import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';

import 'fakes/fake_contacts.dart';
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
      await contactsService.incrementMissedCallBadge(
        openContact.channelDid!,
        callId: 'call-open-1',
      );
      await tester.pumpAndSettle();
      expect(badgeOf(openContact.id), openBadgeBefore);

      // A different contact whose chat is not open: bump is applied.
      await contactsService.incrementMissedCallBadge(
        otherContact.channelDid!,
        callId: 'call-other-1',
      );
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), otherBadgeBefore + 1);
    },
  );

  testWidgets(
    'distinct calls each bump the badge, the same call is counted once, and '
    'opening the chat lets a later call count again',
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

      final channelDid = otherContact.channelDid!;
      final before = badgeOf(otherContact.id);

      // Same call observed twice (repeated terminal upsert): counted once.
      await contactsService.incrementMissedCallBadge(channelDid, callId: 'c1');
      await contactsService.incrementMissedCallBadge(channelDid, callId: 'c1');
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), before + 1);

      // A distinct call: counts again (badge accumulates).
      await contactsService.incrementMissedCallBadge(channelDid, callId: 'c2');
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), before + 2);

      // Opening the chat resets the badge and clears the per-call credit, so a
      // later call counts again from zero.
      await contactsService.resetContactBadgeCount(channelDid);
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), 0);

      await contactsService.incrementMissedCallBadge(channelDid, callId: 'c3');
      await tester.pumpAndSettle();
      expect(badgeOf(otherContact.id), 1);
    },
  );
}
