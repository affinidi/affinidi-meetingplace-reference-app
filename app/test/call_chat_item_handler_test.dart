import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallState, CallRole;
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

    group('lifecycle', () {
      test('dispose cancels subscription', () async {
        handler = CallChatItemHandler(
          onInitiator: () async => 'id',
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem: (_, {required status, duration}) async {},
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
          logger: fakeLogger,
        );
        await mockSession.emitState(callerState);

        expect(callCount, 0);
      });
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
