import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

part 'call_audio_session_service.g.dart';

final canUsePlatformAudioSessionProvider = Provider<bool>((ref) {
  if (kIsWeb) return false;
  if (!(Platform.isIOS || Platform.isAndroid)) return false;
  return BindingBase.debugBindingType() != null;
});

@Riverpod(keepAlive: true)
Future<AudioSession> audioSession(Ref ref) async => AudioSession.instance;

@Riverpod(keepAlive: true)
class CallAudioSessionService extends _$CallAudioSessionService {
  CallAudioSessionService() : super();

  final Lock _lock = Lock();

  @override
  CallAudioSessionState build() => const CallAudioSessionState();

  Future<bool> acquire({required bool isAudioOnly}) async {
    return _lock.synchronized(() async {
      if (state.isAcquired) return true;

      if (!ref.read(canUsePlatformAudioSessionProvider)) return false;

      final session = await ref.read(audioSessionProvider.future);
      await session.configure(_configurationFor(isAudioOnly: isAudioOnly));

      try {
        final isAcquired = await session.setActive(true);
        state = state.copyWith(isAcquired: isAcquired);
        return state.isAcquired;
      } catch (_) {
        return false;
      }
    });
  }

  Future<void> release() async {
    await _lock.synchronized(() async {
      if (!ref.read(canUsePlatformAudioSessionProvider)) {
        state = state.copyWith(isAcquired: false);
        return;
      }

      final session = await ref.read(audioSessionProvider.future);

      try {
        await session.setActive(
          false,
          avAudioSessionSetActiveOptions:
              AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
        );
      } catch (_) {
        return;
      } finally {
        state = state.copyWith(isAcquired: false);
      }
    });
  }

  /// Switches the audio session to video mode if it is currently acquired in
  /// audio-only mode. No-op otherwise.
  Future<void> reconfigureForVideoIfNeeded() async {
    await _lock.synchronized(() async {
      if (!state.isAcquired) return;
      if (!ref.read(canUsePlatformAudioSessionProvider)) return;
      final session = await ref.read(audioSessionProvider.future);
      await session.configure(_configurationFor(isAudioOnly: false));
    });
  }

  AudioSessionConfiguration _configurationFor({required bool isAudioOnly}) {
    return AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.allowBluetoothA2dp |
          AVAudioSessionCategoryOptions.allowAirPlay,
      avAudioSessionMode: isAudioOnly
          ? AVAudioSessionMode.voiceChat
          : AVAudioSessionMode.videoChat,
      avAudioSessionSetActiveOptions:
          AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType:
          AndroidAudioFocusGainType.gainTransientExclusive,
      androidWillPauseWhenDucked: true,
    );
  }
}

class CallAudioSessionState {
  const CallAudioSessionState({this.isAcquired = false});

  final bool isAcquired;

  CallAudioSessionState copyWith({bool? isAcquired}) {
    return CallAudioSessionState(isAcquired: isAcquired ?? this.isAcquired);
  }
}
