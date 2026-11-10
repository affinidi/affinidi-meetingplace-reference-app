import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_flutter_reference_app/application/services/community_offer_service/community_offer_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/community_join_phrase_action.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_phrase_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_community_offers.dart';

const _club = 'did:webvh:QmClub:vtc.example';

/// The member's role, as their VTA's role card says.
class _FakeVtcService extends Fake implements VtcService {
  String? role;
  Exception? failure;
  final cardChanges = StreamController<void>.broadcast();

  @override
  Stream<void> get membershipsChanged => cardChanges.stream;

  @override
  Future<String?> communityRole(String communityDid) async {
    if (failure case final failure?) throw failure;
    return role;
  }
}

void main() {
  late _FakeVtcService vtc;

  setUp(() => vtc = _FakeVtcService());

  Future<void> pumpAction(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(vtc),
          communityOfferServiceProvider.overrideWithValue(
            CommunityOfferService(
              sdk: () async => FakeOfferSdk(),
              mediatorDid: () => 'did:web:mediator.example',
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: CommunityJoinPhraseAction(
              communityDid: _club,
              communityName: 'Football club',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const action = Key('community_join_phrase');

  testWidgets('opens the join phrase for an administrator', (tester) async {
    vtc.role = 'admin';
    await pumpAction(tester);

    await tester.tap(find.byKey(action));
    await tester.pumpAndSettle();

    expect(find.byType(VtcJoinPhraseView), findsOneWidget);
  });

  testWidgets('offers the join phrase to a member promoted meanwhile', (
    tester,
  ) async {
    vtc.role = 'member';
    await pumpAction(tester);
    expect(find.byKey(action), findsNothing);
    vtc.role = 'admin';

    vtc.cardChanges.add(null);
    await tester.pumpAndSettle();

    expect(find.byKey(action), findsOneWidget);
  });

  for (final role in ['member', 'custom:admin', null]) {
    testWidgets('offers ${role ?? 'no role'} no join phrase', (tester) async {
      vtc.role = role;

      await pumpAction(tester);

      expect(find.byKey(action), findsNothing);
    });
  }

  testWidgets('offers no join phrase when the VTA is unlinked', (tester) async {
    vtc.failure = const VtaNotLinkedException();

    await pumpAction(tester);

    expect(find.byKey(action), findsNothing);
  });
}
