import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'utils/app.dart';

void main() {
  group('ChatVrcExchangeInitiatedNotice', () {
    testWidgets('shows initiated text in chat timeline', (tester) async {
      final l10n = await getL10n();
      final chatSdk = FakeChatSdk();
      await navigateToChat(tester, chatSdk: chatSdk);

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
      final chatSdk = FakeChatSdk();
      await navigateToChat(tester, chatSdk: chatSdk);

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
      final chatSdk = FakeChatSdk();
      await navigateToChat(tester, chatSdk: chatSdk);

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
      final chatSdk = FakeChatSdk();
      await navigateToChat(tester, chatSdk: chatSdk);
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
