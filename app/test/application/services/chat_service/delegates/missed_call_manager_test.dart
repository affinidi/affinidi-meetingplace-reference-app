import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/missed_call_manager.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../fakes/fake_call_chat_item_manager.dart';
import '../../../../fakes/fake_contacts.dart';
import '../../../../fakes/fake_contacts_service.dart';
import '../../../../mocks/mock_app_logger.dart';

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

    test('replayPendingMissedCall does nothing when no pending marker is '
        'present', () async {
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
    });

    test('replayPendingMissedCall heals all stale items resolved before the '
        'persisted marker time', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'call-123',
      );
      final contactsService = FakeContactsService();
      final callItemManager = FakeCallChatItemManager(
        resolveIdsReturn: ['msg-1', 'msg-2'],
      );
      contactsService.setContacts([contact]);

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        getMessageById: (_) async => null,
        onUpsertChatItem: (_) {},
      );

      await manager.replayPendingMissedCall();

      expect(callItemManager.updateCallCount, 2);
      expect(callItemManager.lastResolvedCallId, 'call-123');
    });

    test('replayPendingMissedCall clears the marker when it heals during '
        'the initial replay pass', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'call-123',
      );
      final contactsService = FakeContactsService(contacts: [contact]);
      final callItemManager = FakeCallChatItemManager(
        resolveIdsReturn: ['msg-missed'],
      );

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        getMessageById: (_) async => null,
        onUpsertChatItem: (_) {},
      );

      await manager.replayPendingMissedCall();

      expect(callItemManager.updateCallCount, 1);
      expect(contactsService.clearPendingMissedCallCalls, [channelDid]);
    });

    test(
      'replayPendingMissedCall skips healing while a call is ringing for the '
      'contact',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: 'call-123',
        );
        final contactsService = FakeContactsService(contacts: [contact]);
        final callItemManager = FakeCallChatItemManager(
          resolveIdsReturn: ['msg-ringing'],
        );

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService, ringingDid: channelDid),
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
      'replayPendingMissedCall keeps an old marker when the call item has not '
      'synced yet',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: 'call-123',
        );
        final contactsService = FakeContactsService(contacts: [contact]);
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
        expect(contactsService.clearPendingMissedCallCalls, isEmpty);
      },
    );

    test(
      'healArrivedStaleCallItemIfPending heals a stale item created before the '
      'marker',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: 'call-123',
        );
        final contactsService = FakeContactsService(contacts: [contact]);

        final message = incomingCallMessage(
          messageId: 'msg-stale',
          dateCreated: markerTime.subtract(const Duration(minutes: 5)),
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
        expect(contactsService.clearPendingMissedCallCalls, [channelDid]);
      },
    );

    test('healArrivedStaleCallItemIfPending skips a stale item when its callId '
        'does not match the pending marker', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'call-other',
      );
      final contactsService = FakeContactsService(contacts: [contact]);

      final message = incomingCallMessage(
        messageId: 'msg-skewed',
        dateCreated: markerTime.add(const Duration(seconds: 5)),
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
    });

    test(
      'healArrivedStaleCallItemIfPending skips healing while a call is ringing '
      'for the contact',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: 'call-123',
        );
        final contactsService = FakeContactsService(contacts: [contact]);

        final message = incomingCallMessage(
          messageId: 'msg-active-ring',
          dateCreated: markerTime.subtract(const Duration(seconds: 1)),
        );

        final callItemManager = FakeCallChatItemManager(isStaleReturn: true);

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService, ringingDid: channelDid),
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
        pendingMissedCallId: 'call-123',
      );
      final contactsService = FakeContactsService(contacts: [contact]);

      final message = incomingCallMessage(
        messageId: 'msg-not-stale',
        dateCreated: markerTime.subtract(const Duration(minutes: 5)),
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

    test('healArrivedStaleCallItemIfPending does NOT heal a stale item when no '
        'pendingMissedCallAt marker is set — protects a live call whose item '
        'arrives before the ring signal sets incomingCallProvider', () async {
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
      );
      final contactsService = FakeContactsService(contacts: [contact]);

      final message = incomingCallMessage(
        messageId: 'msg-live-call-no-marker',
        dateCreated: DateTime.now().toUtc(),
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
    });

    test('_healIncomingCallItemMissed clears the marker during '
        'stream-based healing', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'call-123',
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

    test('reconcilePendingMissedCall clears the marker when the stale item is '
        'available immediately', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'call-123',
      );
      final contactsService = FakeContactsService(contacts: [contact]);
      final callItemManager = FakeCallChatItemManager(
        resolveIdsReturn: ['msg-now'],
      );

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        getMessageById: (_) async => null,
        onUpsertChatItem: (_) {},
      );

      final healed = await manager.reconcilePendingMissedCall();

      expect(healed, isTrue);
      expect(callItemManager.updateCallCount, 1);
      expect(contactsService.clearPendingMissedCallCalls, [channelDid]);
    });

    test(
      'containment fix: _healStaleIncomingCallItemsByCallId heals only the '
      'newest matching item, not older stale items sharing the same roomId',
      () async {
        // Two stale items share the same roomId prefix (e.g. two consecutive
        // missed calls from the same contact while offline). The marker for the
        // second call should heal only msg-2, not msg-1.
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: 'call-456',
        );
        final contactsService = FakeContactsService(contacts: [contact]);
        final callItemManager = FakeCallChatItemManager(
          resolveIdsReturn: ['msg-1', 'msg-2'],
        );

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          getMessageById: (_) async => null,
          onUpsertChatItem: (_) {},
        );

        await manager.replayPendingMissedCall();

        expect(
          callItemManager.updateCallCount,
          1,
          reason: 'only the newest item should be healed',
        );
        expect(
          callItemManager.lastHealedMessageId,
          'msg-2',
          reason: 'msg-2 is the newest match and should be the one healed',
        );
      },
    );

    test(
      'crash-recovery: replayPendingMissedCall heals via activeIncomingCallId '
      'when pendingMissedCallId is not set',
      () async {
        // Banner was showing (activeIncomingCallId set) but app crashed before
        // _markCallAsMissed() ran (no pendingMissedCallId).
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          activeIncomingCallId: 'call-crash',
        );
        final contactsService = FakeContactsService(contacts: [contact]);
        final callItemManager = FakeCallChatItemManager(
          resolveIdsReturn: ['msg-orphan'],
        );

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          getMessageById: (_) async => null,
          onUpsertChatItem: (_) {},
        );

        await manager.replayPendingMissedCall();

        expect(callItemManager.updateCallCount, 1);
        expect(
          contactsService.setPendingMissedCallIds,
          contains('call-crash'),
          reason: 'crash-recovery must promote activeIncomingCallId to marker',
        );
        expect(
          contactsService.clearPendingMissedCallCalls,
          contains(channelDid),
          reason: 'marker must be cleared after successful heal',
        );
      },
    );

    test('crash-recovery: skipped when call is still ringing', () async {
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        activeIncomingCallId: 'call-live',
      );
      final contactsService = FakeContactsService(contacts: [contact]);
      final callItemManager = FakeCallChatItemManager(
        resolveIdsReturn: ['msg-live'],
      );

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService, ringingDid: channelDid),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        getMessageById: (_) async => null,
        onUpsertChatItem: (_) {},
      );

      await manager.replayPendingMissedCall();

      expect(callItemManager.updateCallCount, 0);
    });
  });
}

Ref _createTestRef(ContactsService contactsService, {String? ringingDid}) {
  final container = ProviderContainer(
    overrides: [
      contactsServiceProvider.overrideWith(() => contactsService),
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
    ],
  );
  if (ringingDid != null) {
    container
        .read(incomingCallProvider.notifier)
        .set(
          IncomingAudioVideoCallEvent(
            callId: 'call-123',
            callerPermanentChannelDid: ringingDid,
            otherPartyPermanentChannelDid: ringingDid,
            mediaType: CallMediaType.video,
          ),
        );
  }
  return container.read(Provider<Ref>((ref) => ref));
}
