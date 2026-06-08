part of 'chat_screen.dart';

class _ChatTextEntry extends HookConsumerWidget {
  _ChatTextEntry({required String contactId}) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final otherPartyName = ref.watch(provider.otherPartyName);
    final isGroupChat = ref.watch(provider.isGroupChat);
    final shouldDisable = ref.watch(provider.shouldDisable);
    final focusNode = useFocusNode();
    final inputDecoration = context.chatInputDecoration;
    final messageTextValue = useValueListenable(
      controller.messageTextController,
    );
    final hasMessageText = messageTextValue.text.isNotEmpty;
    final recorder = useMemoized(AudioRecorder.new);
    final recorderMimeType = useRef<String>(_voiceMessageMimeTypeMp4);
    final recordingStartedAt = useRef<DateTime?>(null);
    final recordingTicker = useRef<Timer?>(null);
    final recordingCapTimer = useRef<Timer?>(null);
    final amplitudeSubscription = useRef<StreamSubscription<Amplitude>?>(null);
    final voiceEntryMode = useState(_VoiceEntryMode.text);
    final recordingDuration = useState(Duration.zero);
    final recordingLevels = useState(<double>[]);
    final voiceDraft = useState<_VoiceMessageDraft?>(null);
    final isVoiceMode =
        voiceEntryMode.value != _VoiceEntryMode.text &&
        voiceEntryMode.value != _VoiceEntryMode.sending;
    final isVoiceActionBusy =
        voiceEntryMode.value == _VoiceEntryMode.starting ||
        voiceEntryMode.value == _VoiceEntryMode.sending;
    final borderRadius = inputDecoration.border is OutlineInputBorder
        ? (inputDecoration.border as OutlineInputBorder).borderRadius
        : BorderRadius.circular(8.0);
    const voiceMessageMaxDuration = Duration(minutes: 5);

    Future<void> deleteDraftFile(_VoiceMessageDraft draft) async {
      try {
        final file = File(draft.path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e, stackTrace) {
        AppLogger.instance.error(
          'Failed to delete voice message draft',
          error: e,
          stackTrace: stackTrace,
          name: '_ChatTextEntry',
        );
      }
    }

    void clearRecordingTimers() {
      recordingTicker.value?.cancel();
      recordingTicker.value = null;
      recordingCapTimer.value?.cancel();
      recordingCapTimer.value = null;
      final subscription = amplitudeSubscription.value;
      amplitudeSubscription.value = null;
      if (subscription != null) {
        unawaited(subscription.cancel());
      }
    }

    void clearRecordingState() {
      clearRecordingTimers();
      recordingStartedAt.value = null;
      recorderMimeType.value = _voiceMessageMimeTypeMp4;
      voiceEntryMode.value = _VoiceEntryMode.text;
      recordingDuration.value = Duration.zero;
      recordingLevels.value = const [];
    }

    Future<_VoiceMessageDraft?> stopVoiceRecording() async {
      if (voiceEntryMode.value != _VoiceEntryMode.recording) {
        return voiceDraft.value;
      }

      clearRecordingTimers();
      final path = await recorder.stop();
      final duration = recordingDuration.value;
      var levels = recordingLevels.value;
      final mediaType = recorderMimeType.value;
      clearRecordingState();

      if (path == null) return null;
      final fileLevels = await _levelsFromVoiceFile(path, mediaType);
      if (fileLevels.isNotEmpty) {
        levels = fileLevels;
      }

      final draft = _VoiceMessageDraft(
        path: path,
        duration: duration,
        levels: levels,
        waveform: _waveformFromLevels(levels),
        mediaType: mediaType,
      );
      voiceDraft.value = draft;
      voiceEntryMode.value = _VoiceEntryMode.draft;
      return draft;
    }

    Future<void> discardVoiceRecording() async {
      if (voiceEntryMode.value == _VoiceEntryMode.recording) {
        clearRecordingTimers();
        await recorder.cancel();
        clearRecordingState();
      }

      final draft = voiceDraft.value;
      voiceDraft.value = null;
      voiceEntryMode.value = _VoiceEntryMode.text;
      if (draft != null) {
        await deleteDraftFile(draft);
      }
    }

    Future<void> startVoiceRecording() async {
      if (shouldDisable ||
          hasMessageText ||
          voiceEntryMode.value != _VoiceEntryMode.text) {
        return;
      }

      voiceEntryMode.value = _VoiceEntryMode.starting;
      final previousDraft = voiceDraft.value;
      voiceDraft.value = null;
      if (previousDraft != null) {
        await deleteDraftFile(previousDraft);
      }

      try {
        final hasPermission = await recorder.hasPermission();
        if (!hasPermission) {
          voiceEntryMode.value = _VoiceEntryMode.text;
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.voiceMessagePermissionDenied),
              action: SnackBarAction(
                label: context.l10n.cameraOpenSettings,
                onPressed: () => unawaited(openAppSettings()),
              ),
            ),
          );
          return;
        }

        final supportsWav = await recorder.isEncoderSupported(AudioEncoder.wav);
        if (!supportsWav) {
          throw StateError('WAV voice recording is not supported');
        }

        const mediaType = _voiceMessageMimeTypeWav;
        final tempDir = await getTemporaryDirectory();
        final filePath = path.join(
          tempDir.path,
          'voice-message-${clock.now().microsecondsSinceEpoch}.wav',
        );

        await recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: _voiceMessageSampleRate,
            numChannels: 1,
          ),
          path: filePath,
        );

        recorderMimeType.value = mediaType;
        recordingStartedAt.value = clock.now();
        recordingDuration.value = Duration.zero;
        recordingLevels.value = const [];
        voiceEntryMode.value = _VoiceEntryMode.recording;

        recordingTicker.value = Timer.periodic(
          const Duration(milliseconds: 200),
          (_) {
            final startedAt = recordingStartedAt.value;
            if (startedAt == null) return;
            final elapsed = clock.now().difference(startedAt);
            recordingDuration.value = elapsed > voiceMessageMaxDuration
                ? voiceMessageMaxDuration
                : elapsed;
          },
        );
        amplitudeSubscription.value = recorder
            .onAmplitudeChanged(const Duration(milliseconds: 100))
            .listen((amplitude) {
              final normalized = ((amplitude.current + 60) / 60)
                  .clamp(0.0, 1.0)
                  .toDouble();
              recordingLevels.value = [...recordingLevels.value, normalized];
            });
        recordingCapTimer.value = Timer(
          voiceMessageMaxDuration,
          () => unawaited(stopVoiceRecording()),
        );
      } catch (e, stackTrace) {
        clearRecordingState();
        AppLogger.instance.error(
          'Failed to start voice recording',
          error: e,
          stackTrace: stackTrace,
          name: '_ChatTextEntry',
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.voiceMessageRecordingFailed)),
        );
      }
    }

    void showKeyboard() {
      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(focusNode);
    }

    Future<void> sendVoiceRecording() async {
      final draft = voiceEntryMode.value == _VoiceEntryMode.recording
          ? await stopVoiceRecording()
          : voiceDraft.value;
      if (draft == null) return;

      voiceDraft.value = null;
      voiceEntryMode.value = _VoiceEntryMode.sending;
      showKeyboard();

      final didSend = await controller.sendVoiceMessage(
        filePath: draft.path,
        mediaType: draft.mediaType,
        duration: draft.duration,
        waveform: draft.waveform,
      );
      if (!context.mounted) return;

      if (didSend) {
        voiceEntryMode.value = _VoiceEntryMode.text;
        await deleteDraftFile(draft);
      } else {
        voiceDraft.value = draft;
        voiceEntryMode.value = _VoiceEntryMode.draft;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.voiceMessageSendFailed)),
        );
      }
    }

    useEffect(() {
      return () {
        clearRecordingTimers();
        unawaited(() async {
          await recorder.cancel();
          await recorder.dispose();
        }());
        final draft = voiceDraft.value;
        if (draft != null) {
          unawaited(deleteDraftFile(draft));
        }
      };
    }, [recorder]);

    void sendChatActivity() {
      if (!context.mounted) return;
      controller.sendChatActivity();
    }

    void sendMessage() {
      if (!context.mounted) return;
      controller.sendMessage();
      showKeyboard();
    }

    void handleMediaSelection() =>
        _ChatMediaOptions.show(context: context, contactId: _contactId);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!isVoiceMode)
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: shouldDisable
                      ? context.theme.disabledColor
                      : context.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  key: const Key('chat_add_media_button'),
                  radius: 60,
                  child: const Icon(Icons.add, size: 25, color: Colors.white),
                  onTap: shouldDisable ? null : handleMediaSelection,
                ),
              ),
            if (isVoiceMode) ...[
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: shouldDisable || isVoiceActionBusy
                      ? context.theme.disabledColor
                      : context.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  key: const Key('chat_voice_delete_button'),
                  radius: 60,
                  onTap: shouldDisable || isVoiceActionBusy
                      ? null
                      : () => unawaited(discardVoiceRecording()),
                  child: const Icon(
                    Icons.delete,
                    size: 25,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: _VoiceInputPreview(
                  draft: voiceDraft.value,
                  isRecording:
                      voiceEntryMode.value == _VoiceEntryMode.recording,
                  duration: recordingDuration.value,
                  levels: recordingLevels.value,
                  onStopRecording: () => unawaited(stopVoiceRecording()),
                ),
              ),
            ] else
              Expanded(
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: TextFormField(
                    key: const Key('chat_message_input'),
                    enabled: !shouldDisable,
                    onChanged: shouldDisable
                        ? null
                        : (text) => sendChatActivity(),
                    textInputAction: TextInputAction.send,
                    focusNode: focusNode,
                    onEditingComplete:
                        (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                        ? (shouldDisable ? null : sendMessage)
                        : null,
                    onFieldSubmitted:
                        (!kIsWeb && defaultTargetPlatform != TargetPlatform.iOS)
                        ? (shouldDisable ? null : (_) => sendMessage())
                        : null,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    cursorHeight: 16,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    controller: controller.messageTextController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: context.chatInputDecoration.copyWith(
                      hintText: isGroupChat
                          ? context.l10n.chatTypeMessagePromptGroup
                          : context.l10n.chatTypeMessagePrompt(
                              otherPartyName ?? '',
                            ),
                    ),
                    validator: MultiValidator([
                      ZalgoTextValidator(
                        errorText: context.l10n.zalgoTextDetectedError,
                      ),
                      MaxLengthValidator(
                        MaxLengthValidatorType.extraLong.value,
                        errorText: context.l10n.chatTooLong,
                      ),
                    ]).call,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: shouldDisable || isVoiceActionBusy
                    ? context.theme.disabledColor
                    : context.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                key: const Key('chat_send_button'),
                radius: 60,
                onTap: shouldDisable || isVoiceActionBusy
                    ? null
                    : isVoiceMode
                    ? () => unawaited(sendVoiceRecording())
                    : hasMessageText
                    ? sendMessage
                    : () => unawaited(startVoiceRecording()),
                child: Icon(
                  key: Key(
                    hasMessageText ||
                            voiceDraft.value != null ||
                            voiceEntryMode.value == _VoiceEntryMode.recording
                        ? 'chat_send_icon'
                        : 'chat_voice_record_icon',
                  ),
                  hasMessageText ||
                          voiceDraft.value != null ||
                          voiceEntryMode.value == _VoiceEntryMode.recording
                      ? Icons.send
                      : Icons.mic,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
