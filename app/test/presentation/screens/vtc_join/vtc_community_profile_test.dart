import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_community_profile.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

void main() {
  Future<void> pumpProfile(
    WidgetTester tester,
    VtcCommunityProfile profile,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: profile)),
      ),
    );
  }

  testWidgets('shows what the community publishes and its join phrase', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      VtcCommunityProfile(
        communityDid: 'did:web:chess.example',
        description: 'We play chess.',
        website: Uri.parse('https://chess.example'),
        contactEmail: 'hello@chess.example',
        joinPhrase: 'knight moves',
      ),
    );

    expect(find.text('We play chess.'), findsOneWidget);
    expect(find.text('https://chess.example'), findsOneWidget);
    expect(find.text('hello@chess.example'), findsOneWidget);
    expect(find.text('Community DID'), findsOneWidget);
    expect(find.text('Join phrase'), findsOneWidget);
    expect(find.text('knight moves'), findsOneWidget);
  });

  testWidgets('leaves out what the community does not publish', (tester) async {
    await pumpProfile(
      tester,
      const VtcCommunityProfile(communityDid: 'did:web:chess.example'),
    );

    expect(find.text('Community DID'), findsOneWidget);
    expect(find.text('Website'), findsNothing);
    expect(find.text('Contact'), findsNothing);
    expect(find.byKey(const Key('vtc_community_join_phrase')), findsNothing);
  });
}
