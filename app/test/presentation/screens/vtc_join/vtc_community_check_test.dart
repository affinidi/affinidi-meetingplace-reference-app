import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community_address.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_community_check.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

void main() {
  Future<void> pumpCheck(WidgetTester tester, String did, {Uri? website}) =>
      tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VtcCommunityCheck(
              address: VtcCommunityAddress.of(did)!,
              communityName: 'Football club',
              website: website,
            ),
          ),
        ),
      );

  group('VtcCommunityCheck', () {
    testWidgets('shows the host and fingerprint of a did:webvh', (
      tester,
    ) async {
      await pumpCheck(tester, 'did:webvh:QmAbCdEfGh:vtc.club.org');

      expect(find.text('Is this the right community?'), findsOneWidget);
      expect(find.text('vtc.club.org'), findsOneWidget);
      expect(
        tester
            .widget<SelectableText>(
              find.byKey(const Key('vtc_join_fingerprint')),
            )
            .data,
        'QmAb CdEf Gh',
      );
      expect(
        find.textContaining('compare these with what Football club shows'),
        findsOneWidget,
      );
    });

    testWidgets('shows no fingerprint for a did:web', (tester) async {
      await pumpCheck(tester, 'did:web:club.org');

      expect(find.text('club.org'), findsOneWidget);
      expect(find.byKey(const Key('vtc_join_fingerprint')), findsNothing);
    });

    testWidgets('notes a website on another domain', (tester) async {
      await pumpCheck(
        tester,
        'did:webvh:QmAbCd:vtc.club.org',
        website: Uri.parse('https://club-org.net/'),
      );

      expect(
        find.text(
          'Football club lists a website on club-org.net, not on '
          'vtc.club.org. Make sure you trust both.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('notes nothing for a website on its domain', (tester) async {
      await pumpCheck(
        tester,
        'did:webvh:QmAbCd:vtc.club.org',
        website: Uri.parse('https://www.club.org/'),
      );

      expect(find.byKey(const Key('vtc_join_website_elsewhere')), findsNothing);
    });
  });
}
