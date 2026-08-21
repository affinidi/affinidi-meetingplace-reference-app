import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:mpx_flutter_reference_app/application/services/chat_service/open_chat_registry.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/contacts_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';

import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_contacts_repository.dart';
import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';
import '../../../mocks/mock_app_logger.dart';

// =========================================================================
// ContactsService — marker preservation across contact writes
// =========================================================================

/// Builds a minimal ProviderContainer wired with a FakeContactsRepository and
/// FakeMeetingPlaceSDK so ContactsService can call
/// getChannelByOtherPartyPermanentDid() without hitting the real SDK.
ProviderContainer _makeContainer({
  required FakeContactsRepository repository,
  FakeMeetingPlaceSDK? sdk,
}) => ProviderContainer(
  overrides: [
    appLoggerProvider.overrideWithValue(FakeAppLogger()),
    environmentProvider.overrideWithValue(FakeEnvironment()),
    contactsRepositoryProvider.overrideWith((ref) async => repository),
    meetingPlaceSdkProvider.overrideWith(
      (ref) async => sdk ?? FakeMeetingPlaceSDK(),
    ),
  ],
);

sdk.Channel _individualChannelWithSeqNo(int seqNo) {
  final channel = FakeChannels.individualChannel;
  return sdk.Channel(
    id: channel.id,
    offerLink: channel.offerLink,
    publishOfferDid: channel.publishOfferDid,
    mediatorDid: channel.mediatorDid,
    status: channel.status,
    contactCard: channel.contactCard,
    type: channel.type,
    transport: channel.transport,
    isConnectionInitiator: channel.isConnectionInitiator,
    otherPartyContactCard: channel.otherPartyContactCard,
    outboundMessageId: channel.outboundMessageId,
    acceptOfferDid: channel.acceptOfferDid,
    permanentChannelDid: channel.permanentChannelDid,
    otherPartyPermanentChannelDid: channel.otherPartyPermanentChannelDid,
    notificationToken: channel.notificationToken,
    otherPartyNotificationToken: channel.otherPartyNotificationToken,
    messageSyncMarker: channel.messageSyncMarker,
    seqNo: seqNo,
    externalRef: channel.externalRef,
  );
}

// ------------------------------------------------------------------
// updateContactFromChannelActivity preserves pendingMissedCallAt
// ------------------------------------------------------------------

void main() {
  group('ContactsService marker preservation', () {
    test(
      'updateContactFromChannelActivity preserves pendingMissedCallAt from '
      'persisted storage when provider state has a stale null snapshot',
      () async {
        final channel = FakeChannels.individualChannel;
        final channelDid = channel.otherPartyPermanentChannelDid!;
        final markerTime = DateTime(2026, 7, 14, 13, 13, 13).toUtc();

        final persistedContact = Contact(
          id: FakeContacts.individualContact.id,
          channelDid: channelDid,
          channelDidSha256: FakeContacts.individualContact.channelDidSha256,
          offerLink: FakeContacts.individualContact.offerLink,
          card: FakeContacts.individualContact.card,
          dateAdded: FakeContacts.individualContact.dateAdded,
          type: FakeContacts.individualContact.type,
          status: FakeContacts.individualContact.status,
          mediatorDid: FakeContacts.individualContact.mediatorDid,
          origin: FakeContacts.individualContact.origin,
          category: FakeContacts.individualContact.category,
          pendingMissedCallAt: markerTime,
        );
        final repository = FakeContactsRepository(contacts: [persistedContact]);

        final sdk = FakeMeetingPlaceSDK(channels: {channelDid: channel});
        final container = _makeContainer(repository: repository, sdk: sdk);
        addTearDown(container.dispose);

        // Seed provider state with the stale snapshot (no marker)
        final service = container.read(contactsServiceProvider.notifier);
        final staleContact = persistedContact.copyWith(
          pendingMissedCallAt: null,
        );
        service.state = service.state.copyWith(contacts: [staleContact]);

        await service.updateContactFromChannelActivity(channel);

        final updated = repository.contacts.firstWhere(
          (c) => c.channelDid == channelDid,
        );
        expect(
          updated.pendingMissedCallAt,
          markerTime,
          reason:
              'marker must survive a channel-activity contact update that '
              'uses a stale in-memory snapshot',
        );
      },
    );

    // ------------------------------------------------------------------
    // resetContactBadgeCount preserves pendingMissedCallAt
    // ------------------------------------------------------------------

    test(
      'resetContactBadgeCount preserves pendingMissedCallAt from persisted '
      'storage when badge reset runs at chat open with a stale snapshot',
      () async {
        final channel = FakeChannels.individualChannel;
        final channelDid = channel.otherPartyPermanentChannelDid!;
        final markerTime = DateTime(2026, 7, 14, 13, 18, 47).toUtc();

        final persistedContact = Contact(
          id: FakeContacts.individualContact.id,
          channelDid: channelDid,
          channelDidSha256: FakeContacts.individualContact.channelDidSha256,
          offerLink: FakeContacts.individualContact.offerLink,
          card: FakeContacts.individualContact.card,
          dateAdded: FakeContacts.individualContact.dateAdded,
          type: FakeContacts.individualContact.type,
          status: FakeContacts.individualContact.status,
          mediatorDid: FakeContacts.individualContact.mediatorDid,
          origin: FakeContacts.individualContact.origin,
          category: FakeContacts.individualContact.category,
          pendingMissedCallAt: markerTime,
          badgeCount: 2,
          missedCallCount: 1,
        );
        final repository = FakeContactsRepository(contacts: [persistedContact]);

        final sdk = FakeMeetingPlaceSDK(channels: {channelDid: channel});
        final container = _makeContainer(repository: repository, sdk: sdk);
        addTearDown(container.dispose);

        // Seed provider state with stale snapshot: has badges but no marker
        final service = container.read(contactsServiceProvider.notifier);
        final staleContact = persistedContact.copyWith(
          pendingMissedCallAt: null,
        );
        service.state = service.state.copyWith(contacts: [staleContact]);

        await service.resetContactBadgeCount(channelDid);

        final updated = repository.contacts.firstWhere(
          (c) => c.channelDid == channelDid,
        );
        expect(
          updated.badgeCount,
          0,
          reason: 'badge reset must clear the unread count',
        );
        expect(
          updated.missedCallCount,
          0,
          reason: 'missed call count must be cleared together with badge',
        );
        expect(
          updated.pendingMissedCallAt,
          markerTime,
          reason:
              'marker must survive the chat-open badge reset so replay can '
              'still heal the call item',
        );
      },
    );

    // ------------------------------------------------------------------
    // updateContactSequenceNumber preserves pendingMissedCallAt
    // ------------------------------------------------------------------

    test(
      'updateContactSequenceNumber preserves pendingMissedCallAt when stream '
      'message processing updates the sequence number mid-replay',
      () async {
        final channel = FakeChannels.individualChannel;
        final channelDid = channel.otherPartyPermanentChannelDid!;
        final markerTime = DateTime(2026, 7, 14, 13, 20, 0).toUtc();

        final persistedContact = Contact(
          id: FakeContacts.individualContact.id,
          channelDid: channelDid,
          channelDidSha256: FakeContacts.individualContact.channelDidSha256,
          offerLink: FakeContacts.individualContact.offerLink,
          card: FakeContacts.individualContact.card,
          dateAdded: FakeContacts.individualContact.dateAdded,
          type: FakeContacts.individualContact.type,
          status: FakeContacts.individualContact.status,
          mediatorDid: FakeContacts.individualContact.mediatorDid,
          origin: FakeContacts.individualContact.origin,
          category: FakeContacts.individualContact.category,
          pendingMissedCallAt: markerTime,
          pendingMissedCallId: 'call-123',
          currentMessageSeqNo: 5,
        );
        final repository = FakeContactsRepository(contacts: [persistedContact]);

        final sdk = FakeMeetingPlaceSDK(channels: {channelDid: channel});
        final container = _makeContainer(repository: repository, sdk: sdk);
        addTearDown(container.dispose);

        final service = container.read(contactsServiceProvider.notifier);
        final staleContact = persistedContact.copyWith(
          pendingMissedCallAt: null,
        );
        service.state = service.state.copyWith(contacts: [staleContact]);

        await service.updateContactSequenceNumber(channelDid, 6);

        final updated = repository.contacts.firstWhere(
          (c) => c.channelDid == channelDid,
        );
        expect(updated.currentMessageSeqNo, 6);
        expect(
          updated.pendingMissedCallAt,
          markerTime,
          reason:
              'sequence number update must not overwrite the missed-call '
              'marker with a stale null from provider state',
        );
        expect(
          updated.pendingMissedCallId,
          'call-123',
          reason:
              'sequence number update must preserve the missed-call callId '
              'so reconciliation can find the exact call item',
        );
      },
    );

    test('unrelated stale contact writes preserve persisted missed-call badge '
        'state', () async {
      final channelDid = FakeContacts.individualContact.channelDid!;
      final oldKeepAlive = DateTime(2026, 7, 14, 10).toUtc();
      final newKeepAlive = DateTime(2026, 7, 14, 11).toUtc();

      final persistedContact = FakeContacts.individualContact.copyWith(
        badgeCount: 2,
        missedCallCount: 1,
        lastKeepAliveMessage: oldKeepAlive,
      );
      final repository = FakeContactsRepository(contacts: [persistedContact]);

      final container = _makeContainer(repository: repository);
      addTearDown(container.dispose);

      final service = container.read(contactsServiceProvider.notifier);
      final staleContact = persistedContact.copyWith(
        badgeCount: 0,
        missedCallCount: 0,
      );
      service.state = service.state.copyWith(contacts: [staleContact]);

      await service.updateContactLastKeepAliveMessage(channelDid, newKeepAlive);

      final updated = repository.contacts.firstWhere(
        (c) => c.channelDid == channelDid,
      );
      expect(updated.lastKeepAliveMessage, newKeepAlive);
      expect(
        updated.badgeCount,
        2,
        reason:
            'an unrelated contact write must not clobber a missed-call '
            'badge from persisted storage',
      );
      expect(
        updated.missedCallCount,
        1,
        reason: 'durable missed-call count must survive unrelated stale writes',
      );
    });

    test(
      'syncChannelReadSeqNo only uses channel activity observed while the chat '
      'was open',
      () async {
        final openChannel = _individualChannelWithSeqNo(3);
        final postCloseChannel = _individualChannelWithSeqNo(4);
        final channelDid = openChannel.otherPartyPermanentChannelDid!;

        final persistedContact = FakeContacts.individualContact.copyWith(
          currentMessageSeqNo: 0,
          badgeCount: 0,
          missedCallCount: 0,
        );
        final repository = FakeContactsRepository(contacts: [persistedContact]);

        final sdk = FakeMeetingPlaceSDK(
          channels: {channelDid: postCloseChannel},
        );
        final container = _makeContainer(repository: repository, sdk: sdk);
        addTearDown(container.dispose);

        final service = container.read(contactsServiceProvider.notifier);
        service.state = service.state.copyWith(contacts: [persistedContact]);

        container
            .read(openChatRegistryProvider.notifier)
            .markOpened(persistedContact.id);
        await service.updateContactFromChannelActivity(openChannel);
        container
            .read(openChatRegistryProvider.notifier)
            .markClosed(persistedContact.id);

        await service.syncChannelReadSeqNo(channelDid);

        final updated = repository.contacts.firstWhere(
          (c) => c.channelDid == channelDid,
        );
        expect(updated.currentMessageSeqNo, 3);
        expect(
          updated.badgeCount,
          0,
          reason:
              'a post-close seqNo must not be folded into the chat-open read '
              'snapshot',
        );
      },
    );

    test(
      'syncOpenChannelReadSeqNo marks an open-chat call activity as read',
      () async {
        final openChannel = _individualChannelWithSeqNo(3);
        final channelDid = openChannel.otherPartyPermanentChannelDid!;

        final persistedContact = FakeContacts.individualContact.copyWith(
          currentMessageSeqNo: 0,
          badgeCount: 0,
          missedCallCount: 0,
        );
        final repository = FakeContactsRepository(contacts: [persistedContact]);

        final sdk = FakeMeetingPlaceSDK(channels: {channelDid: openChannel});
        final container = _makeContainer(repository: repository, sdk: sdk);
        addTearDown(container.dispose);

        final service = container.read(contactsServiceProvider.notifier);
        service.state = service.state.copyWith(contacts: [persistedContact]);

        await service.syncOpenChannelReadSeqNo(channelDid);

        final updated = repository.contacts.firstWhere(
          (c) => c.channelDid == channelDid,
        );
        expect(updated.currentMessageSeqNo, 3);
        expect(updated.badgeCount, 0);
      },
    );

    test(
      'a contact created from a channel baselines its read seqNo to the '
      'channel seqNo, so pre-existing channel history is not counted as unread',
      () async {
        // A channel that already carries history at the moment the contact is
        // first materialised — mirrors a group channel created with a non-zero
        // startSeqNo at join time. (An individual channel is used to avoid the
        // group offer-name lookup; the baseline logic is channel-type
        // agnostic.)
        final channel = _individualChannelWithSeqNo(5);
        final channelDid = channel.otherPartyPermanentChannelDid!;

        final repository = FakeContactsRepository(contacts: const []);
        final container = _makeContainer(repository: repository);
        addTearDown(container.dispose);

        final service = container.read(contactsServiceProvider.notifier);

        // First activity materialises the contact (create branch).
        await service.updateContactFromChannelActivity(channel);

        final created = repository.contacts.firstWhere(
          (c) => c.channelDid == channelDid,
        );
        expect(
          created.currentMessageSeqNo,
          5,
          reason:
              'a freshly materialised contact must baseline its read position '
              'to the channel seqNo at creation',
        );

        // A later channel-activity recompute (chat closed) must not fold the
        // pre-existing history into the unread badge.
        await service.updateContactFromChannelActivity(channel);

        final recomputed = repository.contacts.firstWhere(
          (c) => c.channelDid == channelDid,
        );
        expect(
          recomputed.badgeCount,
          0,
          reason:
              'channel history present at contact creation must not inflate '
              'the unread badge',
        );
      },
    );

    test('a group contact created from a channel baselines its read seqNo, so '
        'the pre-join group history is not counted as unread', () async {
      // The real reported case: a group channel is created with a non-zero
      // seqNo (the group's history at join). Materialising the contact must
      // baseline the read position to it, otherwise the whole backlog
      // inflates the unread badge (observed 8/5 on device).
      final channel = FakeChannels.groupChannel; // seqNo: 3, group.
      final channelDid = channel.otherPartyPermanentChannelDid!;

      final repository = FakeContactsRepository(contacts: const []);
      final container = _makeContainer(repository: repository);
      addTearDown(container.dispose);

      final service = container.read(contactsServiceProvider.notifier);

      // First activity materialises the group contact (create branch).
      await service.updateContactFromChannelActivity(channel);

      final created = repository.contacts.firstWhere(
        (c) => c.channelDid == channelDid,
      );
      expect(
        created.currentMessageSeqNo,
        3,
        reason:
            'a freshly materialised group contact must baseline its read '
            'position to the channel seqNo (the group history at join)',
      );

      // A later channel-activity recompute (chat closed) must not fold the
      // pre-join group history into the unread badge.
      await service.updateContactFromChannelActivity(channel);

      final recomputed = repository.contacts.firstWhere(
        (c) => c.channelDid == channelDid,
      );
      expect(
        recomputed.badgeCount,
        0,
        reason:
            'group history present at contact creation must not inflate the '
            'unread badge',
      );
    });

    test('a never-opened group contact counts post-join messages as unread '
        'on top of missed calls', () async {
      // The device scenario: a fresh group (baseline seqNo 0) with one missed
      // call already counted, never opened on this device. Post-join inbound
      // messages then advance channel.seqNo. Each message must count as unread
      // — a never-opened group must not swallow live messages (the previous
      // behaviour left device 3 stuck at the missed-call count). Pre-join
      // history is already excluded because the contact was baselined to the
      // join seqNo at creation, not counted here.
      final groupContact = FakeContacts.groupContact.copyWith(
        currentMessageSeqNo: 0,
        missedCallCount: 1,
        badgeCount: 1,
        hasBeenOpened: false,
      );
      final channelDid = groupContact.channelDid!;

      final repository = FakeContactsRepository(contacts: [groupContact]);
      final container = _makeContainer(repository: repository);
      addTearDown(container.dispose);

      final service = container.read(contactsServiceProvider.notifier);
      service.state = service.state.copyWith(contacts: [groupContact]);

      final channel = FakeChannels.groupChannel;
      channel.seqNo = 3; // three post-join messages arrived.

      await service.updateContactFromChannelActivity(channel);

      final updated = repository.contacts.firstWhere(
        (c) => c.channelDid == channelDid,
      );
      expect(
        updated.badgeCount,
        4,
        reason:
            'a never-opened group must count post-join messages (3) as unread '
            'on top of the missed call (1)',
      );
      expect(
        updated.currentMessageSeqNo,
        0,
        reason:
            'a closed chat must not advance the read position, so unread '
            'messages remain counted until the chat is opened',
      );
    });

    test('a group badge reaches the same count whether or not the chat was '
        'ever opened — replays the full device event sequence', () async {
      // The reported divergence: across the real device sequence (missed call,
      // three texts, missed call) a previously-opened device and a
      // never-opened device must reach the SAME badge (5) — one per call, one
      // per message. The removed absorb workaround made a never-opened group
      // swallow every message (stuck at the missed-call count) while an opened
      // one counted them, so the two devices disagreed. A single per-recompute
      // unit test could not catch this: it only surfaces across the ordered
      // event stream.
      Future<int> replayFinalBadge({required bool hasBeenOpened}) async {
        final groupContact = FakeContacts.groupContact.copyWith(
          currentMessageSeqNo: 0,
          missedCallCount: 0,
          badgeCount: 0,
          hasBeenOpened: hasBeenOpened,
        );
        final channelDid = groupContact.channelDid!;
        final repository = FakeContactsRepository(contacts: [groupContact]);
        final container = _makeContainer(repository: repository);
        addTearDown(container.dispose);
        final service = container.read(contactsServiceProvider.notifier);
        service.state = service.state.copyWith(contacts: [groupContact]);

        Future<void> message(int seqNo) async {
          final channel = FakeChannels.groupChannel;
          channel.seqNo = seqNo; // one more inbound group message.
          await service.updateContactFromChannelActivity(channel);
        }

        // CALL 1 missed, then TEXT 1/2/3, then CALL 2 missed.
        await service.incrementMissedCallBadge(channelDid, callId: 'call-1');
        await message(1);
        await message(2);
        await message(3);
        await service.incrementMissedCallBadge(channelDid, callId: 'call-2');

        return repository.contacts
            .firstWhere((c) => c.channelDid == channelDid)
            .badgeCount;
      }

      final neverOpened = await replayFinalBadge(hasBeenOpened: false);
      final previouslyOpened = await replayFinalBadge(hasBeenOpened: true);

      expect(
        neverOpened,
        5,
        reason: 'never-opened group: two missed calls (2) + three messages (3)',
      );
      expect(
        previouslyOpened,
        5,
        reason: 'a previously-opened group must reach the same count',
      );
      expect(
        neverOpened,
        previouslyOpened,
        reason: 'the badge must not depend on whether the chat was opened',
      );
    });

    test('clearPendingMissedCall clears persisted marker state instead of '
        'preserving it back from storage', () async {
      final channelDid = FakeContacts.individualContact.channelDid!;
      final markerTime = DateTime(2026, 7, 14, 18, 27, 5).toUtc();

      final persistedContact = FakeContacts.individualContact.copyWith(
        pendingMissedCallAt: markerTime,
        pendingMissedCallId: 'call-123',
      );
      final repository = FakeContactsRepository(contacts: [persistedContact]);

      final container = _makeContainer(repository: repository);
      addTearDown(container.dispose);

      final service = container.read(contactsServiceProvider.notifier);

      await service.clearPendingMissedCall(channelDid);

      final updated = repository.contacts.firstWhere(
        (c) => c.channelDid == channelDid,
      );
      expect(
        updated.pendingMissedCallAt,
        isNull,
        reason:
            'an explicit clear must not be overwritten by the preservation '
            'merge',
      );
      expect(
        updated.pendingMissedCallId,
        isNull,
        reason: 'call-id marker must be cleared together with the timestamp',
      );
    });

    // =====================================================================
    // Missed-call badge credit recovery — the dedup-ordering (poison) fix and
    // the chat-open replay skip. Cross-layer recovery cases 1/3/4 live in
    // missed_call_manager_test.dart (the heal wiring).
    // =====================================================================

    test(
      'Case 2 — a chat-open replay of the owed credit is skipped, so opening '
      'the chat leaves no lingering count',
      () async {
        final channelDid = FakeContacts.individualContact.channelDid!;
        final contact = FakeContacts.individualContact.copyWith(
          badgeCount: 0,
          missedCallCount: 0,
        );
        final repository = FakeContactsRepository(contacts: [contact]);
        final container = _makeContainer(repository: repository);
        addTearDown(container.dispose);
        final service = container.read(contactsServiceProvider.notifier);
        service.state = service.state.copyWith(contacts: [contact]);
        container
            .read(openChatRegistryProvider.notifier)
            .markOpened(contact.id);

        int badge() => repository.contacts
            .firstWhere((c) => c.channelDid == channelDid)
            .badgeCount;

        // The heal replays the owed credit through incrementMissedCallBadge;
        // while the chat is open the badge was already zeroed on open, so the
        // replay must be skipped and add no lingering count.
        await service.incrementMissedCallBadge(channelDid, callId: 'miss-1');

        expect(
          badge(),
          0,
          reason:
              'a chat-open replay must be skipped: the user saw the call, the '
              'badge is already zeroed',
        );
      },
    );

    test(
      'poison fix — a badge bump whose write fails leaves the id uncredited, '
      'so a later replay credits exactly once and the success-path dedup holds',
      () async {
        final channelDid = FakeContacts.individualContact.channelDid!;
        final contact = FakeContacts.individualContact.copyWith(
          badgeCount: 0,
          missedCallCount: 0,
        );
        final repository = FakeContactsRepository(contacts: [contact]);
        final container = _makeContainer(repository: repository);
        addTearDown(container.dispose);
        final service = container.read(contactsServiceProvider.notifier);
        service.state = service.state.copyWith(contacts: [contact]);

        int badge() => repository.contacts
            .firstWhere((c) => c.channelDid == channelDid)
            .badgeCount;

        // Initial bump fails at the write.
        repository.failUpdateWhen = (_) => true;
        await expectLater(
          service.incrementMissedCallBadge(channelDid, callId: 'miss-1'),
          throwsA(isA<Exception>()),
        );
        expect(
          badge(),
          0,
          reason: 'a failed write must not increment the badge',
        );

        // Recovery replay: the write now succeeds and the credit lands exactly
        // once — the failed bump did NOT poison the dedup set (the id is
        // recorded only after the write succeeds).
        repository.failUpdateWhen = null;
        await service.incrementMissedCallBadge(channelDid, callId: 'miss-1');
        expect(
          badge(),
          1,
          reason: 'the replay must credit the previously-failed bump',
        );

        // Success-path dedup still holds: the same id does not double-count.
        await service.incrementMissedCallBadge(channelDid, callId: 'miss-1');
        expect(badge(), 1, reason: 'a credited id must not be counted twice');
      },
    );
  });

  group('ContactsService superseded-call marker', () {
    Contact contactWith({List<String> supersededCallIds = const []}) => Contact(
      id: FakeContacts.individualContact.id,
      channelDid: FakeChannels.individualChannel.otherPartyPermanentChannelDid,
      channelDidSha256: FakeContacts.individualContact.channelDidSha256,
      offerLink: FakeContacts.individualContact.offerLink,
      card: FakeContacts.individualContact.card,
      dateAdded: FakeContacts.individualContact.dateAdded,
      type: FakeContacts.individualContact.type,
      status: FakeContacts.individualContact.status,
      mediatorDid: FakeContacts.individualContact.mediatorDid,
      origin: FakeContacts.individualContact.origin,
      category: FakeContacts.individualContact.category,
      supersededCallIds: supersededCallIds,
    );

    test('addSupersededCallId persists ids durably, appends and dedups; '
        'getSupersededCallIds reads them back', () async {
      final channelDid =
          FakeChannels.individualChannel.otherPartyPermanentChannelDid!;
      final repository = FakeContactsRepository(contacts: [contactWith()]);
      final container = _makeContainer(repository: repository);
      addTearDown(container.dispose);
      final service = container.read(contactsServiceProvider.notifier);

      await service.addSupersededCallId(channelDid, 'call-a');
      await service.addSupersededCallId(channelDid, 'own-item');
      // Duplicate and empty are ignored.
      await service.addSupersededCallId(channelDid, 'call-a');
      await service.addSupersededCallId(channelDid, '');

      expect(await service.getSupersededCallIds(channelDid), {
        'call-a',
        'own-item',
      });
      expect(
        repository.contacts
            .firstWhere((c) => c.channelDid == channelDid)
            .supersededCallIds,
        ['call-a', 'own-item'],
      );
    });

    test('a stale channel-activity write does not drop the persisted '
        'superseded set', () async {
      final channel = FakeChannels.individualChannel;
      final channelDid = channel.otherPartyPermanentChannelDid!;
      final repository = FakeContactsRepository(
        contacts: [
          contactWith(supersededCallIds: ['call-a']),
        ],
      );
      final sdk = FakeMeetingPlaceSDK(channels: {channelDid: channel});
      final container = _makeContainer(repository: repository, sdk: sdk);
      addTearDown(container.dispose);

      // Seed provider state with a stale snapshot that has lost the set.
      final service = container.read(contactsServiceProvider.notifier);
      service.state = service.state.copyWith(contacts: [contactWith()]);

      await service.updateContactFromChannelActivity(channel);

      expect(
        repository.contacts
            .firstWhere((c) => c.channelDid == channelDid)
            .supersededCallIds,
        ['call-a'],
        reason:
            'the append-only superseded set must survive a contact update '
            'that uses a stale in-memory snapshot',
      );
    });

    test('a preservePendingMissedCallState:false write still unions the '
        'persisted superseded set (clearPendingMissedCall race)', () async {
      final channelDid =
          FakeChannels.individualChannel.otherPartyPermanentChannelDid!;
      // The durable set was concurrently extended to {call-a, call-b} after
      // the clear flow captured its older {call-a}-only snapshot.
      final repository = FakeContactsRepository(
        contacts: [
          contactWith(supersededCallIds: ['call-a', 'call-b']),
        ],
      );
      final container = _makeContainer(repository: repository);
      addTearDown(container.dispose);
      final service = container.read(contactsServiceProvider.notifier);

      // clearPendingMissedCall writes its stale {call-a} snapshot with
      // preservePendingMissedCallState: false — the union must still run.
      await service.updateContact(
        contactWith(supersededCallIds: ['call-a']),
        preservePendingMissedCallState: false,
      );

      expect(
        repository.contacts
            .firstWhere((c) => c.channelDid == channelDid)
            .supersededCallIds,
        containsAll(['call-a', 'call-b']),
        reason:
            'a write with preservePendingMissedCallState: false must still '
            'union the durable superseded set, or a concurrently-added id is '
            'lost after restart',
      );
    });
  });
}
