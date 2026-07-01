import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_log_entry.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/handlers/call_chat_item_handler.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_chat_item_rules.dart';

import 'mocks/mock_app_logger.dart';
import 'mocks/mock_audio_video_call_session.dart';

void main() {
  group('CallChatItemHandler', () {
    late MockAudioVideoCallSession mockSession;
    late FakeAppLogger fakeLogger;
    late CallChatItemHandler handler;

    const callerState = AudioVideoCallState(ownRole: CallRole.caller);
    const recipientState = AudioVideoCallState(ownRole: CallRole.recipient);

    setUp(() {
      mockSession = MockAudioVideoCallSession();
      fakeLogger = FakeAppLogger();
    });

    group('caller path', () {
      test('invokes callback and stores id when ownRole is caller', () async {
        const itemId = 'call-item-123';
        handler = CallChatItemHandler(
          onInitiator: () async => itemId,
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem: (_, {required status, duration}) async {},
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
          onInitiator: () async {
            callCount++;
            return 'id';
          },
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem: (_, {required status, duration}) async {},
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
          onInitiator: () async => 'id',
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem: (_, {required status, duration}) async {},
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
          onInitiator: () async {
            callCount++;
            return 'id';
          },
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem: (_, {required status, duration}) async {},
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
          onInitiator: () async => 'id',
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem: (_, {required status, duration}) async {},
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
          onInitiator: () async {
            callCount++;
            return 'id';
          },
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem: (_, {required status, duration}) async {},
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
            onInitiator: () async => 'id',
            resolveItemId: ({required bool isCaller}) async => null,
            updateItem: (_, {required status, duration}) async {},
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
            onInitiator: () async {
              callCount++;
              return 'id';
            },
            resolveItemId: ({required bool isCaller}) async => null,
            updateItem: (_, {required status, duration}) async {},
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
          onInitiator: () async => 'id',
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem: (_, {required status, duration}) async {},
          isDisposed: () => false,
          logger: fakeLogger,
        );

        handler.attach(mockSession);
        handler.dispose();

        var callCount = 0;
        handler = CallChatItemHandler(
          onInitiator: () async {
            callCount++;
            return 'id';
          },
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem: (_, {required status, duration}) async {},
          isDisposed: () => false,
          logger: fakeLogger,
        );
        await mockSession.emitState(callerState);

        expect(callCount, 0);
      });
    });
  });

  group('updateCallChatItemStatus', () {
    late FakeAppLogger logger;

    setUp(() {
      logger = FakeAppLogger();
    });

    CallChatItemHandler makeHandler({
      String? seedId,
      bool isDisposed = false,
      List<({String messageId, CallStatus status})>? calls,
    }) {
      final recorded = calls ?? [];
      final h = CallChatItemHandler(
        resolveItemId: ({required bool isCaller}) async => seedId,
        updateItem: (id, {required status, duration}) async {
          recorded.add((messageId: id, status: status));
        },
        isDisposed: () => isDisposed,
        logger: logger,
      );
      if (seedId != null) h.seedCallChatItemId(seedId);
      return h;
    }

    test('writes status when item id is available', () async {
      final calls = <({String messageId, CallStatus status})>[];
      final handler = makeHandler(seedId: 'msg-1', calls: calls);

      handler.updateCallChatItemStatus(CallStatus.ringing);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(calls, hasLength(1));
      expect(calls.single.status, CallStatus.ringing);
    });

    test('skips write when callChatItemEnded is true', () async {
      final calls = <({String messageId, CallStatus status})>[];
      final handler = makeHandler(seedId: 'msg-1', calls: calls);

      handler.endCallChatItem(
        outcome: CallEndOutcome.hungUp,
        isCaller: true,
        hasHadPeer: true,
        callDuration: const Duration(seconds: 30),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final countAfterEnd = calls.length;
      handler.updateCallChatItemStatus(CallStatus.ringing);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(calls.length, countAfterEnd);
    });

    test('skips write when isDisposed returns true', () async {
      final calls = <({String messageId, CallStatus status})>[];
      final handler = makeHandler(
        seedId: 'msg-1',
        isDisposed: true,
        calls: calls,
      );

      handler.updateCallChatItemStatus(CallStatus.inProgress);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(calls, isEmpty);
    });
  });

  group('endCallChatItem', () {
    late FakeAppLogger logger;

    setUp(() => logger = FakeAppLogger());

    CallChatItemHandler makeHandler({
      required List<({String messageId, CallStatus status, Duration? duration})>
      calls,
      String? seedId,
      bool isDisposed = false,
    }) {
      final h = CallChatItemHandler(
        resolveItemId: ({required bool isCaller}) async => seedId,
        updateItem: (id, {required status, duration}) async {
          calls.add((messageId: id, status: status, duration: duration));
        },
        isDisposed: () => isDisposed,
        logger: logger,
      );
      if (seedId != null) h.seedCallChatItemId(seedId);
      return h;
    }

    test('caller + hungUp + hasHadPeer writes ended with duration', () async {
      final calls =
          <({String messageId, CallStatus status, Duration? duration})>[];
      final handler = makeHandler(calls: calls, seedId: 'msg-1');

      handler.endCallChatItem(
        outcome: CallEndOutcome.hungUp,
        isCaller: true,
        hasHadPeer: true,
        callDuration: const Duration(seconds: 45),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(calls.single.status, CallStatus.ended);
      expect(calls.single.duration, const Duration(seconds: 45));
    });

    test('caller + declined writes declined with no duration', () async {
      final calls =
          <({String messageId, CallStatus status, Duration? duration})>[];
      final handler = makeHandler(calls: calls, seedId: 'msg-1');

      handler.endCallChatItem(
        outcome: CallEndOutcome.declined,
        isCaller: true,
        hasHadPeer: false,
        callDuration: Duration.zero,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(calls.single.status, CallStatus.declined);
      expect(calls.single.duration, isNull);
    });

    test('recipient + declined writes missed', () async {
      final calls =
          <({String messageId, CallStatus status, Duration? duration})>[];
      final handler = makeHandler(calls: calls, seedId: 'msg-1');

      handler.endCallChatItem(
        outcome: CallEndOutcome.declined,
        isCaller: false,
        hasHadPeer: false,
        callDuration: Duration.zero,
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(calls.single.status, CallStatus.missed);
    });

    test('is idempotent — second call produces no additional write', () async {
      final calls =
          <({String messageId, CallStatus status, Duration? duration})>[];
      final handler = makeHandler(calls: calls, seedId: 'msg-1');

      handler.endCallChatItem(
        outcome: CallEndOutcome.hungUp,
        isCaller: true,
        hasHadPeer: true,
        callDuration: const Duration(seconds: 10),
      );
      handler.endCallChatItem(
        outcome: CallEndOutcome.hungUp,
        isCaller: true,
        hasHadPeer: true,
        callDuration: const Duration(seconds: 10),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(calls, hasLength(1));
    });

    test('sets callChatItemEnded immediately (before async resolves)', () {
      final calls =
          <({String messageId, CallStatus status, Duration? duration})>[];
      final handler = makeHandler(calls: calls, seedId: 'msg-1');

      handler.endCallChatItem(
        outcome: CallEndOutcome.hungUp,
        isCaller: true,
        hasHadPeer: true,
        callDuration: Duration.zero,
      );

      expect(handler.callChatItemEnded, isTrue);
    });
  });

  group('seedCallChatItemId', () {
    test('sets the id and does not overwrite if called again', () {
      final logger = FakeAppLogger();
      final handler = CallChatItemHandler(
        resolveItemId: ({required bool isCaller}) async => 'from-service',
        updateItem: (_, {required status, duration}) async {},
        isDisposed: () => false,
        logger: logger,
      );

      handler.seedCallChatItemId('first');
      handler.seedCallChatItemId('second');

      expect(handler.callChatItemId, 'first');
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
