import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_card_delivery.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_card_delivery_trail.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

void main() {
  const personaDid = 'did:peer:2.persona';
  const communityDid = 'did:web:community.example';
  const mediatorDid = 'did:key:z6MkMediator';

  final issue = TrustTaskDocument.fromJson({
    'id': 'urn:uuid:issue-1',
    'type': credentialIssueTask,
    'issuer': communityDid,
    'recipient': personaDid,
    'issuedAt': '2026-11-05T09:30:00Z',
    'payload': {
      'credential_response': {
        'credential': {'type': 'MembershipCredential'},
      },
    },
    'proof': {
      'type': 'DataIntegrityProof',
      'cryptosuite': 'eddsa-jcs-2022',
      'verificationMethod': '$communityDid#key-0',
      'proofPurpose': 'authentication',
      'created': '2026-11-05T09:30:00Z',
      'proofValue': 'zSignature',
    },
  });

  VtcCardDelivery delivered() {
    var delivery = const VtcCardDelivery(personaDid: personaDid)
        .at(
          VtcDeliveryStep.keysLent,
          VtcDeliveryStatus.done,
          signingKeyId: '$personaDid#key-1',
          keyAgreementKeyId: '$personaDid#key-2',
        )
        .at(
          VtcDeliveryStep.signedIn,
          VtcDeliveryStatus.done,
          mediatorDid: mediatorDid,
          waiting: 2,
        )
        .at(VtcDeliveryStep.pickedUp, VtcDeliveryStatus.done, issue: issue)
        .at(VtcDeliveryStep.kept, VtcDeliveryStatus.done, isKeptAsValid: true);
    delivery = delivery.at(VtcDeliveryStep.confirmed, VtcDeliveryStatus.done);
    return delivery;
  }

  Future<void> pumpTrail(WidgetTester tester, VtcCardDelivery delivery) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: VtcCardDeliveryTrail(
              delivery: delivery,
              communityName: 'Football club',
            ),
          ),
        ),
      ),
    );
  }

  Future<void> open(WidgetTester tester, String key) async {
    final step = find.byKey(Key(key));
    await tester.ensureVisible(step);
    await tester.pumpAndSettle();
    await tester.tap(step);
    await tester.pumpAndSettle();
  }

  group('VtcCardDeliveryTrail', () {
    testWidgets('draws each step of a delivered card', (tester) async {
      await pumpTrail(tester, delivered());

      expect(find.text('Keys lent by your VTA'), findsOneWidget);
      expect(
        find.text('Held in memory only, while this screen collects the card'),
        findsOneWidget,
      );
      expect(find.text("Signed in to your identity's inbox"), findsOneWidget);
      expect(find.text('2 messages waiting'), findsOneWidget);
      expect(find.text('Card picked up from Football club'), findsOneWidget);
      expect(
        find.text('Signed by Football club · proof verified'),
        findsOneWidget,
      );
      expect(find.text('Kept on your VTA'), findsOneWidget);
      expect(find.text('Proof checked by your VTA'), findsOneWidget);
      expect(
        find.text('Membership confirmed with Football club'),
        findsOneWidget,
      );
    });

    testWidgets('opens each step to its facts', (tester) async {
      await pumpTrail(tester, delivered());

      await open(tester, 'vtc_delivery_keys');
      expect(find.text(personaDid), findsOneWidget);
      expect(find.text('$personaDid#key-1'), findsOneWidget);
      expect(find.text('Key agreement key'), findsOneWidget);
      expect(find.text('$personaDid#key-2'), findsOneWidget);

      await open(tester, 'vtc_delivery_inbox');
      expect(find.text(mediatorDid), findsOneWidget);

      await open(tester, 'vtc_delivery_pickup');
      expect(find.text(communityDid), findsOneWidget);
      expect(find.text(credentialIssueTask), findsOneWidget);
      expect(find.text('eddsa-jcs-2022'), findsOneWidget);
      expect(find.text('$communityDid#key-0'), findsOneWidget);

      await open(tester, 'vtc_delivery_confirmed');
      expect(find.text(MemberTask.vmc), findsOneWidget);
    });

    testWidgets('shows the signed delivery in full', (tester) async {
      await pumpTrail(tester, delivered());

      final document = find.byKey(const Key('vtc_delivery_pickup_document'));
      await tester.ensureVisible(document);
      await tester.pumpAndSettle();
      await tester.tap(document);
      await tester.pumpAndSettle();

      expect(find.text("The community's signed delivery"), findsOneWidget);
      final shown = tester
          .widget<SelectableText>(find.byKey(const Key('vtc_join_json')))
          .textSpan!
          .toPlainText();
      expect(jsonDecode(shown), issue.toJson());
    });

    testWidgets('turns the pick-up marker while it waits', (tester) async {
      await pumpTrail(
        tester,
        const VtcCardDelivery(personaDid: personaDid)
            .at(VtcDeliveryStep.keysLent, VtcDeliveryStatus.done)
            .at(VtcDeliveryStep.signedIn, VtcDeliveryStatus.done, waiting: 0)
            .at(VtcDeliveryStep.pickedUp, VtcDeliveryStatus.waiting),
      );
      await tester.pump();

      expect(find.text('No messages waiting'), findsOneWidget);
      expect(
        find.text('Waiting for Football club to deliver it'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('vtc_join_trail_marker_busy')),
        findsOneWidget,
      );
      expect(find.text('Still to come'), findsNWidgets(2));
      // No document until the card is picked up.
      expect(
        find.byKey(const Key('vtc_delivery_pickup_document')),
        findsNothing,
      );
    });

    testWidgets('says a step failed and will be tried again', (tester) async {
      await pumpTrail(
        tester,
        const VtcCardDelivery(
          personaDid: personaDid,
        ).at(VtcDeliveryStep.keysLent, VtcDeliveryStatus.failed),
      );

      expect(
        find.text("Your VTA didn't lend the keys. Trying again"),
        findsOneWidget,
      );
      expect(find.byKey(const Key('vtc_trail_marker_failed')), findsOneWidget);
    });
  });
}
