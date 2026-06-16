import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_identities.dart';
import 'utils/app.dart';

const _addMediaButtonKey = Key('chat_add_media_button');

Future<void> _openMediaSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(_addMediaButtonKey));
  await tester.pumpAndSettle();
}

ListTile _findVrcListTile(WidgetTester tester, String label) {
  return tester.widget<ListTile>(
    find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
  );
}

void main() {
  group('Chat attachment VRC option', () {
    testWidgets('shows VRC option in media options sheet', (tester) async {
      final l10n = await getL10n();

      await navigateToChat(tester);
      await _openMediaSheet(tester);

      expect(find.text(l10n.verifiableRelationshipCredential), findsOneWidget);
    });

    testWidgets('VRC option is enabled in a fresh chat', (tester) async {
      final l10n = await getL10n();

      await navigateToChat(tester);
      await _openMediaSheet(tester);

      final tile = _findVrcListTile(
        tester,
        l10n.verifiableRelationshipCredential,
      );
      expect(tile.enabled, isTrue);
    });

    testWidgets('VRC option is disabled after exchange is initiated', (
      tester,
    ) async {
      final l10n = await getL10n();
      final chatSdk = FakeChatSdk();

      await navigateToChat(tester, chatSdk: chatSdk);

      chatSdk.simulateVrcEvent(
        eventType: 'vrcExchangeInitiated',
        senderDid: FakeChannels.individualChannel.permanentChannelDid!,
        recipientDid: FakeIdentities.primaryIdentity.card.did,
      );
      await tester.pumpAndSettle();

      await _openMediaSheet(tester);

      final tile = _findVrcListTile(
        tester,
        l10n.verifiableRelationshipCredential,
      );
      expect(tile.enabled, isFalse);
    });

    testWidgets('VRC option is re-enabled after Do later is tapped', (
      tester,
    ) async {
      final l10n = await getL10n();

      await navigateToChat(tester);

      // Tap Do later from the banner — this should keep the attachment enabled
      await tester.tap(find.text(l10n.doLater));
      await tester.pumpAndSettle();

      await _openMediaSheet(tester);

      final tile = _findVrcListTile(
        tester,
        l10n.verifiableRelationshipCredential,
      );
      expect(tile.enabled, isTrue);
    });
  });
}
