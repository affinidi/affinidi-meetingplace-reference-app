import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
