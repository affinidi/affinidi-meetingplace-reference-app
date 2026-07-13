import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/call_audio_session_service/call_audio_session_service.dart';

class _ControllableFakeAudioSession extends Fake implements AudioSession {
  final activationRequests = <bool>[];
  final configurations = <AudioSessionConfiguration>[];
  final _setActiveCompleters = <Completer<bool>>[];
  final _setActiveCalled = StreamController<bool>.broadcast();
  AVAudioSessionSetActiveOptions? lastSetActiveOptions;

  Future<bool> nextSetActiveCall() => _setActiveCalled.stream.first;

  void completeNextSetActive(bool value) {
    _setActiveCompleters.removeAt(0).complete(value);
  }

  @override
  Future<void> configure(AudioSessionConfiguration configuration) async {
    configurations.add(configuration);
  }

  @override
  Future<bool> setActive(
    bool active, {
    AVAudioSessionSetActiveOptions? avAudioSessionSetActiveOptions,
    AndroidAudioFocusGainType? androidAudioFocusGainType,
    AndroidAudioAttributes? androidAudioAttributes,
    bool? androidWillPauseWhenDucked,
    AudioSessionConfiguration fallbackConfiguration =
        const AudioSessionConfiguration.music(),
  }) {
    activationRequests.add(active);
    lastSetActiveOptions = avAudioSessionSetActiveOptions;
    final completer = Completer<bool>();
    _setActiveCompleters.add(completer);
    _setActiveCalled.add(active);
    return completer.future;
  }
}

void main() {
  ProviderContainer buildContainer(_ControllableFakeAudioSession audioSession) {
    return ProviderContainer(
      overrides: [
        canUsePlatformAudioSessionProvider.overrideWith((ref) => true),
        audioSessionProvider.overrideWith((ref) async => audioSession),
      ],
    );
  }

  group('CallAudioSessionService', () {
    test('serializes release behind an in-flight acquire', () async {
      final audioSession = _ControllableFakeAudioSession();
      final container = buildContainer(audioSession);
      addTearDown(container.dispose);

      final service = container.read(callAudioSessionServiceProvider.notifier);

      final acquireFuture = service.acquire(isAudioOnly: false);
      await audioSession.nextSetActiveCall();

      final releaseFuture = service.release();
      await pumpEventQueue();

      expect(audioSession.activationRequests, [true]);

      audioSession.completeNextSetActive(true);
      expect(await acquireFuture, isTrue);

      expect(await audioSession.nextSetActiveCall(), isFalse);
      expect(audioSession.activationRequests, [true, false]);

      audioSession.completeNextSetActive(true);
      await releaseFuture;

      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isFalse,
      );
      expect(
        audioSession.lastSetActiveOptions,
        AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      );
    });

    test('does not reactivate when two acquires overlap', () async {
      final audioSession = _ControllableFakeAudioSession();
      final container = buildContainer(audioSession);
      addTearDown(container.dispose);

      final service = container.read(callAudioSessionServiceProvider.notifier);

      final firstAcquire = service.acquire(isAudioOnly: true);
      await audioSession.nextSetActiveCall();

      final secondAcquire = service.acquire(isAudioOnly: true);
      await pumpEventQueue();

      expect(audioSession.activationRequests, [true]);

      audioSession.completeNextSetActive(true);

      expect(await firstAcquire, isTrue);
      expect(await secondAcquire, isTrue);
      expect(audioSession.activationRequests, [true]);
      expect(audioSession.configurations, hasLength(1));
      expect(
        audioSession.configurations.single.avAudioSessionMode,
        AVAudioSessionMode.voiceChat,
      );
    });
  });
}
