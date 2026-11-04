import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_trail.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

void main() {
  final receipt = TrustTaskReceipt(
    type: JoinTask.submit,
    documentId: 'urn:uuid:submit',
    signer: 'did:webvh:persona',
    answeredBy: 'did:webvh:community',
    cryptosuite: 'eddsa-jcs-2022',
    verificationMethod: 'did:webvh:persona#key-0',
    signedAt: DateTime.utc(2026, 11, 4, 10, 12),
    answeredAt: DateTime.utc(2026, 11, 4, 10, 13),
  );

  final lastCheck = TrustTaskReceipt(
    type: JoinTask.status,
    documentId: 'urn:uuid:status',
    signer: 'did:webvh:persona',
    answeredBy: 'did:webvh:community',
    signedAt: DateTime.utc(2026, 11, 4, 10, 14),
    answeredAt: DateTime.utc(2026, 11, 4, 10, 14),
  );

  Future<void> pumpTrail(
    WidgetTester tester, {
    TrustTaskReceipt? receipt,
    String? requestId,
    bool deferred = false,
    DateTime? lastCheckedAt,
    TrustTaskReceipt? lastCheck,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: VtcJoinTrail(
              communityName: 'Football club',
              receipt: receipt,
              requestId: requestId,
              deferred: deferred,
              lastCheckedAt: lastCheckedAt,
              lastCheck: lastCheck,
              autoCheckInterval: const Duration(seconds: 30),
            ),
          ),
        ),
      ),
    );
  }

  group('VtcJoinTrail', () {
    testWidgets('draws each step, the card still to come', (tester) async {
      await pumpTrail(tester, receipt: receipt);

      expect(find.text('Signed by your VTA'), findsOneWidget);
      expect(
        find.textContaining(
          'As your identity in Football club · eddsa-jcs-2022 · ',
        ),
        findsOneWidget,
      );
      expect(find.text('Received by Football club'), findsOneWidget);
      expect(
        find.text('Passed to its administrators · its signed answer verified'),
        findsOneWidget,
      );
      expect(find.text('Waiting for the administrators'), findsOneWidget);
      expect(
        find.text('Checked again every 30 seconds while this screen is open'),
        findsOneWidget,
      );
      expect(find.text('Membership card'), findsOneWidget);
    });

    testWidgets('opens a step to the proof behind it', (tester) async {
      await pumpTrail(
        tester,
        receipt: receipt,
        requestId: 'request-1',
        lastCheckedAt: DateTime(2026, 11, 4, 10, 14),
        lastCheck: lastCheck,
      );
      expect(find.text(JoinTask.submit), findsNothing);

      await tester.tap(find.byKey(const Key('vtc_join_trail_vta')));
      await tester.pumpAndSettle();
      expect(find.text('did:webvh:persona'), findsOneWidget);
      expect(find.text(JoinTask.submit), findsOneWidget);
      expect(find.text('urn:uuid:submit'), findsOneWidget);
      expect(find.text('Cryptosuite'), findsOneWidget);
      expect(find.text('did:webvh:persona#key-0'), findsOneWidget);
      expect(find.text('Signed at'), findsOneWidget);

      await tester.tap(find.byKey(const Key('vtc_join_trail_community')));
      await tester.pumpAndSettle();
      expect(find.text('did:webvh:community'), findsOneWidget);
      expect(find.text('Answered at'), findsOneWidget);
      expect(find.text('request-1'), findsOneWidget);

      await tester.tap(find.byKey(const Key('vtc_join_trail_review')));
      await tester.pumpAndSettle();
      expect(find.text(JoinTask.status), findsOneWidget);
      expect(find.text('Last check signed by your VTA at'), findsOneWidget);
      expect(find.text('Last check answered and verified at'), findsOneWidget);
    });

    testWidgets('says when the administrators put it off', (tester) async {
      await pumpTrail(
        tester,
        receipt: receipt,
        deferred: true,
        lastCheckedAt: DateTime(2026, 11, 4, 10, 14),
      );

      expect(
        find.text('Put off by the administrators for now'),
        findsOneWidget,
      );
      expect(find.text('Last checked at 10:14'), findsOneWidget);
    });

    testWidgets('shows the steps without a receipt', (tester) async {
      await pumpTrail(tester);

      expect(find.text('As your identity in Football club'), findsOneWidget);
      expect(
        find.text('Sent earlier; this phone keeps no receipt for it'),
        findsOneWidget,
      );
      // Nothing to open.
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });
  });
}
