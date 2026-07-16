import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

void main() {
  testWidgets(
    'missed-call badge bump is skipped for the chat the user is viewing '
    'but applied to other contacts',
    (tester) async {
      final openContact = FakeContacts.individualContact;
      final otherContact = FakeContacts.oobContact;

      await navigateToChat(
        tester,
        contactId: openContact.id,
        contacts: [openContact, otherContact],
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      final contactsService = container.read(contactsServiceProvider.notifier);
      await contactsService.ensureInitialized();
      await tester.pumpAndSettle();

      int badgeOf(String id) =>
          container
              .read(contactsServiceProvider)
              .getContactById(id)
              ?.badgeCount ??
          -1;

      final openBadgeBefore = badgeOf(openContact.id);
      final otherBadgeBefore = badgeOf(otherContact.id);

      // The chat the user is currently viewing: bump is suppressed.
      await contactsService.incrementMissedCallBadge(openContact.channelDid!);
      await tester.pumpAndSettle();
      expect(badgeOf(openContact.id), openBadgeBefore);

      // A different contact whose chat is not open: bump is applied.
      await contactsService.incrementMissedCallBadge(otherContact.channelDid!);
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), otherBadgeBefore + 1);
    },
  );

  testWidgets(
    'a call decline signal bumps the badge of the mapped contact when its '
    'chat is not open',
    (tester) async {
      final openContact = FakeContacts.individualContact;
      final otherContact = FakeContacts.oobContact;
      final sdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels);

      await navigateToChat(
        tester,
        contactId: openContact.id,
        contacts: [openContact, otherContact],
        meetingPlaceCoreSDK: sdk,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      final contactsService = container.read(contactsServiceProvider.notifier);
      await contactsService.ensureInitialized();
      await tester.pumpAndSettle();

      int badgeOf(String id) =>
          container
              .read(contactsServiceProvider)
              .getContactById(id)
              ?.badgeCount ??
          -1;

      final otherBadgeBefore = badgeOf(otherContact.id);

      // Declined outgoing call for a contact whose chat is not open: bumped.
      sdk.emitCallSignal(
        CallDeclineSignal(ownChannelDid: otherContact.channelDid!),
      );
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), otherBadgeBefore + 1);

      // Declined outgoing call for the contact currently being viewed: skipped.
      final openBadgeBefore = badgeOf(openContact.id);
      sdk.emitCallSignal(
        CallDeclineSignal(ownChannelDid: openContact.channelDid!),
      );
      await tester.pumpAndSettle();
      expect(badgeOf(openContact.id), openBadgeBefore);
    },
  );

  testWidgets(
    'repeated decline signals for the same unread episode bump the badge once '
    'and count again after the chat is opened',
    (tester) async {
      final openContact = FakeContacts.individualContact;
      final otherContact = FakeContacts.oobContact;
      final sdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels);

      await navigateToChat(
        tester,
        contactId: openContact.id,
        contacts: [openContact, otherContact],
        meetingPlaceCoreSDK: sdk,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      final contactsService = container.read(contactsServiceProvider.notifier);
      await contactsService.ensureInitialized();
      await tester.pumpAndSettle();

      int badgeOf(String id) =>
          container
              .read(contactsServiceProvider)
              .getContactById(id)
              ?.badgeCount ??
          -1;

      final before = badgeOf(otherContact.id);

      // Call glare: one missed call surfaces two decline signals on this
      // device. The badge must only rise by one, matching the single call item.
      sdk.emitCallSignal(
        CallDeclineSignal(ownChannelDid: otherContact.channelDid!),
      );
      sdk.emitCallSignal(
        CallDeclineSignal(ownChannelDid: otherContact.channelDid!),
      );
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), before + 1);

      // Opening the chat resets the badge and clears the episode credit, so a
      // later call counts again.
      await contactsService.resetContactBadgeCount(otherContact.channelDid!);
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), 0);

      sdk.emitCallSignal(
        CallDeclineSignal(ownChannelDid: otherContact.channelDid!),
      );
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), 1);
    },
  );
}
