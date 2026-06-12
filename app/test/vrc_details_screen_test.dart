import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/vrc_service/vrc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vrc/vrc_credential.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/verifiable_credential/verifiable_credential_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';

import 'fakes/fake_vrc_service.dart';
import 'utils/app.dart';

const _credentialId = 'test-vrc-id';

Widget _buildApp({required Widget home}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(extensions: const [AppCustomColors()]),
  home: home,
);

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
      overrides: [vrcServiceProvider.overrideWith(FakeVrcService.new)],
      child: _buildApp(
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
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(
    File('${Directory.systemTemp.path}/vrc_details_test.log'),
  );
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

  group('VrcDetailsScreen — null / error paths', () {
    testWidgets('shows loading when credential is not in store', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [vrcServiceProvider.overrideWith(FakeVrcService.new)],
          child: _buildApp(
            home: const VrcDetailsScreen(credentialId: 'unknown-id'),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows DID rows when vc is empty', (tester) async {
      final l10n = await getL10n();
      final cred = VrcCredential(
        id: _credentialId,
        vc: '',
        channelId: 'did:key:channel',
        holderIdentityDid: 'did:key:holder',
        issuerIdentityDid: 'did:key:issuer',
        issuedAt: DateTime(2024, 1, 1),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [vrcServiceProvider.overrideWith(FakeVrcService.new)],
          child: _buildApp(
            home: VrcDetailsScreen(
              credentialId: _credentialId,
              credential: cred,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(cred.issuerIdentityDid), findsOneWidget);
      expect(find.text(cred.holderIdentityDid), findsOneWidget);
      expect(find.text('${l10n.generalName}:'), findsNothing);
    });

    testWidgets('shows DID rows when vc JSON is invalid', (tester) async {
      final cred = VrcCredential(
        id: _credentialId,
        vc: 'not-valid-json',
        channelId: 'did:key:channel',
        holderIdentityDid: 'did:key:holder',
        issuerIdentityDid: 'did:key:issuer',
        issuedAt: DateTime(2024, 1, 1),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [vrcServiceProvider.overrideWith(FakeVrcService.new)],
          child: _buildApp(
            home: VrcDetailsScreen(
              credentialId: _credentialId,
              credential: cred,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(cred.issuerIdentityDid), findsOneWidget);
      expect(find.text(cred.holderIdentityDid), findsOneWidget);
    });

    testWidgets('shows DID rows when credentialSubject is absent', (
      tester,
    ) async {
      final l10n = await getL10n();
      const vcNoSubject = '{"type":["VerifiableCredential"]}';
      final cred = VrcCredential(
        id: _credentialId,
        vc: vcNoSubject,
        channelId: 'did:key:channel',
        holderIdentityDid: 'did:key:holder',
        issuerIdentityDid: 'did:key:issuer',
        issuedAt: DateTime(2024, 1, 1),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [vrcServiceProvider.overrideWith(FakeVrcService.new)],
          child: _buildApp(
            home: VrcDetailsScreen(
              credentialId: _credentialId,
              credential: cred,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(cred.issuerIdentityDid), findsOneWidget);
      expect(find.text(cred.holderIdentityDid), findsOneWidget);
      expect(find.text('${l10n.generalName}:'), findsNothing);
    });
  });
}
