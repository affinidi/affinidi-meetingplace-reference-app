import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_membership_card.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_membership_card_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _me = 'did:webvh:QmMe:vta.example:me';

void main() {
  Future<void> openCard(WidgetTester tester, {String? id}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: VtcMembershipCardView(
              communityName: 'Chess club',
              card: VtcMembershipCard(
                issuer: _club,
                memberDid: _me,
                credential: {
                  'id': ?id,
                  'type': ['VerifiableCredential', 'MembershipCredential'],
                  'issuer': _club,
                  'credentialSubject': {'id': _me},
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('vtc_membership_card_document')));
    await tester.pumpAndSettle();
  }

  group('VtcMembershipCardView', () {
    testWidgets('copies the command that fetches the card from the VTA', (
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
      await openCard(tester, id: 'urn:uuid:vmc');

      await tester.tap(find.byKey(const Key('vtc_join_json_copy_command')));
      await tester.pump(const Duration(seconds: 2));

      // The VTA keeps the card under its own id.
      expect(copied, 'pnm cred-vault get urn:uuid:vmc');
    });

    testWidgets('offers no command for a card without an id', (tester) async {
      await openCard(tester);

      expect(find.byKey(const Key('vtc_join_json_copy')), findsOneWidget);
      expect(find.byKey(const Key('vtc_join_json_copy_command')), findsNothing);
    });
  });
}
