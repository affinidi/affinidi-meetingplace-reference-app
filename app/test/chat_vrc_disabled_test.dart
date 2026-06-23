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

bool _isVrcOptionEnabled(WidgetTester tester, String label) {
  final option = tester.widget<InkWell>(
    find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
  );

  return option.onTap != null;
}

Future<void> _navigateToGroupChat(WidgetTester tester) async {
  await navigateToChat(
    tester,
    contactId: FakeContacts.groupContact.id,
    identities: [FakeIdentities.primaryIdentity],
    contacts: [FakeContacts.groupContact],
    chatSdk: FakeChatSdk(),
    connectivity: FakeConnectivity(
      initialConnectivityToReturn: [ConnectivityResult.wifi],
    ),
  );
}

Future<void> _navigateToOobChat(WidgetTester tester) async {
  await navigateToChat(
    tester,
    contactId: FakeContacts.oobContact.id,
    identities: [FakeIdentities.primaryIdentity],
    contacts: [FakeContacts.oobContact],
    chatSdk: FakeChatSdk(),
    connectivity: FakeConnectivity(
      initialConnectivityToReturn: [ConnectivityResult.wifi],
    ),
  );
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
      await _navigateToGroupChat(tester);
      await _openAttachmentSheet(tester);

      final l10n = await getL10n();
      final enabled = _isVrcOptionEnabled(tester, l10n.vrcAbbreviation);
      expect(enabled, isFalse);
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
      await _navigateToOobChat(tester);
      await _openAttachmentSheet(tester);

      final l10n = await getL10n();
      final enabled = _isVrcOptionEnabled(tester, l10n.vrcAbbreviation);
      expect(enabled, isFalse);
    });
  });
}
