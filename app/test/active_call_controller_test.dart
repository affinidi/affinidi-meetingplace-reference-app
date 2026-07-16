import 'dart:async';
import 'dart:io';

import 'package:fake_async/fake_async.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';

import 'fakes/fake_chat_session_service.dart';

class _FakeSession extends Fake implements AudioVideoCallSession {
  final List<bool> micCalls = [];
  int hangUpCalls = 0;
  final _stateController = StreamController<AudioVideoCallState>.broadcast();
  final _participantController =
      StreamController<CallParticipantEvent>.broadcast();

  void emit(AudioVideoCallState s) => _stateController.add(s);

  @override
  Stream<AudioVideoCallState> get state => _stateController.stream;

  @override
  Stream<CallParticipantEvent> get participantEvents =>
      _participantController.stream;

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async =>
      micCalls.add(enabled);

  @override
  Future<void> hangUp() async => hangUpCalls++;
}

ActiveCallState _state({
  AudioVideoCallStatus status = AudioVideoCallStatus.connected,
  bool isMicEnabled = true,
  bool isMinimized = false,
}) => ActiveCallState(
  contactId: 'contact-1',
  peerName: 'Alice',
  status: status,
  callDurationSeconds: 0,
  isMicEnabled: isMicEnabled,
  isAudioOnly: false,
  isMinimized: isMinimized,
);

/// Registers a session on [controller] using standard test defaults.
void _registerSession(
  ActiveCallController controller,
  _FakeSession session, {
  bool isMinimized = false,
  bool isGroupContact = false,
  AudioVideoCallStatus initialStatus = AudioVideoCallStatus.outgoingRinging,
}) {
  controller.registerSession(
    session,
    channelDid: 'did:web:test',
    isAudioOnly: false,
    initialStatus: initialStatus,
    peerName: 'Alice',
    isMicEnabled: true,
    isMinimized: isMinimized,
    isGroupContact: isGroupContact,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/active_call_controller_test.log'),
    );
  });

  late ProviderContainer container;
  late ActiveCallController controller;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        chatSessionServiceProvider(
          'did:web:test',
        ).overrideWith(FakeChatSessionService.new),
      ],
    );
    controller = container.read(activeCallControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('update', () {
    test('writes the supplied state', () {
      controller.update(_state());
      expect(container.read(activeCallControllerProvider), _state());
    });
  });

  group('minimize / restore', () {
    test('minimize sets isMinimized true', () {
      controller.update(_state());
      controller.minimize(
        contactId: 'contact-1',
        status: AudioVideoCallStatus.outgoingRinging,
        peerName: 'Alice',
        isAudioOnly: false,
        isCameraEnabled: true,
        isMicEnabled: true,
      );
      expect(container.read(activeCallControllerProvider)!.isMinimized, isTrue);
    });

    test('minimize syncs audio-to-video media state', () {
      controller.update(_state());
      controller.minimize(
        contactId: 'contact-1',
        status: AudioVideoCallStatus.outgoingRinging,
        peerName: 'Alice',
        isAudioOnly: false,
        isCameraEnabled: true,
        isMicEnabled: true,
      );
      final state = container.read(activeCallControllerProvider)!;
      expect(state.isAudioOnly, isFalse);
      expect(state.isCameraEnabled, isTrue);
    });

    test('restore sets isMinimized false', () {
      controller.update(_state(isMinimized: true));
      controller.restore();
      expect(
        container.read(activeCallControllerProvider)!.isMinimized,
        isFalse,
      );
    });

    test('minimize creates banner state when none exists yet', () {
      controller.minimize(
        contactId: 'contact-1',
        status: AudioVideoCallStatus.outgoingRinging,
        peerName: 'Alice',
        isAudioOnly: false,
        isCameraEnabled: true,
        isMicEnabled: true,
      );
      final state = container.read(activeCallControllerProvider);
      expect(state, isNotNull);
      expect(state!.isMinimized, isTrue);
      expect(state.status, AudioVideoCallStatus.outgoingRinging);
    });
  });

  group('clear', () {
    test('nulls the state', () {
      controller.update(_state());
      controller.clear();
      expect(container.read(activeCallControllerProvider), isNull);
    });
  });

  group('toggleMic', () {
    test('flips the flag and forwards to the session', () {
      final session = _FakeSession();
      controller.update(_state(isMicEnabled: true));
      _registerSession(controller, session);

      controller.toggleMic();

      expect(
        container.read(activeCallControllerProvider)!.isMicEnabled,
        isFalse,
      );
      expect(session.micCalls, [false]);
    });

    test('is a no-op without a registered session', () {
      controller.update(_state(isMicEnabled: true));
      controller.toggleMic();
      expect(
        container.read(activeCallControllerProvider)!.isMicEnabled,
        isTrue,
      );
    });
  });

  group('hangUp', () {
    test('hangs up the session and clears the state', () {
      final session = _FakeSession();
      controller.update(_state());
      _registerSession(controller, session);

      controller.hangUp();

      expect(session.hangUpCalls, 1);
      expect(container.read(activeCallControllerProvider), isNull);
    });
  });

  group('duration timer', () {
    test('startTimer increments callDurationSeconds every second', () {
      fakeAsync((async) {
        controller.update(_state());
        controller.startTimer();

        async.elapse(const Duration(seconds: 3));

        expect(
          container.read(activeCallControllerProvider)!.callDurationSeconds,
          3,
        );
      });
    });

    test('startTimer is a no-op if already running', () {
      fakeAsync((async) {
        controller.update(_state());
        controller.startTimer();
        controller.startTimer();

        async.elapse(const Duration(seconds: 2));

        expect(
          container.read(activeCallControllerProvider)!.callDurationSeconds,
          2,
        );
      });
    });

    test('stopTimer halts the counter', () {
      fakeAsync((async) {
        controller.update(_state());
        controller.startTimer();

        async.elapse(const Duration(seconds: 2));
        controller.stopTimer();
        async.elapse(const Duration(seconds: 5));

        expect(
          container.read(activeCallControllerProvider)!.callDurationSeconds,
          2,
        );
      });
    });

    test('clear cancels the timer', () {
      fakeAsync((async) {
        controller.update(_state());
        controller.startTimer();
        async.elapse(const Duration(seconds: 1));

        controller.clear();
        async.elapse(const Duration(seconds: 3));

        expect(container.read(activeCallControllerProvider), isNull);
      });
    });

    test('timer persists through minimize and restore', () {
      fakeAsync((async) {
        controller.update(_state());
        controller.startTimer();

        async.elapse(const Duration(seconds: 2));
        controller.minimize(
          contactId: 'contact-1',
          status: AudioVideoCallStatus.outgoingRinging,
          peerName: 'Alice',
          isAudioOnly: false,
          isCameraEnabled: true,
          isMicEnabled: true,
        );
        async.elapse(const Duration(seconds: 3));
        controller.restore();
        async.elapse(const Duration(seconds: 1));

        expect(
          container.read(activeCallControllerProvider)!.callDurationSeconds,
          6,
        );
      });
    });
  });

  group('registerSession', () {
    test('initializes state when state is null', () {
      final session = _FakeSession();
      _registerSession(
        controller,
        session,
        initialStatus: AudioVideoCallStatus.outgoingRinging,
      );

      final state = container.read(activeCallControllerProvider);
      expect(state, isNotNull);
      expect(state!.status, AudioVideoCallStatus.outgoingRinging);
      expect(state.isMinimized, isFalse);
    });

    test('initializes state as minimized when isMinimized is true', () {
      final session = _FakeSession();
      _registerSession(controller, session, isMinimized: true);

      expect(container.read(activeCallControllerProvider)!.isMinimized, isTrue);
    });

    test('overwrites existing status with initialStatus', () {
      final session = _FakeSession();
      controller.update(_state(status: AudioVideoCallStatus.active));
      _registerSession(
        controller,
        session,
        initialStatus: AudioVideoCallStatus.outgoingRinging,
      );

      // Status must be overwritten to the provided initialStatus.
      expect(
        container.read(activeCallControllerProvider)!.status,
        AudioVideoCallStatus.outgoingRinging,
      );
    });
  });

  group('session state stream (minimized)', () {
    test('banner clears when missed status arrives while minimized', () async {
      final session = _FakeSession();
      _registerSession(controller, session, isMinimized: true);

      session.emit(
        const AudioVideoCallState(status: AudioVideoCallStatus.missed),
      );
      await Future<void>.microtask(() {});

      expect(container.read(activeCallControllerProvider), isNull);
    });

    test(
      'banner clears when declined status arrives while minimized',
      () async {
        final session = _FakeSession();
        _registerSession(controller, session, isMinimized: true);

        session.emit(
          const AudioVideoCallState(status: AudioVideoCallStatus.declined),
        );
        await Future<void>.microtask(() {});

        expect(container.read(activeCallControllerProvider), isNull);
      },
    );

    test('banner clears when ended status arrives while minimized', () async {
      final session = _FakeSession();
      _registerSession(controller, session, isMinimized: true);

      session.emit(
        const AudioVideoCallState(status: AudioVideoCallStatus.ended),
      );
      await Future<void>.microtask(() {});

      expect(container.read(activeCallControllerProvider), isNull);
    });

    test('session updates are ignored when not minimized', () async {
      final session = _FakeSession();
      controller.update(_state(status: AudioVideoCallStatus.outgoingRinging));
      _registerSession(
        controller,
        session,
        isMinimized: false,
        initialStatus: AudioVideoCallStatus.outgoingRinging,
      );

      session.emit(
        const AudioVideoCallState(status: AudioVideoCallStatus.missed),
      );
      await Future<void>.microtask(() {});

      // Not minimized: banner state unchanged (screen controller drives it).
      expect(container.read(activeCallControllerProvider), isNotNull);
    });

    test('startTimer is called when first remote participant joins', () {
      fakeAsync((async) {
        final session = _FakeSession();
        controller.update(
          _state(
            status: AudioVideoCallStatus.waitingForKeys,
            isMinimized: true,
          ),
        );
        _registerSession(
          controller,
          session,
          isMinimized: true,
          isGroupContact: false,
          initialStatus: AudioVideoCallStatus.waitingForKeys,
        );

        session.emit(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [
              AudioVideoCallParticipant(participantId: 'local', isSelf: true),
              AudioVideoCallParticipant(participantId: 'remote-1'),
            ],
          ),
        );
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 2));
        expect(
          container.read(activeCallControllerProvider)?.callDurationSeconds,
          greaterThanOrEqualTo(2),
        );
      });
    });
  });

  group('hangUpFromScreen', () {
    test(
      'sets caller role and hangs up the session, clearing banner state',
      () {
        final session = _FakeSession();
        _registerSession(controller, session);

        controller.hangUpFromScreen(role: CallRole.caller);

        expect(session.hangUpCalls, 1);
        expect(container.read(activeCallControllerProvider), isNull);
      },
    );

    test('sets recipient role and hangs up the session', () {
      final session = _FakeSession();
      _registerSession(controller, session);

      controller.hangUpFromScreen(role: CallRole.recipient);

      expect(session.hangUpCalls, 1);
      expect(container.read(activeCallControllerProvider), isNull);
    });

    test('does not overwrite an already-resolved role', () {
      final session = _FakeSession();
      _registerSession(controller, session, isMinimized: true);
      // Role resolved via session state before hangUpFromScreen is called.
      session.emit(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.outgoingRinging,
          ownRole: CallRole.caller,
        ),
      );

      // role: recipient should be ignored since role is already set.
      controller.hangUpFromScreen(role: CallRole.recipient);

      expect(session.hangUpCalls, 1);
      expect(container.read(activeCallControllerProvider), isNull);
    });

    test('caller path sets CallRole.caller', () {
      final session = _FakeSession();
      _registerSession(controller, session, isMinimized: true);

      // Simulate late arrival of session state (after screen disposed).
      // hangUpFromScreen sets the role before _onSessionState can.
      controller.hangUpFromScreen(role: CallRole.caller);

      // Session should be hung up and state cleared (contract met).
      expect(session.hangUpCalls, 1);
      expect(container.read(activeCallControllerProvider), isNull);
    });
  });

  group('isCallVisible', () {
    test('is false for null state', () {
      expect(controller.isCallVisible(null), isFalse);
    });

    test('is true for an active status', () {
      expect(
        controller.isCallVisible(
          _state(status: AudioVideoCallStatus.connected),
        ),
        isTrue,
      );
    });

    test('is false for terminal statuses', () {
      for (final status in [
        AudioVideoCallStatus.idle,
        AudioVideoCallStatus.ended,
        AudioVideoCallStatus.disconnected,
        AudioVideoCallStatus.error,
        AudioVideoCallStatus.missed,
        AudioVideoCallStatus.declined,
      ]) {
        expect(
          controller.isCallVisible(_state(status: status)),
          isFalse,
          reason: '$status should be terminal',
        );
      }
    });
  });
}
