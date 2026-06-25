part of 'chat_screen.dart';

enum _VoiceEntryMode { text, starting, recording, draft, sending }

const _voiceMessageMimeTypeMp4 = 'audio/mp4';
const _voiceMessageMimeTypeWav = 'audio/wav';
const _voiceMessageSampleRate = 16000;

class _VoiceMessageDraft {
  const _VoiceMessageDraft({
    required this.path,
    required this.duration,
    required this.levels,
    required this.waveform,
    required this.mediaType,
  });

  final String path;
  final Duration duration;
  final List<double> levels;
  final List<int> waveform;
  final String mediaType;
}

class _VoiceRecorderState {
  const _VoiceRecorderState({
    required this.mode,
    required this.duration,
    required this.levels,
    required this.draft,
    required this.startRecording,
    required this.stopRecording,
    required this.discard,
    required this.send,
  });

  final _VoiceEntryMode mode;
  final Duration duration;
  final List<double> levels;
  final _VoiceMessageDraft? draft;
  final VoidCallback startRecording;
  final VoidCallback stopRecording;
  final VoidCallback discard;
  final VoidCallback send;

  bool get isRecording => mode == _VoiceEntryMode.recording;

  bool get isVoiceMode =>
      mode != _VoiceEntryMode.text && mode != _VoiceEntryMode.sending;

  bool get isBusy =>
      mode == _VoiceEntryMode.starting || mode == _VoiceEntryMode.sending;

  bool get hasDraftOrRecording => draft != null || isRecording;
}

/// Owns voice-recording state and lifecycle, exposing the current state and
/// the start, stop, discard, and send actions to its builder.
///
/// Mirrors the [_VoicePlayer] builder pattern so the recording logic lives
/// next to playback instead of inside the chat input widget.
class _VoiceRecorder extends HookWidget {
  const _VoiceRecorder({
    required this._controller,
    required this._shouldDisable,
    required this._hasMessageText,
    required this._onRequestKeyboard,
    required this._builder,
  });

  final ChatScreenController _controller;
  final bool _shouldDisable;
  final bool _hasMessageText;
  final VoidCallback _onRequestKeyboard;
  final Widget Function(BuildContext context, _VoiceRecorderState state)
  _builder;

  @override
  Widget build(BuildContext context) {
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
          name: '_VoiceRecorder',
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

    Future<_VoiceMessageDraft?> stopRecording() async {
      if (voiceEntryMode.value != _VoiceEntryMode.recording) {
        return voiceDraft.value;
      }

      clearRecordingTimers();
      final filePath = await recorder.stop();
      final duration = recordingDuration.value;
      var levels = recordingLevels.value;
      final mediaType = recorderMimeType.value;
      clearRecordingState();

      if (filePath == null) return null;
      final fileLevels = await _levelsFromVoiceFile(filePath, mediaType);
      if (fileLevels.isNotEmpty) {
        levels = fileLevels;
      }

      final draft = _VoiceMessageDraft(
        path: filePath,
        duration: duration,
        levels: levels,
        waveform: _waveformFromLevels(levels),
        mediaType: mediaType,
      );
      voiceDraft.value = draft;
      voiceEntryMode.value = _VoiceEntryMode.draft;
      return draft;
    }

    Future<void> discard() async {
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

    Future<void> startRecording() async {
      if (_shouldDisable ||
          _hasMessageText ||
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

        final encoder = await _supportedVoiceEncoder(recorder);
        if (encoder == null) {
          throw AppException(
            'No supported voice recording encoder',
            code: AppExceptionType.voiceEncoderNotSupported.name,
          );
        }

        final mediaType = _voiceMessageMediaType(encoder);
        final tempDir = await getTemporaryDirectory();
        final filePath = path.join(
          tempDir.path,
          'voice-message-${clock.now().microsecondsSinceEpoch}'
          '.${_voiceMessageFileExtension(encoder)}',
        );

        await recorder.start(
          RecordConfig(
            encoder: encoder,
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
          () => unawaited(stopRecording()),
        );
      } catch (e, stackTrace) {
        clearRecordingState();
        AppLogger.instance.error(
          'Failed to start voice recording',
          error: e,
          stackTrace: stackTrace,
          name: '_VoiceRecorder',
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.voiceMessageRecordingFailed)),
        );
      }
    }

    Future<void> send() async {
      final draft = voiceEntryMode.value == _VoiceEntryMode.recording
          ? await stopRecording()
          : voiceDraft.value;
      if (draft == null) return;

      voiceDraft.value = null;
      voiceEntryMode.value = _VoiceEntryMode.sending;
      _onRequestKeyboard();

      final didSend = await _controller.sendVoiceMessage(
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
        voiceEntryMode.value = _VoiceEntryMode.text;
        await deleteDraftFile(draft);
        if (!context.mounted) return;
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

    return _builder(
      context,
      _VoiceRecorderState(
        mode: voiceEntryMode.value,
        duration: recordingDuration.value,
        levels: recordingLevels.value,
        draft: voiceDraft.value,
        startRecording: () => unawaited(startRecording()),
        stopRecording: () => unawaited(stopRecording()),
        discard: () => unawaited(discard()),
        send: () => unawaited(send()),
      ),
    );
  }
}

class _VoiceInputPreview extends HookConsumerWidget {
  const _VoiceInputPreview({
    required this._contactId,
    required this._draft,
    required this._isRecording,
    required this._duration,
    required this._levels,
    required this._onStopRecording,
  });

  final String _contactId;
  final _VoiceMessageDraft? _draft;
  final bool _isRecording;
  final Duration _duration;
  final List<double> _levels;
  final VoidCallback _onStopRecording;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = _draft;
    final controller = ref.read(
      chatScreenControllerProvider(_contactId).notifier,
    );
    if (!_isRecording && draft != null) {
      return _VoicePlayer(
        contactId: _contactId,
        clipId: controller.voiceClipId('voice-input-draft'),
        filePath: draft.path,
        mediaType: draft.mediaType,
        initialDuration: draft.duration,
        builder: (context, state) => _VoiceInputPill(
          icon: state.isPlaying ? Icons.pause : Icons.play_arrow,
          duration: state.duration,
          levels: draft.levels,
          progress: state.progress,
          onPressed: state.toggle,
        ),
      );
    }

    return _VoiceInputPill(
      icon: Icons.pause,
      duration: _duration,
      levels: _levels,
      progress: null,
      onPressed: _onStopRecording,
    );
  }
}

class _VoiceInputPill extends StatelessWidget {
  const _VoiceInputPill({
    required this._icon,
    required this._duration,
    required this._levels,
    required this._progress,
    required this._onPressed,
  });

  final IconData _icon;
  final Duration _duration;
  final List<double> _levels;
  final double? _progress;
  final VoidCallback _onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _VoiceControlButton(icon: _icon, onPressed: _onPressed),
          const SizedBox(width: 10),
          Expanded(
            child: _VoiceProgressDots(
              levels: _levels,
              progress: _progress,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatVoiceDuration(_duration),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _HostedAudioWidget extends HookWidget {
  const _HostedAudioWidget({
    required this._clipId,
    required this._contactId,
    required this._attachment,
    required this._cachedBytes,
    required this._hasFailed,
    required this._onRetry,
    required this._onDownload,
    required this._isFromMe,
    required this._chatItemColor,
    required this._senderAvatar,
  });

  final String _clipId;
  final String _contactId;
  final chat.ChatAttachment _attachment;
  final Uint8List? _cachedBytes;
  final bool _hasFailed;
  final bool Function() _onRetry;
  final bool Function() _onDownload;
  final bool _isFromMe;
  final Color _chatItemColor;
  final ImageProvider<Object>? _senderAvatar;

  @override
  Widget build(BuildContext context) {
    final cachedBytes = _cachedBytes;
    final levels = _levelsForHostedVoice(_attachment, cachedBytes);
    final durationMs =
        chat.VoiceMessageMetadata.of(_attachment)?.durationMs ?? 0;

    // Set when the user taps play before the clip is cached, so the download
    // is kicked off and playback starts automatically once the bytes arrive.
    final playRequested = useState(false);

    if (cachedBytes == null) {
      // While a requested download is still in flight (and has not failed),
      // show a spinner instead of an inert play button.
      final isLoading = playRequested.value && !_hasFailed;

      void onPressed() {
        if (_hasFailed) {
          if (_onRetry()) playRequested.value = true;
          return;
        }
        if (playRequested.value) return;
        if (_onDownload()) playRequested.value = true;
      }

      return _VoiceMessageBubble(
        isFromMe: _isFromMe,
        chatItemColor: _chatItemColor,
        isPlaying: false,
        isLoading: isLoading,
        duration: Duration(milliseconds: durationMs),
        levels: levels,
        progress: 0,
        onPressed: onPressed,
        senderAvatar: _senderAvatar,
      );
    }

    return _VoicePlayer(
      contactId: _contactId,
      clipId: _clipId,
      bytes: cachedBytes,
      mediaType: _attachment.mediaType,
      initialDuration: Duration(milliseconds: durationMs),
      autoPlay: playRequested.value,
      onAutoPlayed: () => playRequested.value = false,
      builder: (context, state) => _VoiceMessageBubble(
        isFromMe: _isFromMe,
        chatItemColor: _chatItemColor,
        isPlaying: state.isPlaying,
        duration: state.duration,
        levels: levels,
        progress: state.progress,
        onPressed: state.toggle,
        senderAvatar: _senderAvatar,
      ),
    );
  }
}

class _VoiceMessageBubble extends StatelessWidget {
  const _VoiceMessageBubble({
    required this._isFromMe,
    required this._chatItemColor,
    required this._isPlaying,
    required this._duration,
    required this._levels,
    required this._progress,
    required this._onPressed,
    required this._senderAvatar,
    this._isLoading = false,
  });

  final bool _isFromMe;
  final Color _chatItemColor;
  final bool _isPlaying;
  final Duration _duration;
  final List<double> _levels;
  final double _progress;
  final VoidCallback _onPressed;
  final ImageProvider<Object>? _senderAvatar;
  final bool _isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _chatItemColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          ProfileCircleAvatar(
            key: const Key('voice_sender_avatar'),
            radius: 28,
            image: _senderAvatar,
            child: Icon(
              _isFromMe ? Icons.person : Icons.person_outline,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            onPressed: _isLoading ? null : _onPressed,
            icon: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
          Expanded(
            child: _VoiceProgressDots(
              levels: _levels,
              progress: _progress,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatVoiceDuration(_duration),
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _VoicePlayerState {
  const _VoicePlayerState({
    required this.isPlaying,
    required this.duration,
    required this.progress,
    required this.toggle,
  });

  final bool isPlaying;
  final Duration duration;
  final double progress;
  final VoidCallback toggle;
}

class _VoicePlayer extends HookConsumerWidget {
  const _VoicePlayer({
    required this._contactId,
    required this._clipId,
    required this._initialDuration,
    required this._builder,
    this._filePath,
    this._bytes,
    this._mediaType,
    this._autoPlay = false,
    this._onAutoPlayed,
  });

  final String _contactId;
  final String _clipId;
  final String? _filePath;
  final Uint8List? _bytes;
  final String? _mediaType;
  final Duration _initialDuration;
  final bool _autoPlay;
  final VoidCallback? _onAutoPlayed;
  final Widget Function(BuildContext context, _VoicePlayerState state) _builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final isPlaying = ref.watch(
      provider.select(
        (state) =>
            state.voicePlayback.isActive(_clipId) &&
            state.voicePlayback.isPlaying,
      ),
    );
    final progress = ref.watch(
      provider.select((state) => state.voicePlayback.progressFor(_clipId)),
    );
    final duration = ref.watch(
      provider.select((state) {
        final playback = state.voicePlayback;
        if (!playback.isActive(_clipId)) return _initialDuration;
        return playback.duration > Duration.zero
            ? playback.duration
            : _initialDuration;
      }),
    );

    Future<void> togglePlayback() async {
      await controller.toggleVoicePlayback(
        clipId: _clipId,
        bytes: _bytes,
        filePath: _filePath,
        mediaType: _mediaType,
        initialDuration: _initialDuration,
      );
    }

    final hasAutoPlayed = useRef(false);
    useEffect(() {
      if (_autoPlay && !hasAutoPlayed.value) {
        hasAutoPlayed.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(togglePlayback());
          _onAutoPlayed?.call();
        });
      }
      return null;
    }, [_autoPlay]);

    return _builder(
      context,
      _VoicePlayerState(
        isPlaying: isPlaying,
        duration: duration,
        progress: progress,
        toggle: () => unawaited(togglePlayback()),
      ),
    );
  }
}

class _VoiceControlButton extends StatelessWidget {
  const _VoiceControlButton({required this._icon, required this._onPressed});

  final IconData _icon;
  final VoidCallback _onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(backgroundColor: Colors.white),
        onPressed: _onPressed,
        icon: Icon(_icon, color: context.colorScheme.primary, size: 20),
      ),
    );
  }
}

class _VoiceProgressDots extends StatelessWidget {
  const _VoiceProgressDots({
    required this._levels,
    required this._progress,
    required this._color,
  });

  final List<double> _levels;
  final double? _progress;
  final Color _color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth && constraints.maxWidth > 0
            ? constraints.maxWidth
            : _voiceWaveformFallbackWidth;

        return SizedBox(
          width: width,
          height: _voiceWaveformHeight,
          child: CustomPaint(
            key: const Key('voice_waveform_paint'),
            painter: _VoiceProgressDotsPainter(
              levels: _levels,
              progress: _progress,
              color: _color,
            ),
          ),
        );
      },
    );
  }
}

const _voiceWaveformHeight = 28.0;
const _voiceWaveformFallbackWidth = 120.0;
const _voiceWaveformDotMinRadius = 2.4;
const _voiceWaveformDotMaxRadius = 7.5;

class _VoiceProgressDotsPainter extends CustomPainter {
  const _VoiceProgressDotsPainter({
    required this._levels,
    required this._progress,
    required this._color,
  });

  final List<double> _levels;
  final double? _progress;
  final Color _color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final dotCount = math.max(12, math.min(48, (size.width / 7).floor()));
    final playedPaint = Paint()..color = _color;
    final remainingPaint = Paint()..color = _color.withValues(alpha: 0.55);
    final markerPaint = Paint()..color = _color;
    final drawableWidth = math.max(
      0.0,
      size.width - (_voiceWaveformDotMaxRadius * 2),
    );
    final spacing = drawableWidth / (dotCount - 1);
    final centerY = size.height / 2;
    final progress = _progress?.clamp(0.0, 1.0).toDouble();
    final progressX = progress == null ? null : size.width * progress;

    for (var i = 0; i < dotCount; i++) {
      final x = _voiceWaveformDotMaxRadius + (i * spacing);
      final level = _levelAt(i, dotCount);
      final radius =
          _voiceWaveformDotMinRadius +
          (level * (_voiceWaveformDotMaxRadius - _voiceWaveformDotMinRadius));
      final paint = progressX != null && x <= progressX
          ? playedPaint
          : remainingPaint;
      canvas.drawCircle(Offset(x, centerY), radius, paint);
    }

    if (progressX != null) {
      canvas.drawCircle(Offset(progressX, centerY), 4, markerPaint);
    }
  }

  double _levelAt(int index, int dotCount) {
    if (_levels.isEmpty) {
      return _defaultVoiceLevels[index % _defaultVoiceLevels.length];
    }
    final start = (index * _levels.length / dotCount).floor();
    final end = math.min(
      _levels.length,
      math.max(start + 1, ((index + 1) * _levels.length / dotCount).ceil()),
    );
    var level = 0.0;
    for (var i = start; i < end; i++) {
      level = math.max(level, _levels[i]);
    }
    return level.clamp(0.0, 1.0).toDouble();
  }

  @override
  bool shouldRepaint(covariant _VoiceProgressDotsPainter oldDelegate) {
    return oldDelegate._levels != _levels ||
        oldDelegate._progress != _progress ||
        oldDelegate._color != _color;
  }
}

const _defaultVoiceLevels = <double>[
  0.05,
  0.05,
  0.05,
  0.05,
  0.05,
  0.05,
  0.05,
  0.05,
  0.05,
  0.05,
  0.05,
  0.05,
];

List<int> _waveformFromLevels(List<double> levels) {
  return levels
      .map((level) => (level.clamp(0.0, 1.0) * 100).round())
      .toList(growable: false);
}

List<double> _levelsForHostedVoice(
  chat.ChatAttachment attachment,
  Uint8List? bytes,
) {
  final waveform = chat.VoiceMessageMetadata.of(attachment)?.waveform;
  if (!_hasWaveformShape(waveform) && bytes != null) {
    final byteLevels = _levelsFromVoiceBytes(bytes, attachment.mediaType);
    if (byteLevels.isNotEmpty) return byteLevels;
  }
  return _levelsFromWaveform(waveform);
}

Future<List<double>> _levelsFromVoiceFile(String path, String mediaType) async {
  if (mediaType != _voiceMessageMimeTypeWav) return const [];

  try {
    final bytes = await File(path).readAsBytes();
    return _levelsFromVoiceBytes(bytes, mediaType);
  } catch (e, stackTrace) {
    AppLogger.instance.error(
      'Failed to extract voice waveform',
      error: e,
      stackTrace: stackTrace,
      name: '_ChatTextEntry',
    );
    return const [];
  }
}

List<double> _levelsFromVoiceBytes(Uint8List bytes, String? mediaType) {
  if (mediaType != _voiceMessageMimeTypeWav) return const [];
  return _levelsFromWavBytes(bytes);
}

List<double> _levelsFromWavBytes(Uint8List bytes) {
  if (bytes.length < 44) return const [];

  final data = ByteData.sublistView(bytes);
  if (_ascii(bytes, 0, 4) != 'RIFF' || _ascii(bytes, 8, 4) != 'WAVE') {
    return const [];
  }

  var offset = 12;
  var channels = 1;
  var bitsPerSample = 16;
  int? dataOffset;
  int? dataLength;

  while (offset + 8 <= bytes.length) {
    final chunkId = _ascii(bytes, offset, 4);
    final chunkSize = data.getUint32(offset + 4, Endian.little);
    final chunkDataOffset = offset + 8;
    if (chunkDataOffset + chunkSize > bytes.length) break;

    if (chunkId == 'fmt ' && chunkSize >= 16) {
      final audioFormat = data.getUint16(chunkDataOffset, Endian.little);
      if (audioFormat != 1) return const [];
      channels = data.getUint16(chunkDataOffset + 2, Endian.little);
      bitsPerSample = data.getUint16(chunkDataOffset + 14, Endian.little);
    } else if (chunkId == 'data') {
      dataOffset = chunkDataOffset;
      dataLength = chunkSize;
      break;
    }

    offset = chunkDataOffset + chunkSize + (chunkSize.isOdd ? 1 : 0);
  }

  if (dataOffset == null || dataLength == null || bitsPerSample != 16) {
    return const [];
  }
  if (channels <= 0) return const [];

  final bytesPerSample = bitsPerSample ~/ 8;
  final bytesPerFrame = bytesPerSample * channels;
  final frameCount = dataLength ~/ bytesPerFrame;
  if (frameCount <= 0) return const [];

  const targetCount = 64;
  final buckets = List<double>.filled(targetCount, 0);
  for (var bucket = 0; bucket < targetCount; bucket++) {
    final startFrame = (bucket * frameCount / targetCount).floor();
    final endFrame = math.max(
      startFrame + 1,
      ((bucket + 1) * frameCount / targetCount).floor(),
    );
    var peak = 0;
    for (
      var frame = startFrame;
      frame < endFrame && frame < frameCount;
      frame++
    ) {
      for (var channel = 0; channel < channels; channel++) {
        final sampleOffset =
            dataOffset + (frame * bytesPerFrame) + (channel * bytesPerSample);
        final sample = data.getInt16(sampleOffset, Endian.little).abs();
        if (sample > peak) peak = sample;
      }
    }
    buckets[bucket] = peak / 32768;
  }

  final peak = buckets.fold<double>(0, math.max);
  if (peak <= 0) return buckets;

  return buckets
      .map((level) => math.pow(level / peak, 0.7).clamp(0.0, 1.0).toDouble())
      .toList(growable: false);
}

String _ascii(Uint8List bytes, int offset, int length) {
  if (offset + length > bytes.length) return '';
  return String.fromCharCodes(bytes.sublist(offset, offset + length));
}

List<double> _levelsFromWaveform(List<int>? waveform) {
  if (waveform == null || waveform.isEmpty) return _defaultVoiceLevels;
  return waveform
      .map((level) => (level.clamp(0, 100) / 100).toDouble())
      .toList(growable: false);
}

bool _hasWaveformShape(List<int>? waveform) {
  if (waveform == null || waveform.length < 2) return false;
  var min = 100;
  var max = 0;
  for (final level in waveform) {
    final value = level.clamp(0, 100);
    min = math.min(min, value);
    max = math.max(max, value);
  }
  return max > min;
}

String _formatVoiceDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

Future<AudioEncoder?> _supportedVoiceEncoder(AudioRecorder recorder) async {
  for (final encoder in const [AudioEncoder.wav, AudioEncoder.aacLc]) {
    if (await recorder.isEncoderSupported(encoder)) {
      return encoder;
    }
  }
  return null;
}

String _voiceMessageMediaType(AudioEncoder encoder) {
  return encoder == AudioEncoder.wav
      ? _voiceMessageMimeTypeWav
      : _voiceMessageMimeTypeMp4;
}

String _voiceMessageFileExtension(AudioEncoder encoder) {
  return encoder == AudioEncoder.wav ? 'wav' : 'm4a';
}
