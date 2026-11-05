import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community_address.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_community_check.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

void main() {
  Future<void> pumpCheck(WidgetTester tester, String did) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: VtcCommunityCheck(
          address: VtcCommunityAddress.of(did)!,
          communityName: 'Football club',
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
  });
}
