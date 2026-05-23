import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_connectivity.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'utils/app.dart';

/// Opens the + attachment sheet from the chat input bar.
Future<void> _openAttachmentSheet(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
}

ListTile _findVrcListTile(WidgetTester tester, String label) {
  return tester.widget<ListTile>(
    find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
  );
}

Future<void> _navigateToGroupChat(WidgetTester tester) async {
  await navigateToLocation(
    tester,
    '/contacts/${FakeContacts.groupContact.id}/chat',
    identities: [FakeIdentities.primaryIdentity],
    contacts: [FakeContacts.groupContact],
    meetingPlaceChatSDK: FakeChatSdk(),
    connectivity: FakeConnectivity(
      initialConnectivityToReturn: [ConnectivityResult.wifi],
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _navigateToOobChat(WidgetTester tester) async {
  await navigateToLocation(
    tester,
    '/contacts/${FakeContacts.oobContact.id}/chat',
    identities: [FakeIdentities.primaryIdentity],
    contacts: [FakeContacts.oobContact],
    meetingPlaceChatSDK: FakeChatSdk(),
    connectivity: FakeConnectivity(
      initialConnectivityToReturn: [ConnectivityResult.wifi],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('VRC disabled in group chat', () {
    testWidgets('does not show the VRC banner', (tester) async {
      final l10n = await getL10n();

      await _navigateToGroupChat(tester);

      expect(
        find.text(
          l10n.verifyRelationshipPrompt(
            FakeContacts.groupContact.otherPartyCard!.firstName,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('VRC option in attachment sheet is disabled', (tester) async {
      final l10n = await getL10n();

      await _navigateToGroupChat(tester);
      await _openAttachmentSheet(tester);

      final tile = _findVrcListTile(
        tester,
        l10n.verifiableRelationshipCredential,
      );
      expect(tile.enabled, isFalse);
    });
  });

  group('VRC disabled for Direct Share QR code (OOB) chat', () {
    testWidgets('does not show the VRC banner', (tester) async {
      final l10n = await getL10n();

      await _navigateToOobChat(tester);

      expect(
        find.text(
          l10n.verifyRelationshipPrompt(
            FakeContacts.oobContact.otherPartyCard!.firstName,
          ),
        ),
        findsNothing,
      );
    });

    testWidgets('VRC option in attachment sheet is disabled', (tester) async {
      final l10n = await getL10n();

      await _navigateToOobChat(tester);
      await _openAttachmentSheet(tester);

      final tile = _findVrcListTile(
        tester,
        l10n.verifiableRelationshipCredential,
      );
      expect(tile.enabled, isFalse);
    });
  });
}
