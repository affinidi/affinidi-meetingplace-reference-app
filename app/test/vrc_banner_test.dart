import 'package:connectivity_plus/connectivity_plus.dart';
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
  group('VrcBanner', () {
    testWidgets('shows the VRC prompt when no VRC exchange has occurred', (
      tester,
    ) async {
      final l10n = await getL10n();

      await _navigateToChat(tester);

      expect(
        find.text(
          l10n.verifyRelationshipPrompt(
            FakeContacts.individualContact.otherPartyCard!.firstName,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows Start now and Do later buttons', (tester) async {
      final l10n = await getL10n();

      await _navigateToChat(tester);

      expect(find.text(l10n.generateVrc), findsOneWidget);
      expect(find.text(l10n.doLater), findsOneWidget);
    });
  });

  group('VrcBanner visibility', () {
    testWidgets('hides after Do later is tapped', (tester) async {
      final l10n = await getL10n();
      final firstName =
          FakeContacts.individualContact.otherPartyCard!.firstName;

      await _navigateToChat(tester);
      expect(
        find.text(l10n.verifyRelationshipPrompt(firstName)),
        findsOneWidget,
      );

      await tester.tap(find.text(l10n.doLater));
      await tester.pumpAndSettle();

      expect(find.text(l10n.verifyRelationshipPrompt(firstName)), findsNothing);
    });

    testWidgets('hides when a VRC request arrives from the contact', (
      tester,
    ) async {
      final l10n = await getL10n();
      final chatSdk = FakeChatSdk();
      final firstName =
          FakeContacts.individualContact.otherPartyCard!.firstName;

      await _navigateToChat(tester, chatSdk: chatSdk);
      expect(
        find.text(l10n.verifyRelationshipPrompt(firstName)),
        findsOneWidget,
      );

      chatSdk.simulateVrcPermissionRequest(
        senderDid: FakeChannels.individualChannel.permanentChannelDid!,
        recipientDid: FakeIdentities.primaryIdentity.card.did,
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.verifyRelationshipPrompt(firstName)), findsNothing);
      expect(find.text(l10n.vrcVerifyPrompt(firstName)), findsOneWidget);
    });
  });

  group('SelectVrcIdentityScreen', () {
    testWidgets('opens with Select Persona title when Start now is tapped', (
      tester,
    ) async {
      final l10n = await getL10n();

      await _navigateToChat(tester);
      await tester.tap(find.text(l10n.generateVrc));
      await tester.pumpAndSettle();

      expect(find.text(l10n.selectIdentityTitle), findsOneWidget);
    });

    testWidgets(
      'shows Cancel and Start now buttons with an identity available',
      (tester) async {
        final l10n = await getL10n();

        await _navigateToChat(tester);
        await tester.tap(find.text(l10n.generateVrc));
        await tester.pumpAndSettle();

        expect(find.text(l10n.generalCancel), findsOneWidget);
        expect(find.text(l10n.generateVrc), findsWidgets);
      },
    );
  });
}
