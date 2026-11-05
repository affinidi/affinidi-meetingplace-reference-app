import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_flutter_reference_app/application/services/community_offer_service/community_offer_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_phrase_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_community_offers.dart';

const _communityDid = 'did:webvh:community.example';

void main() {
  late FakeOfferSdk sdk;

  setUp(() {
    sdk = FakeOfferSdk();
  });

  Future<void> pumpView(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          communityOfferServiceProvider.overrideWithValue(
            CommunityOfferService(
              sdk: () async => sdk,
              mediatorDid: () => 'did:web:mediator.example',
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: VtcJoinPhraseView(
                communityDid: _communityDid,
                communityName: 'Club',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> publish(WidgetTester tester, String phrase) async {
    await tester.tap(find.text('Publish join phrase'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('vtc_join_phrase_field')),
      phrase,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Publish join phrase'),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lets a member publish a join phrase', (tester) async {
    await pumpView(tester);
    expect(find.textContaining('Let people find Club'), findsOneWidget);

    await publish(tester, 'my-club');

    expect(sdk.requests.single.customMnemonic, 'my-club');
    expect(sdk.requests.single.offerDescription, 'Join Club in Meeting Place');
    expect(find.byKey(const Key('vtc_join_phrase_text')), findsOneWidget);
    expect(find.text('my-club'), findsOneWidget);
    expect(find.textContaining('nothing about you'), findsOneWidget);
    expect(find.text('Withdraw phrase'), findsOneWidget);
  });

  testWidgets('says when the phrase is taken', (tester) async {
    sdk.taken.add('my-club');
    await pumpView(tester);

    await publish(tester, 'my-club');

    expect(find.textContaining('already taken'), findsOneWidget);
    expect(sdk.requests, isEmpty);
  });

  testWidgets('withdraws the phrase once confirmed', (tester) async {
    await pumpView(tester);
    await publish(tester, 'my-club');

    await tester.tap(find.text('Withdraw phrase'));
    await tester.pumpAndSettle();
    expect(find.text('Withdraw "my-club"?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Withdraw phrase'),
      ),
    );
    await tester.pumpAndSettle();

    expect(sdk.offers.single.isDeleted, isTrue);
    expect(find.text('Publish join phrase'), findsOneWidget);
  });
}
