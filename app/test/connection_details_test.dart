import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_connection_offers.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_groups.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

void main() {
  group('Connection details — group remove member', () {
    final groupContact = FakeContacts.groupContact;

    FakeMeetingPlaceSDK buildCoreSdkWithGroup() => FakeMeetingPlaceSDK(
      channels: FakeChannels.allChannels,
      connectionOffers: [FakeConnectionOffers.groupOfferOwnedByMe],
    )..setMockGroup(FakeGroups.approvedGroup());

    testWidgets(
      '''tapping remove and confirming calls SDK removeMember with the member did''',
      (tester) async {
        final fakeChatSdk = FakeChatSdk();

        await navigateToLocation(
          tester,
          '/contacts/${groupContact.id}/connection-details',
          identities: [FakeIdentities.primaryIdentity],
          contacts: [groupContact],
          meetingPlaceCoreSDK: buildCoreSdkWithGroup(),
          meetingPlaceChatSDK: fakeChatSdk,
        );
        await tester.pumpAndSettle();

        final removeButton = find.descendant(
          of: find.ancestor(
            of: find.textContaining(FakeGroups.removableMemberFirstName),
            matching: find.byType(ListTile),
          ),
          matching: find.byIcon(Icons.person_remove_outlined),
        );
        expect(removeButton, findsOneWidget);

        await tester.ensureVisible(removeButton);
        await tester.pumpAndSettle();
        await tester.tap(removeButton);
        await tester.pumpAndSettle();

        final l10n = await getL10n();
        await tester.tap(find.text(l10n.removeMemberConfirm));
        await tester.pumpAndSettle();

        expect(fakeChatSdk.lastRemovedMemberDid, FakeGroups.removableMemberDid);
        expect(fakeChatSdk.removeMemberCallCount, 1);
      },
    );

    testWidgets('cancelling the dialog does not call SDK removeMember', (
      tester,
    ) async {
      final fakeChatSdk = FakeChatSdk();

      await navigateToLocation(
        tester,
        '/contacts/${groupContact.id}/connection-details',
        identities: [FakeIdentities.primaryIdentity],
        contacts: [groupContact],
        meetingPlaceCoreSDK: buildCoreSdkWithGroup(),
        meetingPlaceChatSDK: fakeChatSdk,
      );
      await tester.pumpAndSettle();

      final removeButton = find.descendant(
        of: find.ancestor(
          of: find.textContaining(FakeGroups.removableMemberFirstName),
          matching: find.byType(ListTile),
        ),
        matching: find.byIcon(Icons.person_remove_outlined),
      );
      await tester.ensureVisible(removeButton);
      await tester.pumpAndSettle();
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      await tester.tap(find.text(l10n.generalCancel));
      await tester.pumpAndSettle();

      expect(fakeChatSdk.removeMemberCallCount, 0);
    });

    testWidgets('does not show remove button for the group admin/owner', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        '/contacts/${groupContact.id}/connection-details',
        identities: [FakeIdentities.primaryIdentity],
        contacts: [groupContact],
        meetingPlaceCoreSDK: buildCoreSdkWithGroup(),
        meetingPlaceChatSDK: FakeChatSdk(),
      );
      await tester.pumpAndSettle();

      final adminRemoveButton = find.descendant(
        of: find.ancestor(
          of: find.textContaining(FakeGroups.adminMemberFirstName),
          matching: find.byType(ListTile),
        ),
        matching: find.byIcon(Icons.person_remove_outlined),
      );
      expect(adminRemoveButton, findsNothing);
    });
  });
}
