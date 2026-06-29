import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'voice_playback_service.g.dart';

/// Owns voice-message playback for one chat. Scoped per [contactId] so audio
/// keeps playing while the message list virtualizes, and stops when the chat
/// screen is left.
@riverpod
class VoicePlaybackService extends _$VoicePlaybackService {
  AudioPlayer? _player;
  final _subscriptions = <StreamSubscription<Object?>>[];
  KeepAliveLink? _playbackKeepAlive;
  Uint8List? _activeSourceBytes;
  String? _activeSourceFilePath;

  @override
  VoicePlaybackState build(String contactId) {
    ref.onDispose(() {
      unawaited(_disposePlayer());
    });
    return const VoicePlaybackState();
  }

  static String clipId(String contactId, String attachmentCacheKey) =>
      '$contactId\u0000$attachmentCacheKey';

  Future<void> stop() async {
    await _haltPlayback();
  }

  Future<void> disposePlaybackResources() {
    return _disposePlayer();
  }

  Future<void> _haltPlayback() async {
    final player = _player;
    if (player != null) {
      await player.stop();
    }
    _clearActiveSource();
    state = const VoicePlaybackState();
    _releasePlaybackKeepAlive();
  }

  Future<void> toggle({
    required String clipId,
    Uint8List? bytes,
    String? filePath,
    String? mediaType,
    Duration initialDuration = Duration.zero,
  }) async {
    final player = _player ??= AudioPlayer();
    _ensureSubscriptions(player);

    if (state.isActive(clipId) && state.isPlaying) {
      await player.stop();
      _clearActiveSource();
      state = state.copyWith(isPlaying: false, position: Duration.zero);
      _releasePlaybackKeepAlive();
      return;
    }

    await player.stop();
    _pinActiveSource(bytes: bytes, filePath: filePath);
    _acquirePlaybackKeepAlive();
    state = VoicePlaybackState(activeClipId: clipId, duration: initialDuration);

    final sourceBytes = _activeSourceBytes;
    if (sourceBytes != null) {
      await player.play(BytesSource(sourceBytes, mimeType: mediaType));
      return;
    }

    final sourceFilePath = _activeSourceFilePath;
    if (sourceFilePath != null) {
      await player.play(DeviceFileSource(sourceFilePath, mimeType: mediaType));
    }
  }

  void _pinActiveSource({Uint8List? bytes, String? filePath}) {
    _activeSourceBytes = bytes;
    _activeSourceFilePath = filePath;
  }

  void _clearActiveSource() {
    _activeSourceBytes = null;
    _activeSourceFilePath = null;
  }

  void _acquirePlaybackKeepAlive() {
    _playbackKeepAlive ??= ref.keepAlive();
  }

  void _releasePlaybackKeepAlive() {
    _playbackKeepAlive?.close();
    _playbackKeepAlive = null;
  }

  void _ensureSubscriptions(AudioPlayer player) {
    if (_subscriptions.isNotEmpty) return;

    _subscriptions.addAll([
      player.onPlayerStateChanged.listen((playerState) {
        if (state.activeClipId == null) return;

        if (playerState == PlayerState.completed) {
          _clearActiveSource();
          state = const VoicePlaybackState();
          _releasePlaybackKeepAlive();
          return;
        }

        if (playerState == PlayerState.stopped) return;

        state = state.copyWith(isPlaying: playerState == PlayerState.playing);
      }),
      player.onPositionChanged.listen((position) {
        if (state.activeClipId == null) return;
        state = state.copyWith(position: position);
      }),
      player.onDurationChanged.listen((duration) {
        if (state.activeClipId == null || duration <= Duration.zero) return;
        state = state.copyWith(duration: duration);
      }),
    ]);
  }

  Future<void> _disposePlayer() async {
    _clearActiveSource();
    _releasePlaybackKeepAlive();
    final player = _player;
    _player = null;

    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    if (player != null) {
      await player.dispose();
    }
  }
}

class VoicePlaybackState {
  const VoicePlaybackState({
    this.activeClipId,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  final String? activeClipId;
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  bool isActive(String clipId) => activeClipId == clipId;

  double progressFor(String clipId) {
    if (!isActive(clipId)) return 0;
    final durationMs = duration.inMilliseconds;
    if (durationMs <= 0) return 0;
    return (position.inMilliseconds / durationMs).clamp(0.0, 1.0).toDouble();
  }

  VoicePlaybackState copyWith({
    String? activeClipId,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool clearActiveClipId = false,
  }) {
    return VoicePlaybackState(
      activeClipId: clearActiveClipId
          ? null
          : (activeClipId ?? this.activeClipId),
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

extension VoicePlaybackServiceProviderSelectors
    on VoicePlaybackServiceProvider {
  ProviderListenable<bool> isPlaying(String clipId) {
    return select(
      (playback) => playback.isActive(clipId) && playback.isPlaying,
    );
  }

  ProviderListenable<double> progress(String clipId) {
    return select((playback) => playback.progressFor(clipId));
  }

  ProviderListenable<Duration> duration(String clipId, Duration fallback) {
    return select((playback) {
      if (!playback.isActive(clipId)) return fallback;
      return playback.duration > Duration.zero ? playback.duration : fallback;
    });
  }
}
