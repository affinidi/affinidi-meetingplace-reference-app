import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/missed_call_manager.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:uuid/uuid.dart';

import '../../../../fakes/fake_call_chat_item_manager.dart';
import '../../../../fakes/fake_contacts.dart';
import '../../../../fakes/fake_contacts_service.dart';

void main() {
  group('MissedCallManager reconciliation', () {
    const channelDid = 'did:peer:other-party';

    Message incomingCallMessage({
      required String messageId,
      required DateTime dateCreated,
    }) => Message(
      chatId: 'chat-123',
      messageId: messageId,
      value: '',
      dateCreated: dateCreated,
      status: ChatItemStatus.confirmed,
      isFromMe: false,
      senderDid: channelDid,
      attachments: [
        CallMetadata.buildAttachment(
          id: const Uuid().v4(),
          mediaType: CallMediaType.video,
          status: CallStatus.calling,
          callId: 'call-123',
        ),
      ],
    );

    test(
      'replayPendingMissedCall does nothing when no marker exists',
      () async {
        final contactsService = FakeContactsService();
        final callItemManager = FakeCallChatItemManager();

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          getMessageById: (_) async => null,
          onUpsertChatItem: (_) {},
        );

        await manager.replayPendingMissedCall();

        expect(callItemManager.updateCallCount, 0);
      },
    );

    test(
      'healArrivedStaleCallItemIfPending updates stale item before marker time',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
        );
        final contactsService = FakeContactsService(contacts: [contact]);

        final itemTime = markerTime.subtract(const Duration(minutes: 5));
        final message = incomingCallMessage(
          messageId: 'msg-stale',
          dateCreated: itemTime,
        );

        final callItemManager = FakeCallChatItemManager(isStaleReturn: true);

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          getMessageById: (_) async => message,
          onUpsertChatItem: (_) {},
        );

        await manager.healArrivedStaleCallItemIfPending(message);

        expect(callItemManager.updateCallCount, 1);
      },
    );

    test(
      'healArrivedStaleCallItemIfPending ignores item created after marker',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
        );
        final contactsService = FakeContactsService(contacts: [contact]);

        final itemTime = markerTime.add(const Duration(minutes: 5));
        final message = incomingCallMessage(
          messageId: 'msg-newer',
          dateCreated: itemTime,
        );

        final callItemManager = FakeCallChatItemManager(isStaleReturn: true);

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          getMessageById: (_) async => message,
          onUpsertChatItem: (_) {},
        );

        await manager.healArrivedStaleCallItemIfPending(message);

        expect(callItemManager.updateCallCount, 0);
      },
    );

    test('healArrivedStaleCallItemIfPending ignores non-stale items', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
      );
      final contactsService = FakeContactsService(contacts: [contact]);

      final itemTime = markerTime.subtract(const Duration(minutes: 5));
      final message = incomingCallMessage(
        messageId: 'msg-not-stale',
        dateCreated: itemTime,
      );

      final callItemManager = FakeCallChatItemManager(isStaleReturn: false);

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        getMessageById: (_) async => message,
        onUpsertChatItem: (_) {},
      );

      await manager.healArrivedStaleCallItemIfPending(message);

      expect(callItemManager.updateCallCount, 0);
    });

    test('_healIncomingCallItemMissed clears marker even when getMessageById '
        'returns null', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
      );
      final contactsService = FakeContactsService(contacts: [contact]);
      final callItemManager = FakeCallChatItemManager(isStaleReturn: true);
      final upsertCalls = <ChatItem>[];

      final message = incomingCallMessage(
        messageId: 'msg-no-fetch',
        dateCreated: markerTime.subtract(const Duration(minutes: 1)),
      );

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        getMessageById: (_) async => null,
        onUpsertChatItem: upsertCalls.add,
      );

      await manager.healArrivedStaleCallItemIfPending(message);

      expect(callItemManager.updateCallCount, 1);
      expect(upsertCalls, isEmpty);
      expect(contactsService.clearPendingMissedCallCalls, [channelDid]);
    });
  });
}

Ref _createTestRef(ContactsService contactsService) {
  final container = ProviderContainer(
    overrides: [contactsServiceProvider.overrideWith(() => contactsService)],
  );
  return container.read(Provider<Ref>((ref) => ref));
}
