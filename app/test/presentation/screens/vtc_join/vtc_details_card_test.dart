import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_details_card.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/vta_identity_card.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, List<VtcDetail> details) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: VtcDetailsCard(
                heading: 'Applicant\'s details',
                details: details,
                note: 'Check these against their ID.',
              ),
            ),
          ),
        ),
      );

  Finder row(String value) =>
      find.ancestor(of: find.text(value), matching: find.byType(Row));

  testWidgets('draws the details as an identity card', (tester) async {
    await pumpCard(tester, [
      (type: 'email.personal', value: 'ada@example.com'),
      (type: 'name.display', value: 'Ada Lovelace'),
      (type: 'phone.mobile', value: '+44 7700 900000'),
    ]);

    expect(find.byType(IdentityCardAvatar), findsOneWidget);
    expect(find.text('APPLICANT\'S DETAILS'), findsOneWidget);
    expect(find.text('Check these against their ID.'), findsOneWidget);
    // The name heads the card rather than sitting among the details.
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(row('Ada Lovelace'), findsNothing);
    expect(
      find.descendant(
        of: row('ada@example.com'),
        matching: find.byIcon(McIcons.email),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: row('+44 7700 900000'),
        matching: find.byIcon(McIcons.phone),
      ),
      findsOneWidget,
    );
  });

  testWidgets('labels each detail with its kind', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    await pumpCard(tester, [
      (type: 'email.personal', value: 'ada@example.com'),
      (type: 'email.work', value: 'ada@work.example'),
    ]);

    expect(
      find.descendant(
        of: row('ada@example.com'),
        matching: find.text(l10n.vtcClaimTypeEmailPersonal),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: row('ada@work.example'),
        matching: find.text(l10n.vtcClaimTypeEmailWork),
      ),
      findsOneWidget,
    );
  });

  testWidgets('keeps given and family names as details', (tester) async {
    await pumpCard(tester, [
      (type: 'name.given', value: 'Ada'),
      (type: 'name.family', value: 'Lovelace'),
    ]);

    expect(
      find.descendant(of: row('Ada'), matching: find.byIcon(McIcons.person)),
      findsOneWidget,
    );
    expect(row('Lovelace'), findsOneWidget);
  });
}
