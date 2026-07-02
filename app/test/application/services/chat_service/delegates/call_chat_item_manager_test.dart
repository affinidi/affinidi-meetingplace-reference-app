import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../../fakes/fake_chat_sdk.dart';
import '../../../../mocks/mock_app_logger.dart';

void main() {
  group('CallChatItemManager.findStaleIncomingCallItemIds', () {
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

    test('returns incoming calling and ringing items', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'incoming-calling',
          isFromMe: false,
          status: CallStatus.calling,
        ),
        callMessage(
          messageId: 'incoming-ringing',
          isFromMe: false,
          status: CallStatus.ringing,
        ),
      ];

      final ids = await manager.findStaleIncomingCallItemIds(
        liveIncomingCall: false,
      );

      expect(ids, containsAll(['incoming-calling', 'incoming-ringing']));
    });

    test('excludes final and outgoing call items', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'incoming-ended',
          isFromMe: false,
          status: CallStatus.ended,
        ),
        callMessage(
          messageId: 'incoming-missed',
          isFromMe: false,
          status: CallStatus.missed,
        ),
        callMessage(
          messageId: 'outgoing-calling',
          isFromMe: true,
          status: CallStatus.calling,
        ),
      ];

      final ids = await manager.findStaleIncomingCallItemIds(
        liveIncomingCall: false,
      );

      expect(ids, isEmpty);
    });

    test('preserves the most recent stale item when a call is ringing '
        'live', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'older-incoming',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: DateTime(2026, 6, 29, 10),
        ),
        callMessage(
          messageId: 'newest-incoming',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: DateTime(2026, 6, 29, 11),
        ),
      ];

      final ids = await manager.findStaleIncomingCallItemIds(
        liveIncomingCall: true,
      );

      expect(ids, ['older-incoming']);
    });

    test('returns an empty list when there are no call items', () async {
      fakeChatSdk.sessionMessages = [];

      final ids = await manager.findStaleIncomingCallItemIds(
        liveIncomingCall: false,
      );

      expect(ids, isEmpty);
    });

    test('excludes items younger than olderThan duration', () async {
      final recentDate = DateTime.now().toUtc().subtract(
        const Duration(seconds: 5),
      );
      final oldDate = DateTime.now().toUtc().subtract(
        const Duration(seconds: 30),
      );
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'recent-stale',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: recentDate,
        ),
        callMessage(
          messageId: 'old-stale',
          isFromMe: false,
          status: CallStatus.calling,
          dateCreated: oldDate,
        ),
      ];

      final ids = await manager.findStaleIncomingCallItemIds(
        liveIncomingCall: false,
        olderThan: const Duration(seconds: 15),
      );

      expect(ids, ['old-stale']);
    });
  });

  group('CallChatItemManager.isStaleIncomingCall', () {
    const channelDid = 'did:peer:other-party';

    late CallChatItemManager manager;

    Message callMessage({required bool isFromMe, required CallStatus status}) =>
        Message(
          chatId: 'fake-chat-id',
          messageId: 'msg-id',
          value: '',
          dateCreated: DateTime.now(),
          status: ChatItemStatus.confirmed,
          isFromMe: isFromMe,
          senderDid: isFromMe ? 'me' : channelDid,
          attachments: [
            CallMetadata.buildAttachment(
              id: const Uuid().v4(),
              mediaType: CallMediaType.video,
              status: status,
            ),
          ],
        );

    setUp(() {
      manager = CallChatItemManager(
        ensureInitialized: () async {},
        getChatSdk: FakeChatSdk.new,
        logger: FakeAppLogger(),
      );
    });

    test('is true for incoming calling and ringing items', () {
      expect(
        manager.isStaleIncomingCall(
          callMessage(isFromMe: false, status: CallStatus.calling),
        ),
        isTrue,
      );
      expect(
        manager.isStaleIncomingCall(
          callMessage(isFromMe: false, status: CallStatus.ringing),
        ),
        isTrue,
      );
    });

    test('is false for outgoing or final call items', () {
      expect(
        manager.isStaleIncomingCall(
          callMessage(isFromMe: true, status: CallStatus.calling),
        ),
        isFalse,
      );
      expect(
        manager.isStaleIncomingCall(
          callMessage(isFromMe: false, status: CallStatus.missed),
        ),
        isFalse,
      );
      expect(
        manager.isStaleIncomingCall(
          callMessage(isFromMe: false, status: CallStatus.ended),
        ),
        isFalse,
      );
    });

    test('is false for a non-call message', () {
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

      expect(manager.isStaleIncomingCall(textMessage), isFalse);
    });
  });
}
