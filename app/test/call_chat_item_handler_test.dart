import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_log_entry.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/handlers/call_chat_item_handler.dart';

import 'mocks/mock_app_logger.dart';
import 'mocks/mock_audio_video_call_session.dart';

void main() {
  group('CallChatItemHandler', () {
    late MockAudioVideoCallSession mockSession;
    late FakeAppLogger fakeLogger;
    late CallChatItemHandler handler;

    const callerState = AudioVideoCallState(
      ownRole: CallRole.caller,
      callId: 'test-call-id',
    );
    const recipientState = AudioVideoCallState(ownRole: CallRole.recipient);

    setUp(() {
      mockSession = MockAudioVideoCallSession();
      fakeLogger = FakeAppLogger();
    });

    group('caller path', () {
      test('invokes callback and stores id when ownRole is caller', () async {
        const itemId = 'call-item-123';
        handler = CallChatItemHandler(
          onInitiator: (_) async => itemId,
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              null,
          updateItem: (_, {required status, duration, participation}) async {},
          isDisposed: () => false,
          logger: fakeLogger,
        );

        handler.attach(mockSession);
        await mockSession.emitState(callerState);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(handler.callChatItemId, itemId);
      });

      test('fires callback exactly once', () async {
        var callCount = 0;
        handler = CallChatItemHandler(
          onInitiator: (_) async {
            callCount++;
            return 'id';
          },
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              null,
          updateItem: (_, {required status, duration, participation}) async {},
          isDisposed: () => false,
          logger: fakeLogger,
        );

        handler.attach(mockSession);
        await mockSession.emitState(callerState);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await mockSession.emitState(callerState);

        expect(callCount, 1);
      });

      test('logs on emission', () async {
        final logMessages = <String>[];
        handler = CallChatItemHandler(
          onInitiator: (_) async => 'id',
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              null,
          updateItem: (_, {required status, duration, participation}) async {},
          isDisposed: () => false,
          logger: _LogCapture(logMessages),
        );

        handler.attach(mockSession);
        await mockSession.emitState(callerState);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          logMessages,
          contains('callChatItemHandler: caller, emitting call chat item'),
        );
      });
    });

    group('recipient path', () {
      test('does not invoke callback when ownRole is recipient', () async {
        var callCount = 0;
        handler = CallChatItemHandler(
          onInitiator: (_) async {
            callCount++;
            return 'id';
          },
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              null,
          updateItem: (_, {required status, duration, participation}) async {},
          isDisposed: () => false,
          logger: fakeLogger,
        );

        handler.attach(mockSession);
        await mockSession.emitState(recipientState);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(callCount, 0);
        expect(handler.callChatItemId, isNull);
      });

      test('logs joiner message and returns', () async {
        final logMessages = <String>[];
        handler = CallChatItemHandler(
          onInitiator: (_) async => 'id',
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              null,
          updateItem: (_, {required status, duration, participation}) async {},
          isDisposed: () => false,
          logger: _LogCapture(logMessages),
        );

        handler.attach(mockSession);
        await mockSession.emitState(recipientState);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(
          logMessages,
          contains(
            'callChatItemHandler: recipient, not emitting; '
            'caller item arrives over the wire',
          ),
        );
      });
    });

    group('role resolution', () {
      test('waits for ownRole before emitting', () async {
        var callCount = 0;
        handler = CallChatItemHandler(
          onInitiator: (_) async {
            callCount++;
            return 'id';
          },
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              null,
          updateItem: (_, {required status, duration, participation}) async {},
          isDisposed: () => false,
          logger: fakeLogger,
        );

        handler.attach(mockSession);
        await mockSession.emitState(AudioVideoCallState.initial);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(callCount, 0);

        await mockSession.emitState(callerState);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(callCount, 1);
      });
    });

    group('attach onDone', () {
      test(
        'logs warning when stream closes before ownRole is determined',
        () async {
          final warnings = <String>[];
          handler = CallChatItemHandler(
            onInitiator: (_) async => 'id',
            resolveItemId: ({required bool isCaller, String? callId}) async =>
                null,
            updateItem:
                (_, {required status, duration, participation}) async {},
            isDisposed: () => false,
            logger: _WarningCapture(warnings),
          );

          handler.attach(mockSession);
          mockSession.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 100));

          expect(
            warnings,
            contains(
              'attach: Session stream ended before ownRole was determined; '
              'outgoing call chat item will not be emitted',
            ),
          );
        },
      );

      test(
        'does not invoke onInitiator when stream closes before ownRole',
        () async {
          var callCount = 0;
          handler = CallChatItemHandler(
            onInitiator: (_) async {
              callCount++;
              return 'id';
            },
            resolveItemId: ({required bool isCaller, String? callId}) async =>
                null,
            updateItem:
                (_, {required status, duration, participation}) async {},
            isDisposed: () => false,
            logger: fakeLogger,
          );

          handler.attach(mockSession);
          mockSession.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 100));

          expect(callCount, 0);
          expect(handler.callChatItemId, isNull);
        },
      );
    });

    group('lifecycle', () {
      test('dispose cancels subscription', () async {
        handler = CallChatItemHandler(
          onInitiator: (_) async => 'id',
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              null,
          updateItem: (_, {required status, duration, participation}) async {},
          isDisposed: () => false,
          logger: fakeLogger,
        );

        handler.attach(mockSession);
        handler.dispose();

        var callCount = 0;
        handler = CallChatItemHandler(
          onInitiator: (_) async {
            callCount++;
            return 'id';
          },
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              null,
          updateItem: (_, {required status, duration, participation}) async {},
          isDisposed: () => false,
          logger: fakeLogger,
        );
        await mockSession.emitState(callerState);

        expect(callCount, 0);
      });
    });
  });

  group('in-progress transitions', () {
    late FakeAppLogger logger;
    late MockAudioVideoCallSession session;

    setUp(() {
      logger = FakeAppLogger();
      session = MockAudioVideoCallSession();
    });

    CallChatItemHandler makeHandler(
      List<({String messageId, CallStatus status})> calls,
    ) {
      return CallChatItemHandler(
        onInitiator: (_) async => 'msg-1',
        resolveItemId: ({required bool isCaller, String? callId}) async =>
            'msg-1',
        updateItem: (id, {required status, duration, participation}) async {
          calls.add((messageId: id, status: status));
        },
        isDisposed: () => false,
        logger: logger,
        isGroupCall: true,
      )..attach(session);
    }

    const peerParticipants = [
      AudioVideoCallParticipant(participantId: 'self', isSelf: true),
      AudioVideoCallParticipant(participantId: 'peer'),
    ];

    test('writes ringing when the outgoing call is ringing', () async {
      final calls = <({String messageId, CallStatus status})>[];
      makeHandler(calls);

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.outgoingRinging,
          ownRole: CallRole.caller,
          callId: 'call-1',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(calls.map((c) => c.status), contains(CallStatus.ringing));
    });

    test('writes inProgress once a peer joins', () async {
      final calls = <({String messageId, CallStatus status})>[];
      makeHandler(calls);

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.connected,
          ownRole: CallRole.caller,
          callId: 'call-1',
          participants: peerParticipants,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(calls.last.status, CallStatus.inProgress);
    });

    test('does not repeat a write for an unchanged status', () async {
      final calls = <({String messageId, CallStatus status})>[];
      makeHandler(calls);

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.outgoingRinging,
          ownRole: CallRole.caller,
          callId: 'call-1',
        ),
      );
      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.outgoingRinging,
          ownRole: CallRole.caller,
          callId: 'call-1',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(calls.where((c) => c.status == CallStatus.ringing), hasLength(1));
    });

    test('does not write an in-progress status once ended', () async {
      final calls = <({String messageId, CallStatus status})>[];
      makeHandler(calls);

      await session.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.ended),
      );
      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.outgoingRinging,
          ownRole: CallRole.caller,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      const inProgressStatuses = {
        CallStatus.calling,
        CallStatus.ringing,
        CallStatus.inProgress,
      };
      expect(
        calls.where((c) => inProgressStatuses.contains(c.status)),
        isEmpty,
      );
    });
  });

  group('terminal write', () {
    late FakeAppLogger logger;
    late MockAudioVideoCallSession session;

    setUp(() {
      logger = FakeAppLogger();
      session = MockAudioVideoCallSession();
    });

    CallChatItemHandler makeHandler(
      List<({String messageId, CallStatus status, Duration? duration})> calls, {
      bool isDisposed = false,
    }) {
      return CallChatItemHandler(
        onInitiator: (_) async => 'msg-1',
        resolveItemId: ({required bool isCaller, String? callId}) async =>
            'msg-1',
        updateItem: (id, {required status, duration, participation}) async {
          calls.add((messageId: id, status: status, duration: duration));
        },
        isDisposed: () => isDisposed,
        logger: logger,
      )..attach(session);
    }

    const peerParticipants = [
      AudioVideoCallParticipant(participantId: 'self', isSelf: true),
      AudioVideoCallParticipant(participantId: 'peer'),
    ];

    test(
      'caller hangup after a peer joined writes ended with duration',
      () async {
        final calls =
            <({String messageId, CallStatus status, Duration? duration})>[];
        makeHandler(calls);

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.connected,
            ownRole: CallRole.caller,
            participants: peerParticipants,
          ),
        );
        await session.emitState(
          const AudioVideoCallState(status: AudioVideoCallStatus.disconnected),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final ended = calls.where((c) => c.status == CallStatus.ended);
        expect(ended, hasLength(1));
        expect(ended.single.duration, isNotNull);
      },
    );

    test(
      'caller cancel before answer writes declined with no duration',
      () async {
        final calls =
            <({String messageId, CallStatus status, Duration? duration})>[];
        makeHandler(calls);

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.outgoingRinging,
            ownRole: CallRole.caller,
            callId: 'test-call-id',
          ),
        );
        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.disconnected,
            ownRole: CallRole.caller,
            callId: 'test-call-id',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final declined = calls.where((c) => c.status == CallStatus.declined);
        expect(declined, hasLength(1));
        expect(declined.single.duration, isNull);
      },
    );

    test('recipient missed writes missed', () async {
      final calls =
          <({String messageId, CallStatus status, Duration? duration})>[];
      makeHandler(calls);

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.missed,
          ownRole: CallRole.recipient,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(calls.single.status, CallStatus.missed);
    });

    test('is idempotent across ended status and endCall()', () async {
      final calls =
          <({String messageId, CallStatus status, Duration? duration})>[];
      final handler = makeHandler(calls);

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.disconnected,
          ownRole: CallRole.caller,
          callId: 'test-call-id',
        ),
      );
      handler.endCall();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(calls.where((c) => c.status == CallStatus.declined), hasLength(1));
    });

    test('endCall sets callChatItemEnded immediately', () {
      final calls =
          <({String messageId, CallStatus status, Duration? duration})>[];
      final handler = makeHandler(calls);

      handler.endCall(assumeRole: CallRole.caller);

      expect(handler.callChatItemEnded, isTrue);
    });

    test('endCall skips write when disposed', () async {
      final calls =
          <({String messageId, CallStatus status, Duration? duration})>[];
      final handler = makeHandler(calls, isDisposed: true);

      handler.endCall(assumeRole: CallRole.caller);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(calls, isEmpty);
    });
  });
}

/// Simple logger that captures messages for testing.
class _LogCapture implements AppLogger {
  _LogCapture(this.messages);

  final List<String> messages;

  @override
  void info(String message, {String name = ''}) => messages.add(message);

  @override
  void warning(String message, {String name = '', dynamic error}) {}

  @override
  void error(
    String message, {
    String name = '',
    dynamic error,
    StackTrace? stackTrace,
  }) {}

  @override
  void debug(String message, {String name = ''}) {}

  @override
  void clearLogs() {}

  @override
  String get logFilePath => '';

  @override
  Stream<AppLogEntry> get logStream => const Stream.empty();

  @override
  List<AppLogEntry> get logs => [];
}

/// Logger that captures only warning messages.
class _WarningCapture implements AppLogger {
  _WarningCapture(this.messages);

  final List<String> messages;

  @override
  void info(String message, {String name = ''}) {}

  @override
  void warning(String message, {String name = '', dynamic error}) =>
      messages.add(message);

  @override
  void error(
    String message, {
    String name = '',
    dynamic error,
    StackTrace? stackTrace,
  }) {}

  @override
  void debug(String message, {String name = ''}) {}

  @override
  void clearLogs() {}

  @override
  String get logFilePath => '';

  @override
  Stream<AppLogEntry> get logStream => const Stream.empty();

  @override
  List<AppLogEntry> get logs => [];
}
