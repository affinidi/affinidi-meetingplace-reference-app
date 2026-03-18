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

    final isVoiceRecordingSupported =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);

    final isVoiceUiVisible = useState(false);
    final isMicrophoneBlocked = useState(false);
    final recorderController = useState<RecorderController?>(null);
    final currentRecordingPath = useState<String?>(null);
    final elapsedRecording = useState(Duration.zero);
    final recordedDuration = useState(Duration.zero);
    final isStartingRecording = useState(false);
    final verticalDragAccumulated = useRef<double>(0);
    final currentDurationSub = useRef<StreamSubscription<Duration>?>(null);
    final recordingEndedSub = useRef<StreamSubscription<Duration>?>(null);

    final focusNode = useFocusNode();
    final inputDecoration = context.chatInputDecoration;
    final borderRadius = inputDecoration.border is OutlineInputBorder
        ? (inputDecoration.border as OutlineInputBorder).borderRadius
        : BorderRadius.circular(8.0);

    void sendChatActivity() {
      if (!context.mounted) return;
      controller.sendChatActivity();
    }

    void showKeyboard() {
      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(focusNode);
    }

    void sendMessage() {
      if (!context.mounted) return;
      controller.sendMessage();
      showKeyboard();
    }

    void handleMediaSelection() =>
        _ChatMediaOptions.show(context: context, contactId: _contactId);

    String formatDuration(Duration value) {
      final totalSeconds = value.inSeconds;
      final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }

    Future<bool> ensureMicrophonePermission() async {
      final permissionService = ref.read(permissionServiceProvider);
      var status = await permissionService.getMicrophonePermissionStatus();

      if (status.isDenied) {
        status = await permissionService.requestMicrophonePermission();
      }

      return status.isGranted;
    }

    RecorderController ensureRecorderController() {
      final existing = recorderController.value;
      if (existing != null) return existing;

      final created = RecorderController();

      currentDurationSub.value = created.onCurrentDuration.listen((duration) {
        elapsedRecording.value = duration;
      });
      recordingEndedSub.value = created.onRecordingEnded.listen((duration) {
        recordedDuration.value = duration;
      });

      recorderController.value = created;
      return created;
    }

    Future<void> stopRecordingIfNeeded({required bool clearWaveforms}) async {
      final recorder = recorderController.value;
      if (recorder == null) return;

      if (!recorder.isRecording) return;

      final path = await recorder.stop(clearWaveforms);
      if (path != null) currentRecordingPath.value = path;
    }

    Future<void> closeVoiceUi({required bool deleteFile}) async {
      final path = currentRecordingPath.value;
      isVoiceUiVisible.value = false;

      elapsedRecording.value = Duration.zero;
      recordedDuration.value = Duration.zero;

      final recorder = recorderController.value;
      if (recorder != null) {
        try {
          recorder.reset();
        } catch (_) {
          // ignore
        }
      }

      if (deleteFile && path != null) {
        unawaited(File(path).delete().catchError((_) => File(path)));
      }

      currentRecordingPath.value = null;
    }

    Future<void> startNewRecording() async {
      if (isStartingRecording.value) return;
      isStartingRecording.value = true;

      try {
        final previousPath = currentRecordingPath.value;
        if (previousPath != null) {
          unawaited(
            File(previousPath).delete().catchError((_) => File(previousPath)),
          );
        }

        elapsedRecording.value = Duration.zero;
        recordedDuration.value = Duration.zero;

        final tempDir = await getTemporaryDirectory();
        final filePath = p.join(
          tempDir.path,
          'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

        currentRecordingPath.value = filePath;

        final recorder = ensureRecorderController();
        await recorder.record(
          path: filePath,
          recorderSettings: const RecorderSettings(
            sampleRate: 44100,
            bitRate: 128000,
            iosEncoderSettings: IosEncoderSetting(
              iosEncoder: IosEncoder.kAudioFormatMPEG4AAC,
            ),
            androidEncoderSettings: AndroidEncoderSettings(
              androidEncoder: AndroidEncoder.aacLc,
            ),
          ),
        );
      } finally {
        isStartingRecording.value = false;
      }
    }

    Future<void> openVoiceUiAndRecord() async {
      if (!context.mounted) return;
      if (shouldDisable) return;
      if (!isVoiceRecordingSupported) return;
      if (isMicrophoneBlocked.value) return;
      if (isVoiceUiVisible.value) return;

      FocusScope.of(context).unfocus();

      final permitted = await ensureMicrophonePermission();
      if (!context.mounted) return;

      if (!permitted) {
        isMicrophoneBlocked.value = true;
        return;
      }

      isVoiceUiVisible.value = true;
      await startNewRecording();
    }

    Future<void> trashVoiceMessage() async {
      await stopRecordingIfNeeded(clearWaveforms: true);
      await closeVoiceUi(deleteFile: true);
    }

    Future<void> toggleStopOrRecord() async {
      final recorder = recorderController.value;

      if (recorder != null && recorder.isRecording) {
        await stopRecordingIfNeeded(clearWaveforms: false);
        return;
      }

      await startNewRecording();
    }

    Future<void> sendVoiceMessage() async {
      final recorder = recorderController.value;
      if (recorder != null && recorder.isRecording) {
        await stopRecordingIfNeeded(clearWaveforms: false);
      }

      final path = currentRecordingPath.value;
      if (path == null) return;

      final duration = recordedDuration.value == Duration.zero
          ? elapsedRecording.value
          : recordedDuration.value;

      await controller.onVoiceMessageRecorded(
        file: XFile(path),
        duration: duration,
      );

      await closeVoiceUi(deleteFile: false);
    }

    useEffect(() {
      return () {
        final recorder = recorderController.value;
        if (recorder != null) {
          Future.microtask(() async {
            try {
              if (recorder.isRecording) {
                await recorder.stop(true);
              }
            } catch (_) {
              // ignore
            }
            try {
              recorder.dispose();
            } catch (_) {
              // ignore
            }
          });
        }

        currentDurationSub.value?.cancel();
        recordingEndedSub.value?.cancel();
      };
    }, const []);

    final micEnabled =
        !shouldDisable &&
        isVoiceRecordingSupported &&
        !isMicrophoneBlocked.value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: isVoiceUiVisible.value
              ? ClipRRect(
                  key: const Key('chat_voice_overlay'),
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface.withValues(
                          alpha: 0.22,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: context.colorScheme.onSurface.withValues(
                            alpha: 0.14,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                formatDuration(elapsedRecording.value),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.78),
                                ),
                              ),
                              const Spacer(),
                              if (isStartingRecording.value)
                                SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.colorScheme.onSurface
                                        .withValues(alpha: 0.78),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final recorder = recorderController.value;
                              if (recorder == null) {
                                return SizedBox(
                                  height: 74,
                                  width: constraints.maxWidth,
                                );
                              }

                              return AudioWaveforms(
                                size: Size(constraints.maxWidth, 74),
                                recorderController: recorder,
                                enableGesture: false,
                                waveStyle: WaveStyle(
                                  waveColor: context.colorScheme.onSurface
                                      .withValues(alpha: 0.86),
                                  middleLineColor: context.colorScheme.primary,
                                  middleLineThickness: 2.0,
                                  showMiddleLine: true,
                                  waveThickness: 3.0,
                                  spacing: 6.0,
                                  showTop: true,
                                  showBottom: true,
                                  extendWaveform: true,
                                  backgroundColor: Colors.transparent,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _VoiceCircleButton(
                                key: const Key('chat_voice_trash_button'),
                                enabled: !shouldDisable,
                                backgroundColor: context.colorScheme.primary,
                                icon: Icons.delete_outline,
                                onTap: shouldDisable ? null : trashVoiceMessage,
                              ),
                              _VoiceCircleButton(
                                enabled: !shouldDisable,
                                backgroundColor: context.colorScheme.primary,
                                icon:
                                    (recorderController.value?.isRecording ??
                                        false)
                                    ? Icons.stop
                                    : Icons.mic,
                                size: 54,
                                iconSize: 28,
                                onTap: shouldDisable
                                    ? null
                                    : toggleStopOrRecord,
                              ),
                              _VoiceCircleButton(
                                key: const Key('chat_voice_send_button'),
                                enabled:
                                    !shouldDisable &&
                                    (currentRecordingPath.value != null ||
                                        (recorderController
                                                .value
                                                ?.isRecording ??
                                            false)),
                                backgroundColor: context.colorScheme.primary,
                                icon: Icons.send,
                                onTap: shouldDisable ? null : sendVoiceMessage,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('chat_text_entry_row'),
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
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
                        child: const Icon(
                          Icons.add,
                          size: 25,
                          color: Colors.white,
                        ),
                        onTap: shouldDisable ? null : handleMediaSelection,
                      ),
                    ),
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
                              (!kIsWeb &&
                                  defaultTargetPlatform == TargetPlatform.iOS)
                              ? (shouldDisable ? null : sendMessage)
                              : null,
                          onFieldSubmitted:
                              (!kIsWeb &&
                                  defaultTargetPlatform != TargetPlatform.iOS)
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
                    GestureDetector(
                      key: const Key('chat_voice_button'),
                      onVerticalDragStart: micEnabled
                          ? (_) {
                              verticalDragAccumulated.value = 0;
                            }
                          : null,
                      onVerticalDragUpdate: micEnabled
                          ? (details) {
                              verticalDragAccumulated.value += details.delta.dy;
                            }
                          : null,
                      onVerticalDragEnd: micEnabled
                          ? (_) {
                              if (verticalDragAccumulated.value < -24) {
                                unawaited(openVoiceUiAndRecord());
                              }
                              verticalDragAccumulated.value = 0;
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: micEnabled
                              ? context.colorScheme.primary
                              : context.theme.disabledColor,
                          shape: BoxShape.circle,
                        ),
                        child: InkWell(
                          radius: 60,
                          onTap: micEnabled ? openVoiceUiAndRecord : null,
                          child: const Icon(
                            Icons.mic,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: shouldDisable
                            ? context.theme.disabledColor
                            : context.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: InkWell(
                        key: const Key('chat_send_button'),
                        radius: 60,
                        onTap: shouldDisable ? null : sendMessage,
                        child: const Icon(
                          Icons.send,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _VoiceCircleButton extends StatelessWidget {
  const _VoiceCircleButton({
    super.key,
    required this.enabled,
    required this.backgroundColor,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.iconSize = 24,
  });

  final bool enabled;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = enabled
        ? backgroundColor
        : context.theme.disabledColor;
    return SizedBox(
      height: size,
      width: size,
      child: Material(
        color: resolvedColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(icon, size: iconSize, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
