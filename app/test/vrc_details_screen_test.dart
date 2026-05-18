import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vrc/vrc_credential.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/verifiable_credential/verifiable_credential_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';

import 'utils/app.dart';

const _credentialId = 'test-vrc-id';

final _testCredential = VrcCredential(
  id: _credentialId,
  vc: '{}',
  channelId: 'did:key:channel',
  holderIdentityDid: 'did:key:holder',
  issuerIdentityDid: 'did:key:issuer',
  issuedAt: DateTime(2024, 1, 1),
);

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(extensions: const [AppCustomColors()]),
        home: VrcDetailsScreen(
          credentialId: _credentialId,
          credential: _testCredential,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('VrcDetailsScreen', () {
    testWidgets('shows the Secure Attachments title', (tester) async {
      final l10n = await getL10n();
      await _pump(tester);
      expect(find.text(l10n.secureAttachmentsTitle), findsWidgets);
    });

    testWidgets('shows Issuer and Holder sections', (tester) async {
      final l10n = await getL10n();
      await _pump(tester);
      expect(find.text('${l10n.vrcSectionIssuer}:'), findsOneWidget);
      expect(find.text('${l10n.vrcSectionHolder}:'), findsOneWidget);
    });

    testWidgets('shows Issued On row', (tester) async {
      final l10n = await getL10n();
      await _pump(tester);
      expect(find.text('${l10n.vrcFieldIssuedAt}:'), findsOneWidget);
    });

    testWidgets('does not show the Verified row', (tester) async {
      final l10n = await getL10n();
      await _pump(tester);
      expect(find.text('${l10n.vrcFieldVerifiedAt}:'), findsNothing);
    });
  });
}
