import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_connectivity.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'utils/app.dart';

Future<FakeChatSdk> _navigateToChat(WidgetTester tester) async {
  final chatSdk = FakeChatSdk();
  await navigateToLocation(
    tester,
    '/contacts/individual-contact-id/chat',
    identities: [FakeIdentities.primaryIdentity],
    contacts: [FakeContacts.individualContact],
    meetingPlaceChatSDK: chatSdk,
    connectivity: FakeConnectivity(
      initialConnectivityToReturn: [ConnectivityResult.wifi],
    ),
  );
  await tester.pumpAndSettle();
  return chatSdk;
}

void main() {
  group('ChatVrcExchangeInitiatedNotice', () {
    testWidgets('shows initiated text in chat timeline', (tester) async {
      final l10n = await getL10n();
      final chatSdk = await _navigateToChat(tester);

      chatSdk.simulateVrcEvent(
        eventType: 'vrcExchangeInitiated',
        senderDid: FakeChannels.individualChannel.permanentChannelDid!,
        recipientDid: FakeIdentities.primaryIdentity.card.did,
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.vrcExchangeInitiated), findsOneWidget);
    });
  });

  group('ChatVrcExchangeDoLaterNotice', () {
    testWidgets('shows do later text in chat timeline', (tester) async {
      final l10n = await getL10n();
      final chatSdk = await _navigateToChat(tester);

      chatSdk.simulateVrcEvent(
        eventType: 'vrcExchangeDoLater',
        senderDid: FakeChannels.individualChannel.permanentChannelDid!,
        recipientDid: FakeIdentities.primaryIdentity.card.did,
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.vrcDoLater), findsOneWidget);
    });
  });

  group('ChatVrcExchangeCompleteNotice', () {
    testWidgets('shows completed text in chat timeline', (tester) async {
      final l10n = await getL10n();
      final chatSdk = await _navigateToChat(tester);

      chatSdk.simulateVrcEvent(
        eventType: 'vrcExchangeCompleted',
        senderDid: FakeChannels.individualChannel.permanentChannelDid!,
        recipientDid: FakeIdentities.primaryIdentity.card.did,
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.vrcExchangeCompleted), findsOneWidget);
    });
  });

  group('ChatVrcRequestReceivedNotice', () {
    testWidgets('shows request received text with the contact name', (
      tester,
    ) async {
      final l10n = await getL10n();
      final chatSdk = await _navigateToChat(tester);
      final firstName =
          FakeContacts.individualContact.otherPartyCard!.firstName;

      chatSdk.simulateVrcEvent(
        eventType: 'vrcRequestReceived',
        senderDid: FakeChannels.individualChannel.permanentChannelDid!,
        recipientDid: FakeIdentities.primaryIdentity.card.did,
        data: {
          'identityDid': 'did:key:peer-identity',
          'identityName': firstName,
        },
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.vrcRequestReceived(firstName)), findsOneWidget);
    });
  });
}
