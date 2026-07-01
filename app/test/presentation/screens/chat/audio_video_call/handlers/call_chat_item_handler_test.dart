import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/handlers/call_chat_item_handler.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_chat_item_rules.dart';

import '../../../../../mocks/fake_app_logger.dart';

void main() {
  group('CallChatItemHandler', () {
    group('endCallWrite', () {
      test('returns null before endCallChatItem is called', () {
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        final write = handler.endCallWrite;

        expect(write, isNull);
      });

      test(
        'returns in-flight Future after endCallChatItem is called',
        () async {
          final handler = CallChatItemHandler(
            resolveItemId: ({required bool isCaller}) async => 'msg-123',
            updateItem:
                (_, {required CallStatus status, Duration? duration}) async {},
            isDisposed: () => false,
            logger: FakeAppLogger(),
          );

          handler.endCallChatItem(
            outcome: CallEndOutcome.hungUp,
            isCaller: true,
            hasHadPeer: true,
            callDuration: const Duration(seconds: 30),
          );

          final write = handler.endCallWrite;

          expect(write, isNotNull);
          expect(write, isA<Future<void>>());
        },
      );

      test('captures the same Future on repeated access', () async {
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller}) async => 'msg-456',
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCallChatItem(
          outcome: CallEndOutcome.declined,
          isCaller: false,
          hasHadPeer: false,
          callDuration: const Duration(seconds: 0),
        );

        final write1 = handler.endCallWrite;
        final write2 = handler.endCallWrite;

        expect(write1, same(write2));
      });

      test('allows callers to await the write before cleanup', () async {
        var updateCallCount = 0;
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller}) async => 'msg-789',
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {
                updateCallCount++;
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCallChatItem(
          outcome: CallEndOutcome.hungUp,
          isCaller: true,
          hasHadPeer: true,
          callDuration: const Duration(seconds: 15),
        );

        final pendingWrite = handler.endCallWrite;
        expect(updateCallCount, isZero);

        await pendingWrite;

        expect(updateCallCount, equals(1));
      });
    });

    group('idempotency on endCallChatItem', () {
      test('second call to endCallChatItem is a no-op', () async {
        var updateCallCount = 0;
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller}) async => 'msg-abc',
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {
                updateCallCount++;
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCallChatItem(
          outcome: CallEndOutcome.hungUp,
          isCaller: true,
          hasHadPeer: true,
          callDuration: const Duration(seconds: 20),
        );
        await handler.endCallWrite;

        final firstCount = updateCallCount;

        handler.endCallChatItem(
          outcome: CallEndOutcome.declined,
          isCaller: false,
          hasHadPeer: false,
          callDuration: Duration.zero,
        );

        expect(updateCallCount, equals(firstCount));
      });

      test('callChatItemEnded flag prevents subsequent writes', () {
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller}) async => 'msg-def',
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCallChatItem(
          outcome: CallEndOutcome.hungUp,
          isCaller: true,
          hasHadPeer: true,
          callDuration: const Duration(seconds: 10),
        );

        expect(handler.callChatItemEnded, isTrue);

        handler.endCallChatItem(
          outcome: CallEndOutcome.declined,
          isCaller: false,
          hasHadPeer: false,
          callDuration: Duration.zero,
        );

        expect(handler.endCallWrite, isNotNull);
      });
    });
  });
}
