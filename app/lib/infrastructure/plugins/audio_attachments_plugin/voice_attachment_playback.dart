import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../../application/services/voice_playback_service/voice_playback_service.dart';
import '../../../presentation/widgets/profile_circle_avatar.dart';

const _voiceMessageMimeTypeWav = 'audio/wav';

class VoiceAttachmentBubble extends StatelessWidget {
  const VoiceAttachmentBubble({
    super.key,
    required this.isFromMe,
    required this.chatItemColor,
    required this.isPlaying,
    required this.duration,
    required this.levels,
    required this.progress,
    required this.onPressed,
    this.avatarImage,
    this.isLoading = false,
  });

  final bool isFromMe;
  final Color chatItemColor;
  final bool isPlaying;
  final Duration duration;
  final List<double> levels;
  final double progress;
  final VoidCallback onPressed;
  final ImageProvider<Object>? avatarImage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return _VoiceAttachmentBubbleFrame(
      chatItemColor: chatItemColor,
      avatar: ProfileCircleAvatar(
        key: const Key('voice_sender_avatar'),
        radius: 28,
        image: avatarImage,
        child: avatarImage == null
            ? Icon(
                isFromMe ? Icons.person : Icons.person_outline,
                color: Colors.white,
                size: 30,
              )
            : null,
      ),
      control: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 30,
              ),
      ),
      progressIndicator: _VoiceAttachmentProgressDots(
        levels: levels,
        progress: progress,
        color: Colors.white,
      ),
      durationText: Text(
        _formatVoiceDuration(duration),
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

class VoiceAttachmentPlaybackBubble extends HookConsumerWidget {
  const VoiceAttachmentPlaybackBubble({
    super.key,
    required this.bytes,
    required this.initialDuration,
    required this.isFromMe,
    required this.chatItemColor,
    required this.levels,
    this.mediaType,
    this.avatarImage,
    this.playbackScopeId,
    this.playbackClipId,
    this.autoPlay = false,
    this.onAutoPlayed,
  });

  final Uint8List bytes;
  final String? mediaType;
  final Duration initialDuration;
  final bool isFromMe;
  final Color chatItemColor;
  final List<double> levels;
  final ImageProvider<Object>? avatarImage;
  final String? playbackScopeId;
  final String? playbackClipId;
  final bool autoPlay;
  final VoidCallback? onAutoPlayed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scopeId = playbackScopeId;
    final clipId = playbackClipId;
    if (scopeId != null && clipId != null) {
      final playback = voicePlaybackServiceProvider(scopeId);
      final hasAutoPlayed = useRef(false);

      useEffect(() {
        if (autoPlay && !hasAutoPlayed.value) {
          hasAutoPlayed.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(
              ref
                  .read(playback.notifier)
                  .toggle(
                    clipId: clipId,
                    bytes: bytes,
                    mediaType: mediaType,
                    initialDuration: initialDuration,
                  ),
            );
            onAutoPlayed?.call();
          });
        }
        return null;
      }, [autoPlay]);

      return _VoiceAttachmentBubbleFrame(
        chatItemColor: chatItemColor,
        avatar: ProfileCircleAvatar(
          key: const Key('voice_sender_avatar'),
          radius: 28,
          image: avatarImage,
          child: avatarImage == null
              ? Icon(
                  isFromMe ? Icons.person : Icons.person_outline,
                  color: Colors.white,
                  size: 30,
                )
              : null,
        ),
        control: _ScopedVoiceAttachmentPlaybackButton(
          playback: playback,
          clipId: clipId,
          bytes: bytes,
          mediaType: mediaType,
          initialDuration: initialDuration,
        ),
        progressIndicator: _ScopedVoiceAttachmentProgressDots(
          playback: playback,
          clipId: clipId,
          levels: levels,
        ),
        durationText: _ScopedVoiceAttachmentDurationText(
          playback: playback,
          clipId: clipId,
          initialDuration: initialDuration,
        ),
      );
    }

    return _LocalVoiceAttachmentPlaybackBubble(
      bytes: bytes,
      mediaType: mediaType,
      initialDuration: initialDuration,
      isFromMe: isFromMe,
      chatItemColor: chatItemColor,
      levels: levels,
      avatarImage: avatarImage,
      autoPlay: autoPlay,
      onAutoPlayed: onAutoPlayed,
    );
  }
}

class _VoiceAttachmentBubbleFrame extends StatelessWidget {
  const _VoiceAttachmentBubbleFrame({
    required this.chatItemColor,
    required this.avatar,
    required this.control,
    required this.progressIndicator,
    required this.durationText,
  });

  final Color chatItemColor;
  final Widget avatar;
  final Widget control;
  final Widget progressIndicator;
  final Widget durationText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: chatItemColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 12),
          control,
          Expanded(child: progressIndicator),
          const SizedBox(width: 8),
          durationText,
        ],
      ),
    );
  }
}

class _LocalVoiceAttachmentPlaybackBubble extends HookWidget {
  const _LocalVoiceAttachmentPlaybackBubble({
    required this.bytes,
    required this.initialDuration,
    required this.isFromMe,
    required this.chatItemColor,
    required this.levels,
    this.mediaType,
    this.avatarImage,
    this.autoPlay = false,
    this.onAutoPlayed,
  });

  final Uint8List bytes;
  final String? mediaType;
  final Duration initialDuration;
  final bool isFromMe;
  final Color chatItemColor;
  final List<double> levels;
  final ImageProvider<Object>? avatarImage;
  final bool autoPlay;
  final VoidCallback? onAutoPlayed;

  @override
  Widget build(BuildContext context) {
    final player = useMemoized(AudioPlayer.new);
    final isPlaying = useState(false);
    final position = useState(Duration.zero);
    final duration = useState(initialDuration);

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
      await player.play(BytesSource(bytes, mimeType: mediaType));
    }

    final hasAutoPlayed = useRef(false);
    useEffect(() {
      if (autoPlay && !hasAutoPlayed.value) {
        hasAutoPlayed.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(togglePlayback());
          onAutoPlayed?.call();
        });
      }
      return null;
    }, [autoPlay]);

    final durationMs = duration.value.inMilliseconds;
    final progress = durationMs <= 0
        ? 0.0
        : (position.value.inMilliseconds / durationMs)
              .clamp(0.0, 1.0)
              .toDouble();

    return VoiceAttachmentBubble(
      isFromMe: isFromMe,
      chatItemColor: chatItemColor,
      isPlaying: isPlaying.value,
      duration: duration.value,
      levels: levels,
      progress: progress,
      avatarImage: avatarImage,
      onPressed: () => unawaited(togglePlayback()),
    );
  }
}

class _ScopedVoiceAttachmentPlaybackButton extends ConsumerWidget {
  const _ScopedVoiceAttachmentPlaybackButton({
    required this.playback,
    required this.clipId,
    required this.bytes,
    required this.mediaType,
    required this.initialDuration,
  });

  final VoicePlaybackServiceProvider playback;
  final String clipId;
  final Uint8List bytes;
  final String? mediaType;
  final Duration initialDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(playback.isPlaying(clipId));

    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      onPressed: () {
        unawaited(
          ref
              .read(playback.notifier)
              .toggle(
                clipId: clipId,
                bytes: bytes,
                mediaType: mediaType,
                initialDuration: initialDuration,
              ),
        );
      },
      icon: Icon(
        isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class _ScopedVoiceAttachmentProgressDots extends ConsumerWidget {
  const _ScopedVoiceAttachmentProgressDots({
    required this.playback,
    required this.clipId,
    required this.levels,
  });

  final VoicePlaybackServiceProvider playback;
  final String clipId;
  final List<double> levels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(playback.progress(clipId));

    return _VoiceAttachmentProgressDots(
      levels: levels,
      progress: progress,
      color: Colors.white,
    );
  }
}

class _ScopedVoiceAttachmentDurationText extends ConsumerWidget {
  const _ScopedVoiceAttachmentDurationText({
    required this.playback,
    required this.clipId,
    required this.initialDuration,
  });

  final VoicePlaybackServiceProvider playback;
  final String clipId;
  final Duration initialDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(playback.duration(clipId, initialDuration));

    return Text(
      _formatVoiceDuration(duration),
      style: const TextStyle(color: Colors.white, fontSize: 13),
    );
  }
}

class _VoiceAttachmentProgressDots extends StatelessWidget {
  const _VoiceAttachmentProgressDots({
    required this.levels,
    required this.progress,
    required this.color,
  });

  final List<double> levels;
  final double progress;
  final Color color;

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
            painter: _VoiceAttachmentProgressDotsPainter(
              levels: levels,
              progress: progress,
              color: color,
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

class _VoiceAttachmentProgressDotsPainter extends CustomPainter {
  const _VoiceAttachmentProgressDotsPainter({
    required this.levels,
    required this.progress,
    required this.color,
  });

  final List<double> levels;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final dotCount = math.max(12, math.min(48, (size.width / 7).floor()));
    final playedPaint = Paint()..color = color;
    final remainingPaint = Paint()..color = color.withValues(alpha: 0.55);
    final markerPaint = Paint()..color = color;
    final drawableWidth = math.max(
      0.0,
      size.width - (_voiceWaveformDotMaxRadius * 2),
    );
    final spacing = drawableWidth / (dotCount - 1);
    final centerY = size.height / 2;
    final progressX = size.width * progress.clamp(0.0, 1.0);

    for (var i = 0; i < dotCount; i++) {
      final x = _voiceWaveformDotMaxRadius + (i * spacing);
      final level = _levelAt(i, dotCount);
      final radius =
          _voiceWaveformDotMinRadius +
          (level * (_voiceWaveformDotMaxRadius - _voiceWaveformDotMinRadius));
      final paint = x <= progressX ? playedPaint : remainingPaint;
      canvas.drawCircle(Offset(x, centerY), radius, paint);
    }

    canvas.drawCircle(Offset(progressX, centerY), 4, markerPaint);
  }

  double _levelAt(int index, int dotCount) {
    if (levels.isEmpty) {
      return _defaultVoiceLevels[index % _defaultVoiceLevels.length];
    }
    final start = (index * levels.length / dotCount).floor();
    final end = math.min(
      levels.length,
      math.max(start + 1, ((index + 1) * levels.length / dotCount).ceil()),
    );
    var level = 0.0;
    for (var i = start; i < end; i++) {
      level = math.max(level, levels[i]);
    }
    return level.clamp(0.0, 1.0).toDouble();
  }

  @override
  bool shouldRepaint(
    covariant _VoiceAttachmentProgressDotsPainter oldDelegate,
  ) {
    return oldDelegate.levels != levels ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
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

List<double> voiceLevelsForAttachment(
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
