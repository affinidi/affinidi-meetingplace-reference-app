import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_identity_check.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_identity_check_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

const _me = 'did:webvh:QmMe:vta.example:me';

void main() {
  Future<void> openStatement(WidgetTester tester, {String? id}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: VtcIdentityCheckView(
              communityName: 'Chess club',
              check: VtcIdentityCheck(
                memberDid: _me,
                method: 'inPerson',
                credential: {
                  'id': ?id,
                  'type': ['VerifiableCredential', 'StatementCredential'],
                  'credentialSubject': {'id': _me},
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('vtc_identity_check_document')));
    await tester.pumpAndSettle();
  }

  group('VtcIdentityCheckView', () {
    testWidgets('copies the command that fetches the check from the VTA', (
      tester,
    ) async {
      String? copied;
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await openStatement(tester, id: 'urn:uuid:check');

      await tester.tap(find.byKey(const Key('vtc_join_json_copy_command')));
      await tester.pump(const Duration(seconds: 2));

      // The VTA keeps the statement under its own id.
      expect(copied, 'pnm cred-vault get urn:uuid:check');
    });

    testWidgets('offers no command for a check without an id', (tester) async {
      await openStatement(tester);

      expect(find.byKey(const Key('vtc_join_json_copy')), findsOneWidget);
      expect(find.byKey(const Key('vtc_join_json_copy_command')), findsNothing);
    });
  });
}
