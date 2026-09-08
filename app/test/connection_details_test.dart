import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_connection_offers.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_groups.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

void main() {
  group('When approving a pending connection', () {
    final contact = FakeContacts.pendingContact;
    final channel = Channel(
      permanentChannelDid: contact.channelDid!,
      otherPartyPermanentChannelDid: contact.channelDid!,
      offerLink: contact.offerLink,
      contactCard: contact.card.toSdkContactCard(),
      seqNo: 0,
      type: ChannelType.individual,
      publishOfferDid: 'did:key:pending-offer',
      mediatorDid: contact.mediatorDid,
      status: ChannelStatus.waitingForApproval,
      isConnectionInitiator: true,
    );
    final offer = ConnectionOffer(
      offerName: 'Pending Offer',
      offerLink: contact.offerLink,
      mnemonic: 'pending-offer-mnemonic',
      publishOfferDid: 'did:key:pending-offer',
      mediatorDid: contact.mediatorDid,
      oobInvitationMessage: '{}',
      type: ConnectionOfferType.meetingPlaceInvitation,
      status: ConnectionOfferStatus.published,
      contactCard: FakeIdentities.primaryIdentity.card.toSdkContactCard(),
      ownedByMe: true,
      createdAt: DateTime(2025, 2, 1),
      offerDescription: 'Pending offer',
      transport: ChannelTransport.didcomm,
    );

    testWidgets(
      'it closes the details screen while approval is still in progress',
      (tester) async {
        final approvalCompleter = Completer<void>();
        final sdk = FakeMeetingPlaceSDK(
          channels: {contact.channelDid!: channel},
          connectionOffers: [offer],
          approveConnectionRequestCompleter: approvalCompleter,
        );

        await navigateToLocation(
          tester,
          '/contacts/${contact.id}/connection-details',
          identities: [FakeIdentities.primaryIdentity],
          contacts: [contact],
          meetingPlaceCoreSDK: sdk,
        );

        final l10n = await getL10n();
        await tester.tap(find.text(l10n.generalApprove));
        await tester.pumpAndSettle();

        expect(sdk.approveConnectionRequestCalls, [channel]);
        expect(find.text(l10n.connectionDetails), findsNothing);
        expect(find.byType(AlertDialog), findsNothing);

        approvalCompleter.complete();
        await tester.pumpAndSettle();
      },
    );

    group('and approval fails after the details screen closes', () {
      testWidgets('it shows the error in a snack bar', (tester) async {
        final approvalCompleter = Completer<void>();
        final sdk = FakeMeetingPlaceSDK(
          channels: {contact.channelDid!: channel},
          connectionOffers: [offer],
          approveConnectionRequestCompleter: approvalCompleter,
          approveConnectionRequestError: Exception('approval failed'),
        );

        await navigateToLocation(
          tester,
          '/contacts/${contact.id}/connection-details',
          identities: [FakeIdentities.primaryIdentity],
          contacts: [contact],
          meetingPlaceCoreSDK: sdk,
        );

        final l10n = await getL10n();
        await tester.tap(find.text(l10n.generalApprove));
        await tester.pumpAndSettle();
        approvalCompleter.complete();
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text(l10n.error('Exception: approval failed')),
          findsOneWidget,
        );
      });
    });

    testWidgets(
      'it persists the pending inauguration status without a success snack bar',
      (tester) async {
        final sdk = FakeMeetingPlaceSDK(
          channels: {contact.channelDid!: channel},
          connectionOffers: [offer],
        );

        await navigateToLocation(
          tester,
          '/contacts/${contact.id}/connection-details',
          identities: [FakeIdentities.primaryIdentity],
          contacts: [contact],
          meetingPlaceCoreSDK: sdk,
        );

        final l10n = await getL10n();
        await tester.tap(find.text(l10n.generalApprove));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsNothing);
        expect(find.text(l10n.connectionRequestInProgress), findsNothing);
        expect(sdk.approveConnectionRequestCalls, [channel]);

        await pushRoute(tester, '/contacts/${contact.id}/connection-details');

        expect(find.text(l10n.generalApprove), findsNothing);
      },
    );
  });

  group('When rejecting a pending connection', () {
    final contact = FakeContacts.pendingContact;
    final channel = Channel(
      permanentChannelDid: contact.channelDid!,
      otherPartyPermanentChannelDid: contact.channelDid!,
      offerLink: contact.offerLink,
      contactCard: contact.card.toSdkContactCard(),
      seqNo: 0,
      type: ChannelType.individual,
      publishOfferDid: 'did:key:pending-offer',
      mediatorDid: contact.mediatorDid,
      status: ChannelStatus.waitingForApproval,
      isConnectionInitiator: true,
    );
    final offer = ConnectionOffer(
      offerName: 'Pending Offer',
      offerLink: contact.offerLink,
      mnemonic: 'pending-offer-mnemonic',
      publishOfferDid: 'did:key:pending-offer',
      mediatorDid: contact.mediatorDid,
      oobInvitationMessage: '{}',
      type: ConnectionOfferType.meetingPlaceInvitation,
      status: ConnectionOfferStatus.published,
      contactCard: FakeIdentities.primaryIdentity.card.toSdkContactCard(),
      ownedByMe: true,
      createdAt: DateTime(2025, 2, 1),
      offerDescription: 'Pending offer',
      transport: ChannelTransport.didcomm,
    );

    testWidgets('it closes without showing a modal or success snack bar', (
      tester,
    ) async {
      await navigateToLocation(
        tester,
        '/contacts/${contact.id}/connection-details',
        identities: [FakeIdentities.primaryIdentity],
        contacts: [contact],
        meetingPlaceCoreSDK: FakeMeetingPlaceSDK(
          channels: {contact.channelDid!: channel},
          connectionOffers: [offer],
        ),
      );

      final l10n = await getL10n();
      await tester.tap(find.text(l10n.generalReject));
      await tester.pumpAndSettle();

      expect(find.text(l10n.connectionDetails), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text(l10n.connectionRequestRejected), findsNothing);
    });

    group('and deletion fails after the details screen closes', () {
      testWidgets('it shows the error in a snack bar', (tester) async {
        await navigateToLocation(
          tester,
          '/contacts/${contact.id}/connection-details',
          identities: [FakeIdentities.primaryIdentity],
          contacts: [contact],
          meetingPlaceCoreSDK: FakeMeetingPlaceSDK(
            channels: {contact.channelDid!: channel},
            connectionOffers: [offer],
            returnNullAfterOtherPartyChannelLookups: 1,
          ),
        );

        final l10n = await getL10n();
        await tester.tap(find.text(l10n.generalReject));
        await tester.pumpAndSettle();

        expect(find.text(l10n.connectionDetails), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(l10n.error('missingChannel')), findsOneWidget);
      });
    });
  });

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

    testWidgets('removed member disappears from the list after confirming', (
      tester,
    ) async {
      final coreSdk = buildCoreSdkWithGroup();

      await navigateToLocation(
        tester,
        '/contacts/${groupContact.id}/connection-details',
        identities: [FakeIdentities.primaryIdentity],
        contacts: [groupContact],
        meetingPlaceCoreSDK: coreSdk,
        meetingPlaceChatSDK: FakeChatSdk(),
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

      // Update the mock so that refreshGroup also returns a group without
      // Bob, consistent with the optimistic state already applied to the UI.
      final group = FakeGroups.approvedGroup();
      coreSdk.setMockGroup(
        group.copyWith(
          members: group.members
              .where((m) => m.did != FakeGroups.removableMemberDid)
              .toList(),
        ),
      );

      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      await tester.tap(find.text(l10n.removeMemberConfirm));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(FakeGroups.removableMemberFirstName),
        findsNothing,
      );
    });
  });
}
