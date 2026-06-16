import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'utils/app.dart';

void main() {
  group('ConciergeVrcChatItem', () {
    testWidgets(
      'shows Start now and Do Later buttons when concierge is pending',
      (tester) async {
        final l10n = await getL10n();
        final chatSdk = FakeChatSdk();

        await navigateToChat(tester, chatSdk: chatSdk);

        chatSdk.simulateVrcPermissionRequest(
          senderDid: FakeChannels.individualChannel.permanentChannelDid!,
          recipientDid: FakeIdentities.primaryIdentity.card.did,
        );
        await tester.pumpAndSettle();

        expect(find.text(l10n.generateVrc), findsOneWidget);
        expect(find.text(l10n.vrcDoLaterButton), findsOneWidget);
      },
    );

    testWidgets('shows the concierge prompt text with the contact name', (
      tester,
    ) async {
      final l10n = await getL10n();
      final chatSdk = FakeChatSdk();

      await navigateToChat(tester, chatSdk: chatSdk);

      chatSdk.simulateVrcPermissionRequest(
        senderDid: FakeChannels.individualChannel.permanentChannelDid!,
        recipientDid: FakeIdentities.primaryIdentity.card.did,
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          l10n.vrcVerifyPrompt(
            FakeContacts.individualContact.otherPartyCard!.firstName,
          ),
        ),
        findsOneWidget,
      );
    });
  });
}
