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
        });
      },
    );

    test('resolveStaleIncomingCallItemIdBefore returns a message created '
        'exactly at the cutoff', () async {
      final cutoff = DateTime(2026, 6, 29, 11);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'at-cutoff-incoming',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: cutoff,
        ),
      ];

      final id = await manager.resolveStaleIncomingCallItemIdBefore(cutoff);

      expect(id, 'at-cutoff-incoming');
    });

    test('resolveStaleIncomingCallItemIdBefore waits for a stale item that '
        'arrives during chat bootstrap', () async {
      final cutoff = DateTime(2026, 6, 29, 11);

      // The message is added before the resolution call, simulating it arriving
      // during bootstrap
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'bootstrapped-incoming',
          isFromMe: false,
          status: CallStatus.ringing,
          dateCreated: cutoff,
        ),
      ];

      final id = await manager.resolveStaleIncomingCallItemIdBefore(cutoff);

      expect(id, 'bootstrapped-incoming');
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

  group('updateCallChatItem return value for immediate UI refresh', () {
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
      'returns non-null updated Message when status changes successfully',
      () async {
        final messageId = await manager.sendOutgoingCallMessage(
          mediaType: CallMediaType.audio,
        );
        expect(messageId, isNotNull);

        // Manually add the message to sessionMessages so getMessageById can
        // find it
        final originalMessage = Message(
          chatId: 'fake-chat-id',
          messageId: messageId!,
          value: '',
          dateCreated: DateTime.now(),
          status: ChatItemStatus.sent,
          isFromMe: true,
          senderDid: 'fake-sender-did',
          attachments: [
            CallMetadata.buildAttachment(
              mediaType: CallMediaType.audio,
              status: CallStatus.calling,
              callId: 'test-call-id',
              durationMs: 0,
              id: 'call-attachment-id',
            ),
          ],
        );
        fakeChatSdk.sessionMessages = [originalMessage];

        final updated = await manager.updateCallChatItem(
          messageId,
          status: CallStatus.declined,
        );

        expect(
          updated,
          isNotNull,
          reason:
              'updateCallChatItem should return updated Message for immediate '
              'UI refresh instead of waiting for stream echo',
        );
        expect(updated!.messageId, messageId);
      },
    );

    test('returns null when message not found', () async {
      fakeChatSdk.sessionMessages = [];

      final updated = await manager.updateCallChatItem(
        'nonexistent-message-id',
        status: CallStatus.declined,
      );

      expect(
        updated,
        isNull,
        reason: 'updateCallChatItem should return null when message not found',
      );
    });

    test('returns null when SDK unavailable', () async {
      final managerWithNullSdk = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: () => null,
        logger: FakeAppLogger(),
      );

      final updated = await managerWithNullSdk.updateCallChatItem(
        'any-id',
        status: CallStatus.declined,
      );

      expect(
        updated,
        isNull,
        reason: 'updateCallChatItem should return null when SDK unavailable',
      );
    });
  });
}
