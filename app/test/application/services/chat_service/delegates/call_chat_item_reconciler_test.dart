import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_manager.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_reconciler.dart';

import '../../../../fakes/fake_chat_sdk.dart';
import '../../../../mocks/mock_app_logger.dart';

void main() {
  group('CallChatItemReconciler', () {
    const channelDid = 'did:peer:other-party';

    late FakeChatSdk fakeChatSdk;
    late CallChatItemManager manager;
    late List<Message> upserted;
    late bool callLive;

    Message callMessage({
      required String messageId,
      required bool isFromMe,
      required CallStatus status,
      DateTime? dateCreated,
    }) => Message(
      chatId: 'fake-chat-id',
      messageId: messageId,
      value: '',
      dateCreated: dateCreated ?? DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: isFromMe,
      senderDid: isFromMe ? 'me' : channelDid,
      attachments: [
        CallMetadata.buildAttachment(
          mediaType: CallMediaType.video,
          status: status,
        ),
      ],
    );

    CallChatItemReconciler makeReconciler({Duration? ringTimeout}) =>
        CallChatItemReconciler(
          manager: manager,
          isCallLive: () => callLive,
          upsertItem: upserted.add,
          ringTimeout: ringTimeout,
        );

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => fakeChatSdk,
        logger: FakeAppLogger(),
      );
      upserted = [];
      callLive = false;
    });

    group('onSessionStart', () {
      test('marks all stale incoming items missed and upserts each', () async {
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'msg-1',
            isFromMe: false,
            status: CallStatus.calling,
          ),
          callMessage(
            messageId: 'msg-2',
            isFromMe: false,
            status: CallStatus.ringing,
          ),
        ];

        await makeReconciler().onSessionStart();

        expect(
          upserted.map((m) => m.messageId),
          containsAll(['msg-1', 'msg-2']),
        );
        for (final m in upserted) {
          final call = CallMetadata.maybeOf(m.attachments.first)!;
          expect(call.status, CallStatus.missed);
        }
      });

      test(
        'preserves the most recent item when a call is ringing live',
        () async {
          fakeChatSdk.sessionMessages = [
            callMessage(
              messageId: 'older',
              isFromMe: false,
              status: CallStatus.calling,
              dateCreated: DateTime(2026, 6, 29, 10),
            ),
            callMessage(
              messageId: 'newest',
              isFromMe: false,
              status: CallStatus.calling,
              dateCreated: DateTime(2026, 6, 29, 11),
            ),
          ];
          callLive = true;

          await makeReconciler().onSessionStart();

          expect(upserted.map((m) => m.messageId), ['older']);
          expect(upserted.map((m) => m.messageId), isNot(contains('newest')));
        },
      );

      test('does nothing when no stale items exist', () async {
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'ended',
            isFromMe: false,
            status: CallStatus.ended,
          ),
        ];

        await makeReconciler().onSessionStart();

        expect(upserted, isEmpty);
      });
    });

    group('onStreamItem', () {
      test('marks a stale incoming item missed and upserts it', () async {
        final incoming = callMessage(
          messageId: 'stream-msg',
          isFromMe: false,
          status: CallStatus.calling,
        );
        fakeChatSdk.sessionMessages = [incoming];

        await makeReconciler().onStreamItem(incoming);

        expect(upserted, hasLength(1));
        expect(upserted.first.messageId, 'stream-msg');
        final call = CallMetadata.maybeOf(upserted.first.attachments.first)!;
        expect(call.status, CallStatus.missed);
      });

      test('does nothing when the call is currently ringing live', () async {
        callLive = true;
        final incoming = callMessage(
          messageId: 'live-msg',
          isFromMe: false,
          status: CallStatus.calling,
        );

        await makeReconciler().onStreamItem(incoming);

        expect(upserted, isEmpty);
      });

      test('does nothing for a non-call message', () async {
        final textMessage = Message(
          chatId: 'fake-chat-id',
          messageId: 'text-id',
          value: 'hello',
          dateCreated: DateTime.now(),
          status: ChatItemStatus.confirmed,
          isFromMe: false,
          senderDid: channelDid,
          attachments: const [],
        );

        await makeReconciler().onStreamItem(textMessage);

        expect(upserted, isEmpty);
      });

      test('does nothing for an outgoing call message', () async {
        final outgoing = callMessage(
          messageId: 'outgoing-msg',
          isFromMe: true,
          status: CallStatus.calling,
        );

        await makeReconciler().onStreamItem(outgoing);

        expect(upserted, isEmpty);
      });

      test(
        'does nothing when the call item already has a final status',
        () async {
          final missed = callMessage(
            messageId: 'missed-msg',
            isFromMe: false,
            status: CallStatus.missed,
          );

          await makeReconciler().onStreamItem(missed);

          expect(upserted, isEmpty);
        },
      );
    });

    group('ringTimeout', () {
      test('onSessionStart skips items younger than ringTimeout', () async {
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'young',
            isFromMe: false,
            status: CallStatus.calling,
            dateCreated: DateTime.now().toUtc().subtract(
              const Duration(seconds: 20),
            ),
          ),
        ];

        await makeReconciler(
          ringTimeout: const Duration(seconds: 60),
        ).onSessionStart();

        expect(upserted, isEmpty);
      });

      test(
        'onSessionStart marks items older than ringTimeout as missed',
        () async {
          fakeChatSdk.sessionMessages = [
            callMessage(
              messageId: 'old',
              isFromMe: false,
              status: CallStatus.calling,
              dateCreated: DateTime.now().toUtc().subtract(
                const Duration(seconds: 90),
              ),
            ),
          ];

          await makeReconciler(
            ringTimeout: const Duration(seconds: 60),
          ).onSessionStart();

          expect(upserted, hasLength(1));
          expect(upserted.first.messageId, 'old');
        },
      );

      test('onStreamItem skips items younger than ringTimeout', () async {
        final young = callMessage(
          messageId: 'young-stream',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: DateTime.now().toUtc().subtract(
            const Duration(seconds: 20),
          ),
        );
        fakeChatSdk.sessionMessages = [young];

        await makeReconciler(
          ringTimeout: const Duration(seconds: 60),
        ).onStreamItem(young);

        expect(upserted, isEmpty);
      });

      test(
        'onStreamItem marks items older than ringTimeout as missed',
        () async {
          final old = callMessage(
            messageId: 'old-stream',
            isFromMe: false,
            status: CallStatus.calling,
            dateCreated: DateTime.now().toUtc().subtract(
              const Duration(seconds: 90),
            ),
          );
          fakeChatSdk.sessionMessages = [old];

          await makeReconciler(
            ringTimeout: const Duration(seconds: 60),
          ).onStreamItem(old);

          expect(upserted, hasLength(1));
          expect(upserted.first.messageId, 'old-stream');
        },
      );
    });
  });
}
