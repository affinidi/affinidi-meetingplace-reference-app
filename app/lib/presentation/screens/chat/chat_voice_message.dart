part of 'chat_screen.dart';

enum _VoiceEntryMode { text, starting, recording, draft, sending }

const _voiceMessageMimeTypeMp4 = 'audio/mp4';
const _voiceMessageMimeTypeWav = 'audio/wav';
const _voiceMessageSampleRate = 8000;

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

class _VoiceInputPreview extends HookWidget {
  const _VoiceInputPreview({
    required _VoiceMessageDraft? draft,
    required bool isRecording,
    required Duration duration,
    required List<double> levels,
    required VoidCallback onStopRecording,
  }) : _draft = draft,
       _isRecording = isRecording,
       _duration = duration,
       _levels = levels,
       _onStopRecording = onStopRecording;

  final _VoiceMessageDraft? _draft;
  final bool _isRecording;
  final Duration _duration;
  final List<double> _levels;
  final VoidCallback _onStopRecording;

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    if (!_isRecording && draft != null) {
      return _VoicePlayer(
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
    required IconData icon,
    required Duration duration,
    required List<double> levels,
    required double? progress,
    required VoidCallback onPressed,
  }) : _icon = icon,
       _duration = duration,
       _levels = levels,
       _progress = progress,
       _onPressed = onPressed;

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

class _HostedAudioWidget extends StatelessWidget {
  const _HostedAudioWidget({
    required chat.ChatAttachment attachment,
    required Uint8List? cachedBytes,
    required bool hasFailed,
    required VoidCallback onRetry,
    required bool isFromMe,
    required Color chatItemColor,
  }) : _attachment = attachment,
       _cachedBytes = cachedBytes,
       _hasFailed = hasFailed,
       _onRetry = onRetry,
       _isFromMe = isFromMe,
       _chatItemColor = chatItemColor;

  final chat.ChatAttachment _attachment;
  final Uint8List? _cachedBytes;
  final bool _hasFailed;
  final VoidCallback _onRetry;
  final bool _isFromMe;
  final Color _chatItemColor;

  @override
  Widget build(BuildContext context) {
    final cachedBytes = _cachedBytes;
    final levels = _levelsForHostedVoice(_attachment, cachedBytes);
    if (cachedBytes == null) {
      return _VoiceMessageBubble(
        isFromMe: _isFromMe,
        chatItemColor: _chatItemColor,
        isPlaying: false,
        duration: Duration(milliseconds: _attachment.durationMs ?? 0),
        levels: levels,
        progress: 0,
        onPressed: _hasFailed ? _onRetry : () {},
      );
    }

    return _VoicePlayer(
      bytes: cachedBytes,
      mediaType: _attachment.mediaType,
      initialDuration: Duration(milliseconds: _attachment.durationMs ?? 0),
      builder: (context, state) => _VoiceMessageBubble(
        isFromMe: _isFromMe,
        chatItemColor: _chatItemColor,
        isPlaying: state.isPlaying,
        duration: state.duration,
        levels: levels,
        progress: state.progress,
        onPressed: state.toggle,
      ),
    );
  }
}

class _VoiceMessageBubble extends StatelessWidget {
  const _VoiceMessageBubble({
    required bool isFromMe,
    required Color chatItemColor,
    required bool isPlaying,
    required Duration duration,
    required List<double> levels,
    required double progress,
    required VoidCallback onPressed,
  }) : _isFromMe = isFromMe,
       _chatItemColor = chatItemColor,
       _isPlaying = isPlaying,
       _duration = duration,
       _levels = levels,
       _progress = progress,
       _onPressed = onPressed;

  final bool _isFromMe;
  final Color _chatItemColor;
  final bool _isPlaying;
  final Duration _duration;
  final List<double> _levels;
  final double _progress;
  final VoidCallback _onPressed;

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
            radius: 28,
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
            onPressed: _onPressed,
            icon: Icon(
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

class _VoicePlayer extends HookWidget {
  const _VoicePlayer({
    required Duration initialDuration,
    required Widget Function(BuildContext context, _VoicePlayerState state)
    builder,
    String? filePath,
    Uint8List? bytes,
    String? mediaType,
  }) : _initialDuration = initialDuration,
       _builder = builder,
       _filePath = filePath,
       _bytes = bytes,
       _mediaType = mediaType;

  final String? _filePath;
  final Uint8List? _bytes;
  final String? _mediaType;
  final Duration _initialDuration;
  final Widget Function(BuildContext context, _VoicePlayerState state) _builder;

  @override
  Widget build(BuildContext context) {
    final player = useMemoized(AudioPlayer.new);
    final isPlaying = useState(false);
    final position = useState(Duration.zero);
    final duration = useState(_initialDuration);

    useEffect(() {
      final subscriptions = <StreamSubscription<Object?>>[
        player.onPlayerStateChanged.listen((state) {
          isPlaying.value = state == PlayerState.playing;
          if (state == PlayerState.completed || state == PlayerState.stopped) {
            position.value = Duration.zero;
          }
        }),
        player.onPositionChanged.listen((nextPosition) {
          position.value = nextPosition;
        }),
        player.onDurationChanged.listen((nextDuration) {
          if (nextDuration > Duration.zero) {
            duration.value = nextDuration;
          }
        }),
      ];

      return () {
        for (final subscription in subscriptions) {
          unawaited(subscription.cancel());
        }
        unawaited(player.dispose());
      };
    }, [player]);

    Future<void> togglePlayback() async {
      if (isPlaying.value) {
        await player.stop();
        return;
      }

      await player.stop();
      final bytes = _bytes;
      if (bytes != null) {
        await player.play(BytesSource(bytes, mimeType: _mediaType));
        return;
      }

      final filePath = _filePath;
      if (filePath != null) {
        await player.play(DeviceFileSource(filePath, mimeType: _mediaType));
      }
    }

    final durationMs = duration.value.inMilliseconds;
    final progress = durationMs <= 0
        ? 0.0
        : (position.value.inMilliseconds / durationMs)
              .clamp(0.0, 1.0)
              .toDouble();

    return _builder(
      context,
      _VoicePlayerState(
        isPlaying: isPlaying.value,
        duration: duration.value,
        progress: progress,
        toggle: () => unawaited(togglePlayback()),
      ),
    );
  }
}

class _VoiceControlButton extends StatelessWidget {
  const _VoiceControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) : _icon = icon,
       _onPressed = onPressed;

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
    required List<double> levels,
    required double? progress,
    required Color color,
  }) : _levels = levels,
       _progress = progress,
       _color = color;

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
    required List<double> levels,
    required double? progress,
    required Color color,
  }) : _levels = levels,
       _progress = progress,
       _color = color;

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
  if (!_hasWaveformShape(attachment.waveform) && bytes != null) {
    final byteLevels = _levelsFromVoiceBytes(bytes, attachment.mediaType);
    if (byteLevels.isNotEmpty) return byteLevels;
  }
  return _levelsFromWaveform(attachment.waveform);
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
