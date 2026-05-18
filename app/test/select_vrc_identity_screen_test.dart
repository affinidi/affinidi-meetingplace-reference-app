import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_connectivity.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'utils/app.dart';

Future<void> _navigateToChat(
  WidgetTester tester, {
  FakeChatSdk? chatSdk,
}) async {
  await navigateToLocation(
    tester,
    '/contacts/individual-contact-id/chat',
    identities: [FakeIdentities.primaryIdentity],
    contacts: [FakeContacts.individualContact],
    meetingPlaceChatSDK: chatSdk ?? FakeChatSdk(),
    connectivity: FakeConnectivity(
      initialConnectivityToReturn: [ConnectivityResult.wifi],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final firstName = FakeContacts.individualContact.otherPartyCard!.firstName;

  group('SelectVrcIdentityScreen — initiator role', () {
    testWidgets('shows Select Persona title', (tester) async {
      final l10n = await getL10n();

      await _navigateToChat(tester);
      await tester.tap(find.text(l10n.generateVrc));
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectIdentityTitle), findsOneWidget);
    });

    testWidgets('shows instruction text with the contact name', (tester) async {
      final l10n = await getL10n();

      await _navigateToChat(tester);
      await tester.tap(find.text(l10n.generateVrc));
      await tester.pumpAndSettle();

      expect(
        find.text(l10n.selectIdentityToVerifyRelationshipWithName(firstName)),
        findsOneWidget,
      );
    });

    testWidgets('shows Start now confirm button', (tester) async {
      final l10n = await getL10n();

      await _navigateToChat(tester);
      await tester.tap(find.text(l10n.generateVrc));
      await tester.pumpAndSettle();

      // findsWidgets: button in bottom bar + previously tapped banner button
      // is no longer visible once the screen pushes, so exactly two Start now
      // texts should not be there — but the screen has one action button.
      expect(find.text(l10n.generateVrc), findsWidgets);
    });

    testWidgets('shows Cancel button', (tester) async {
      final l10n = await getL10n();

      await _navigateToChat(tester);
      await tester.tap(find.text(l10n.generateVrc));
      await tester.pumpAndSettle();

      expect(find.text(l10n.generalCancel), findsOneWidget);
    });

    testWidgets('shows the identity picker for the local user', (tester) async {
      final l10n = await getL10n();

      await _navigateToChat(tester);
      await tester.tap(find.text(l10n.generateVrc));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('vrc_identity_picker')), findsOneWidget);
    });
  });

  group('SelectVrcIdentityScreen — responder role', () {
    Future<void> navigateAndOpenResponderScreen(WidgetTester tester) async {
      final chatSdk = FakeChatSdk();
      await _navigateToChat(tester, chatSdk: chatSdk);

      // Simulate the other party requesting verification — banner hides and
      // the concierge item appears with its own Start now button.
      chatSdk.simulateVrcPermissionRequest(
        senderDid: FakeChannels.individualChannel.permanentChannelDid!,
        recipientDid: FakeIdentities.primaryIdentity.card.did,
      );
      await tester.pumpAndSettle();

      // Tap the concierge item's Start now button (responder path).
      await tester.tap(find.text((await getL10n()).generateVrc));
      await tester.pumpAndSettle();
    }

    testWidgets('shows Select Persona title', (tester) async {
      final l10n = await getL10n();

      await navigateAndOpenResponderScreen(tester);

      expect(find.text(l10n.selectIdentityTitle), findsOneWidget);
    });

    testWidgets("shows the initiator's identity label with their name", (
      tester,
    ) async {
      final l10n = await getL10n();

      await navigateAndOpenResponderScreen(tester);

      expect(find.text(l10n.nameSelectedIdentity(firstName)), findsOneWidget);
    });

    testWidgets('shows prompt to select identity to verify with contact', (
      tester,
    ) async {
      final l10n = await getL10n();

      await navigateAndOpenResponderScreen(tester);

      expect(
        find.text(l10n.selectIdentityToVerifyRelationshipPrompt(firstName)),
        findsOneWidget,
      );
    });

    testWidgets('shows Confirm button instead of Start now', (tester) async {
      final l10n = await getL10n();

      await navigateAndOpenResponderScreen(tester);

      expect(find.text(l10n.generalVerify), findsOneWidget);
      expect(find.text(l10n.generateVrc), findsNothing);
    });

    testWidgets('shows Cancel button', (tester) async {
      final l10n = await getL10n();

      await navigateAndOpenResponderScreen(tester);

      expect(find.text(l10n.generalCancel), findsOneWidget);
    });

    testWidgets('shows the identity picker for the local user', (tester) async {
      await navigateAndOpenResponderScreen(tester);

      expect(find.byKey(const ValueKey('vrc_identity_picker')), findsOneWidget);
    });

    testWidgets("shows the other party's contact card with their email", (
      tester,
    ) async {
      final otherPartyEmail =
          FakeContacts.individualContact.otherPartyCard!.email!;

      await navigateAndOpenResponderScreen(tester);

      expect(find.text(otherPartyEmail), findsOneWidget);
    });
  });
}
