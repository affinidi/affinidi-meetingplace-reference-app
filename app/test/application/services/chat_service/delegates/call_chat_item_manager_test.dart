import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fakes/fake_chat_sdk.dart';
import '../../../../mocks/mock_app_logger.dart';

void main() {
  group('CallChatItemManager incoming call resolution', () {
    const channelDid = 'did:peer:other-party';

    late FakeChatSdk fakeChatSdk;
    late CallChatItemManager manager;

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
          id: const Uuid().v4(),
          mediaType: CallMediaType.video,
          status: status,
          callId: '',
        ),
      ],
    );

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => fakeChatSdk,
        logger: FakeAppLogger(),
      );
    });

    test('it waits for a late incoming item to resolve the messageId', () {
      fakeAsync((async) {
        fakeChatSdk.sessionMessages = [];

        String? resolved;
        unawaited(
          manager.resolveIncomingCallChatItemId().then((value) {
            resolved = value;
          }),
        );

        async.flushMicrotasks();
        fakeChatSdk.sessionMessages = [
          callMessage(
            messageId: 'late-incoming',
            isFromMe: false,
            status: CallStatus.calling,
          ),
        ];

        async.elapse(const Duration(milliseconds: 50));
        async.flushMicrotasks();

        expect(resolved, 'late-incoming');
      });
    });

    test(
      'it waits for a late incoming item before updating to missed call',
      () {
        fakeAsync((async) {
          fakeChatSdk.sessionMessages = [];

          unawaited(manager.markCallAsMissed());

          async.flushMicrotasks();
          fakeChatSdk.sessionMessages = [
            callMessage(
              messageId: 'late-incoming',
              isFromMe: false,
              status: CallStatus.calling,
            ),
          ];

          async.elapse(const Duration(milliseconds: 50));
          async.flushMicrotasks();

          expect(fakeChatSdk.updateMessageCalls, hasLength(1));
          expect(
            fakeChatSdk.updateMessageCalls.single.messageId,
            'late-incoming',
          );
          final call = CallMetadata.maybeOf(
            fakeChatSdk.updateMessageCalls.single.attachments.firstWhere(
              CallMetadata.isCall,
            ),
          );
          expect(call?.status, CallStatus.missed);
        });
      },
    );

    test('isStaleIncomingCall is true for incoming calling/ringing items', () {
      expect(
        manager.isStaleIncomingCall(
          callMessage(
            messageId: 'a',
            isFromMe: false,
            status: CallStatus.calling,
          ),
        ),
        isTrue,
      );
      expect(
        manager.isStaleIncomingCall(
          callMessage(
            messageId: 'b',
            isFromMe: false,
            status: CallStatus.ringing,
          ),
        ),
        isTrue,
      );
    });

    test('isStaleIncomingCall is false for outgoing or final items', () {
      expect(
        manager.isStaleIncomingCall(
          callMessage(
            messageId: 'a',
            isFromMe: true,
            status: CallStatus.calling,
          ),
        ),
        isFalse,
      );
      expect(
        manager.isStaleIncomingCall(
          callMessage(
            messageId: 'b',
            isFromMe: false,
            status: CallStatus.missed,
          ),
        ),
        isFalse,
      );
    });

    test('resolveStaleIncomingCallItemIdBefore returns the latest stale item '
        'at or before the cutoff', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'older-incoming',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: DateTime(2026, 6, 29, 10),
        ),
        callMessage(
          messageId: 'at-cutoff-incoming',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: cutoff,
        ),
      ];

      final id = await manager.resolveStaleIncomingCallItemIdBefore(cutoff);

      expect(id, 'at-cutoff-incoming');
    });

    test('resolveStaleIncomingCallItemIdBefore ignores items created after '
        'the cutoff so a newer ringing call is not marked missed', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'newer-ringing',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: DateTime(2026, 6, 29, 12),
        ),
      ];

      final id = await manager.resolveStaleIncomingCallItemIdBefore(cutoff);

      expect(id, isNull);
    });
  });

  group('CallChatItemManager.sendOutgoingCallMessage', () {
    late FakeChatSdk fakeChatSdk;
    late CallChatItemManager manager;

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => fakeChatSdk,
        logger: FakeAppLogger(),
      );
    });

    test(
      'onSent callback is called immediately when message sent successfully',
      () async {
        Message? sentMessage;
        final messageId = await manager.sendOutgoingCallMessage(
          mediaType: CallMediaType.audio,
          callId: 'test-call-id',
          onSent: (message) {
            sentMessage = message;
          },
        );

        expect(messageId, isNotNull);
        expect(sentMessage, isNotNull);
        expect(sentMessage!.messageId, messageId);
        expect(sentMessage!.isFromMe, isTrue);
      },
    );

    test('onSent callback receives message with call attachment', () async {
      Message? sentMessage;
      await manager.sendOutgoingCallMessage(
        mediaType: CallMediaType.video,
        callId: 'test-call-id-123',
        onSent: (message) {
          sentMessage = message;
        },
      );

      expect(sentMessage, isNotNull);
      expect(sentMessage!.attachments, isNotEmpty);
      final callMetadata = CallMetadata.maybeOf(sentMessage!.attachments.first);
      expect(callMetadata, isNotNull);
      expect(callMetadata!.mediaType, CallMediaType.video);
    });

    test('onSent callback is not called when SDK is unavailable', () async {
      final managerWithNullSdk = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => null,
        logger: FakeAppLogger(),
      );
      Message? sentMessage;
      final messageId = await managerWithNullSdk.sendOutgoingCallMessage(
        mediaType: CallMediaType.audio,
        onSent: (message) {
          sentMessage = message;
        },
      );

      expect(messageId, isNull);
      expect(sentMessage, isNull);
    });

    test('onSent callback is not called when send fails', () async {
      Message? sentMessage;
      fakeChatSdk.sendTextMessageFailuresRemaining = 1;

      await expectLater(
        manager.sendOutgoingCallMessage(
          mediaType: CallMediaType.audio,
          onSent: (message) {
            sentMessage = message;
          },
        ),
        completion(isNull),
      );

      expect(sentMessage, isNull);
    });

    test('onSent callback is optional', () async {
      final messageId = await manager.sendOutgoingCallMessage(
        mediaType: CallMediaType.audio,
        callId: 'test-call-id',
      );

      expect(messageId, isNotNull);
    });
  });
}
