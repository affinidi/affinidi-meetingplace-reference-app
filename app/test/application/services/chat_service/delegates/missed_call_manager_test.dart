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

    test('reconcilePendingMissedCall does nothing when no pending marker is '
        'present', () async {
      final contactsService = FakeContactsService();
      final callItemManager = FakeCallChatItemManager();

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        onUpsertChatItem: (_) {},
      );

      final healed = await manager.reconcilePendingMissedCall();

      expect(healed, isFalse);
      expect(callItemManager.updateCallCount, 0);
    });

    test(
      'chat-open unmarked sweep heals stale items with no pending marker',
      () async {
        final contactsService = FakeContactsService();
        final staleItems = [
          incomingCallMessage(
            messageId: 'msg-unmarked-1',
            dateCreated: DateTime.now().toUtc().subtract(
              const Duration(minutes: 5),
            ),
          ),
          incomingCallMessage(
            messageId: 'msg-unmarked-2',
            dateCreated: DateTime.now().toUtc().subtract(
              const Duration(minutes: 1),
            ),
          ),
        ];
        final callItemManager = FakeCallChatItemManager(
          isStaleReturn: true,
          staleItemsReturn: staleItems,
        );

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          onUpsertChatItem: (_) {},
        );

        final healed = await manager.reconcilePendingMissedCall(
          sweepUnmarked: true,
        );

        expect(healed, isTrue);
        expect(callItemManager.updateCallCount, 2);
        expect(
          callItemManager.updatedMessageIds,
          containsAll(['msg-unmarked-1', 'msg-unmarked-2']),
        );
      },
    );

    test(
      'chat-open unmarked sweep still skips while a call is ringing',
      () async {
        final contactsService = FakeContactsService();
        final callItemManager = FakeCallChatItemManager(
          isStaleReturn: true,
          staleItemsReturn: [
            incomingCallMessage(
              messageId: 'msg-ringing-unmarked',
              dateCreated: DateTime.now().toUtc().subtract(
                const Duration(minutes: 1),
              ),
            ),
          ],
        );

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService, ringingDid: channelDid),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          onUpsertChatItem: (_) {},
        );

        final healed = await manager.reconcilePendingMissedCall(
          sweepUnmarked: true,
        );

        expect(healed, isFalse);
        expect(callItemManager.updateCallCount, 0);
      },
    );

    test('reconcilePendingMissedCall heals a stale item resolved before the '
        'persisted marker time and clears the marker', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'call-123',
      );
      final contactsService = FakeContactsService(contacts: [contact]);
      final callItemManager = FakeCallChatItemManager(
        isStaleReturn: true,
        resolveReturn: incomingCallMessage(
          messageId: 'msg-1',
          dateCreated: markerTime.subtract(const Duration(minutes: 5)),
        ),
      );

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        onUpsertChatItem: (_) {},
      );

      final healed = await manager.reconcilePendingMissedCall();

      expect(healed, isTrue);
      expect(callItemManager.updateCallCount, 1);
      expect(callItemManager.lastResolveBound, markerTime);
      expect(callItemManager.lastResolveCallId, 'call-123');
      expect(contactsService.clearPendingMissedCallCalls, [channelDid]);
    });

    test('reconcilePendingMissedCall clears an orphaned marker when the item '
        'is already settled in history', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'call-123',
      );
      final contactsService = FakeContactsService(contacts: [contact]);
      final callItemManager = FakeCallChatItemManager(
        isStaleReturn: false,
        resolveReturn: incomingCallMessage(
          messageId: 'msg-settled',
          dateCreated: markerTime.subtract(const Duration(minutes: 5)),
        ),
      );

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        onUpsertChatItem: (_) {},
      );

      final healed = await manager.reconcilePendingMissedCall();

      expect(healed, isFalse);
      expect(callItemManager.updateCallCount, 0);
      expect(contactsService.clearPendingMissedCallCalls, [channelDid]);
    });

    test(
      'reconcilePendingMissedCall keeps the marker when the call item has not '
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
          onUpsertChatItem: (_) {},
        );

        final healed = await manager.reconcilePendingMissedCall();

        expect(healed, isFalse);
        expect(callItemManager.updateCallCount, 0);
        expect(contactsService.clearPendingMissedCallCalls, isEmpty);
      },
    );

    test('reconcilePendingMissedCall skips healing while a call is ringing for '
        'the contact', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'call-123',
      );
      final contactsService = FakeContactsService(contacts: [contact]);
      final callItemManager = FakeCallChatItemManager(
        isStaleReturn: true,
        resolveReturn: incomingCallMessage(
          messageId: 'msg-ringing',
          dateCreated: markerTime.subtract(const Duration(seconds: 1)),
        ),
      );

      final manager = MissedCallManager(
        ref: _createTestRef(
          contactsService,
          ringingDid: channelDid,
          ringingCallId: 'call-123',
        ),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        onUpsertChatItem: (_) {},
      );

      final healed = await manager.reconcilePendingMissedCall();

      expect(healed, isFalse);
      expect(callItemManager.updateCallCount, 0);
    });

    test(
      'reconcilePendingMissedCall heals when the current ringing state is for '
      'the same contact but a different callId',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: 'cancelled-call-id',
        );
        final contactsService = FakeContactsService(contacts: [contact]);
        final callItemManager = FakeCallChatItemManager(
          isStaleReturn: true,
          resolveReturn: incomingCallMessage(
            messageId: 'msg-cancelled',
            dateCreated: markerTime.subtract(const Duration(seconds: 1)),
          ),
        );

        final manager = MissedCallManager(
          ref: _createTestRef(
            contactsService,
            ringingDid: channelDid,
            ringingCallId: 'new-live-call-id',
          ),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          onUpsertChatItem: (_) {},
        );

        final healed = await manager.reconcilePendingMissedCall();

        expect(healed, isTrue);
        expect(callItemManager.updateCallCount, 1);
        expect(contactsService.clearPendingMissedCallCalls, [channelDid]);
      },
    );

    test(
      'reconcilePendingMissedCall heals by direction and marker time even when '
      'the stored callId is the room-id fallback that never matches the item',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: '!room-id-fallback:synapse',
        );
        final contactsService = FakeContactsService(contacts: [contact]);
        final callItemManager = FakeCallChatItemManager(
          isStaleReturn: true,
          resolveReturn: incomingCallMessage(
            messageId: 'msg-healed',
            dateCreated: markerTime.subtract(const Duration(minutes: 5)),
          ),
        );

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          onUpsertChatItem: (_) {},
        );

        final healed = await manager.reconcilePendingMissedCall();

        expect(healed, isTrue);
        expect(callItemManager.updateCallCount, 1);
        expect(callItemManager.lastResolveBound, markerTime);
      },
    );

    test(
      'reconcilePendingMissedCall heals ALL stale incoming items before the '
      'marker, not just the marked one (back-to-back missed calls)',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final orphan = incomingCallMessage(
          messageId: 'msg-orphan',
          dateCreated: markerTime.subtract(const Duration(minutes: 2)),
        );
        final marked = incomingCallMessage(
          messageId: 'msg-marked',
          dateCreated: markerTime.subtract(const Duration(seconds: 10)),
        );
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: 'call-123',
        );
        final contactsService = FakeContactsService(contacts: [contact]);
        final callItemManager = FakeCallChatItemManager(
          isStaleReturn: true,
          resolveReturn: marked,
          staleItemsReturn: [orphan, marked],
        );

        final manager = MissedCallManager(
          ref: _createTestRef(contactsService),
          otherPartyPermanentChannelDid: channelDid,
          callChatItemManager: callItemManager,
          onUpsertChatItem: (_) {},
        );

        final healed = await manager.reconcilePendingMissedCall();

        expect(healed, isTrue);
        expect(callItemManager.updateCallCount, 2);
        expect(
          callItemManager.updatedMessageIds,
          containsAll(['msg-orphan', 'msg-marked']),
        );
        expect(contactsService.clearPendingMissedCallCalls, [channelDid]);
      },
    );

    test('reconcilePendingMissedCall excludes the currently-ringing call for '
        'the contact from the sweep', () async {
      final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
      final contact = FakeContacts.individualContact.copyWith(
        channelDid: channelDid,
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'missed-call-id',
      );
      final contactsService = FakeContactsService(contacts: [contact]);
      final callItemManager = FakeCallChatItemManager(
        isStaleReturn: true,
        resolveReturn: incomingCallMessage(
          messageId: 'msg-missed',
          dateCreated: markerTime.subtract(const Duration(seconds: 5)),
        ),
      );

      final manager = MissedCallManager(
        ref: _createTestRef(
          contactsService,
          ringingDid: channelDid,
          ringingCallId: 'new-live-call-id',
        ),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
        onUpsertChatItem: (_) {},
      );

      await manager.reconcilePendingMissedCall();

      expect(callItemManager.lastSweepExcludeCallId, 'new-live-call-id');
    });

    test(
      'healArrivedStaleCallItemIfPending heals a stale item created before the '
      'marker',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
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
          onUpsertChatItem: (_) {},
        );

        await manager.healArrivedStaleCallItemIfPending(message);

        expect(callItemManager.updateCallCount, 1);
      },
    );

    test(
      'healArrivedStaleCallItemIfPending skips a stale item created after the '
      'pending marker time',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
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
          onUpsertChatItem: (_) {},
        );

        await manager.healArrivedStaleCallItemIfPending(message);

        expect(callItemManager.updateCallCount, 0);
      },
    );

    test(
      'healArrivedStaleCallItemIfPending skips healing while a call is ringing '
      'for the contact',
      () async {
        final markerTime = DateTime(2026, 7, 9, 10, 30).toUtc();
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: channelDid,
          pendingMissedCallAt: markerTime,
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

      final message = incomingCallMessage(
        messageId: 'msg-not-stale',
        dateCreated: markerTime.subtract(const Duration(minutes: 5)),
      );

      final callItemManager = FakeCallChatItemManager(isStaleReturn: false);

      final manager = MissedCallManager(
        ref: _createTestRef(contactsService),
        otherPartyPermanentChannelDid: channelDid,
        callChatItemManager: callItemManager,
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
        onUpsertChatItem: (_) {},
      );

      await manager.healArrivedStaleCallItemIfPending(message);

      expect(callItemManager.updateCallCount, 0);
    });

    test('healArrivedStaleCallItemIfPending clears the marker after '
        'stream-based healing', () async {
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
        onUpsertChatItem: upsertCalls.add,
      );

      await manager.healArrivedStaleCallItemIfPending(message);

      expect(callItemManager.updateCallCount, 1);
      expect(upsertCalls, isEmpty);
      expect(contactsService.clearPendingMissedCallCalls, [channelDid]);
    });
  });
}

Ref _createTestRef(
  ContactsService contactsService, {
  String? ringingDid,
  String ringingCallId = 'ringing-call-id',
}) {
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
            callId: ringingCallId,
            callerPermanentChannelDid: ringingDid,
            otherPartyPermanentChannelDid: ringingDid,
            mediaType: CallMediaType.video,
            invitedAt: DateTime.now(),
          ),
        );
  }
  return container.read(Provider<Ref>((ref) => ref));
}
