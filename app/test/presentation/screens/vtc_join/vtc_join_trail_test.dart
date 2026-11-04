import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_trail.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

void main() {
  Map<String, dynamic> proof(String key, String created) => {
    'type': 'DataIntegrityProof',
    'cryptosuite': 'eddsa-jcs-2022',
    'verificationMethod': key,
    'proofPurpose': 'authentication',
    'created': created,
    'proofValue': 'zSignature',
  };

  TrustTaskExchange exchange({
    required String type,
    required String id,
    required Map<String, dynamic> payload,
    required Map<String, dynamic> answer,
    required String signedAt,
    required String answeredAt,
    String answerKey = 'did:webvh:community#key-0',
  }) => TrustTaskExchange(
    request: TrustTaskDocument.fromJson({
      'id': id,
      'type': type,
      'issuer': 'did:webvh:persona',
      'recipient': 'did:webvh:community',
      'issuedAt': signedAt,
      'payload': payload,
      'proof': proof('did:webvh:persona#key-0', signedAt),
    }),
    answer: TrustTaskDocument.fromJson({
      'id': '$id-answer',
      'type': '$type#response',
      'issuer': 'did:webvh:community',
      'recipient': 'did:webvh:persona',
      'threadId': id,
      'issuedAt': answeredAt,
      'payload': answer,
      'proof': proof(answerKey, answeredAt),
    }),
  );

  final submit = exchange(
    type: JoinTask.submit,
    id: 'urn:uuid:submit',
    payload: {
      'criterion': 'z1',
      'attributes': [
        {'type': 'name', 'value': 'Alice'},
      ],
    },
    answer: {
      'requestId': 'request-1',
      'verdict': {'effect': 'refer', 'with': <String, dynamic>{}},
    },
    signedAt: '2026-11-04T10:12:00Z',
    answeredAt: '2026-11-04T10:13:00Z',
  );

  final lastCheck = exchange(
    type: JoinTask.status,
    id: 'urn:uuid:status',
    payload: {'requestId': 'request-1'},
    answer: {'requestId': 'request-1', 'status': 'pending'},
    signedAt: '2026-11-04T10:14:00Z',
    answeredAt: '2026-11-04T10:14:00Z',
    answerKey: 'did:webvh:community#key-1',
  );

  Future<void> pumpTrail(
    WidgetTester tester, {
    TrustTaskExchange? submit,
    TrustTaskReceipt? receipt,
    String? requestId,
    bool deferred = false,
    DateTime? lastCheckedAt,
    TrustTaskExchange? lastCheck,
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
              submit: submit,
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
      await pumpTrail(tester, submit: submit);

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
        submit: submit,
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
      expect(find.text('Proof purpose'), findsOneWidget);

      await tester.tap(find.byKey(const Key('vtc_join_trail_community')));
      await tester.pumpAndSettle();
      expect(find.text('did:webvh:community'), findsOneWidget);
      expect(find.text('Answered at'), findsOneWidget);
      expect(find.text('request-1'), findsOneWidget);
      // The answer's Trust Task, as for the VTA's.
      expect(find.text('${JoinTask.submit}#response'), findsOneWidget);
      expect(find.text('urn:uuid:submit-answer'), findsOneWidget);
      expect(find.text('Trust Task'), findsNWidgets(2));
      expect(find.text('Document id'), findsNWidgets(2));
      // The answer's proof, as for the VTA's signature.
      expect(find.text('did:webvh:community#key-0'), findsOneWidget);
      expect(find.text('Cryptosuite'), findsNWidgets(2));
      expect(find.text('Proof purpose'), findsNWidgets(2));
      expect(find.text('Signed at'), findsNWidgets(2));

      final review = find.byKey(const Key('vtc_join_trail_review'));
      await tester.ensureVisible(review);
      await tester.pumpAndSettle();
      await tester.tap(review);
      await tester.pumpAndSettle();
      expect(find.text(JoinTask.status), findsOneWidget);
      expect(find.text('Last check signed by your VTA at'), findsOneWidget);
      expect(find.text('Last check answered and verified at'), findsOneWidget);
      expect(find.text('did:webvh:community#key-1'), findsOneWidget);
    });

    testWidgets('shows each signed document in full', (tester) async {
      await pumpTrail(tester, submit: submit, lastCheck: lastCheck);

      await tester.tap(find.byKey(const Key('vtc_join_trail_vta_document')));
      await tester.pumpAndSettle();
      expect(find.text('Your signed application'), findsOneWidget);
      final shown = tester
          .widget<SelectableText>(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(SelectableText),
            ),
          )
          .data!;
      expect(jsonDecode(shown), submit.request.toJson());
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('vtc_join_trail_community_document')),
      );
      await tester.pumpAndSettle();
      expect(find.text("The community's signed answer"), findsOneWidget);
      expect(find.textContaining('"effect": "refer"'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      final review = find.byKey(const Key('vtc_join_trail_review_document'));
      await tester.ensureVisible(review);
      await tester.pumpAndSettle();
      await tester.tap(review);
      await tester.pumpAndSettle();
      expect(find.text("The community's last signed answer"), findsOneWidget);
      expect(find.textContaining('"status": "pending"'), findsOneWidget);
    });

    testWidgets('shows a receipt kept without its documents', (tester) async {
      await pumpTrail(tester, receipt: submit.receipt);

      expect(find.textContaining('eddsa-jcs-2022 · '), findsOneWidget);
      expect(
        find.text('Passed to its administrators · its signed answer verified'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('vtc_join_trail_vta')));
      await tester.pumpAndSettle();
      expect(find.text('urn:uuid:submit'), findsOneWidget);
      // No documents to show.
      expect(find.byIcon(Icons.data_object), findsNothing);
    });

    testWidgets('says when the administrators put it off', (tester) async {
      await pumpTrail(
        tester,
        submit: submit,
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
      // Nothing to open or show.
      expect(find.byIcon(Icons.expand_more), findsNothing);
      expect(find.byIcon(Icons.data_object), findsNothing);
    });
  });
}
