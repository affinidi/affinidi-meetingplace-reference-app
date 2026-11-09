import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'utils/app.dart';

void main() {
  group('ConciergeVrcChatItem', () {
    // The app follows the system brightness, so cover both themes.
    for (final brightness in Brightness.values) {
      testWidgets('renders the pending concierge card in ${brightness.name} '
          'mode', (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        final l10n = await getL10n();
        final chatSdk = FakeChatSdk();

        await navigateToChat(tester, chatSdk: chatSdk);

        chatSdk.simulateVrcPermissionRequest(
          senderDid: FakeChannels.individualChannel.permanentChannelDid!,
          recipientDid: FakeIdentities.primaryIdentity.card.did,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          Theme.of(tester.element(find.text(l10n.generateVrc))).brightness,
          brightness,
        );
      });
    }

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
