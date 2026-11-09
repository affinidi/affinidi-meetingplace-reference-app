import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/community_offer_service/community_offer_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/community_settings_view.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_findable_view.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_phrase_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_community_offers.dart';
import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';

const _club = 'did:webvh:QmClub:vtc.example';

/// The member's role, as their VTA's role card says.
class _FakeVtcService extends Fake implements VtcService {
  String? role;
  Exception? failure;

  @override
  Future<String?> communityRole(String communityDid) async {
    if (failure case final failure?) throw failure;
    return role;
  }
}

/// The member's directory card, not shown to other members.
class _FakeTrustService extends Fake implements VtcTrustService {
  @override
  Future<MyDirectoryCard> directoryCard(String communityDid) async =>
      const MyDirectoryCard(
        entryId: 'dir_me',
        isDidVisibleToMembers: false,
        isHidden: false,
      );

  @override
  Future<String?> identityDid(String communityDid) async =>
      FakeIdentities.primaryIdentity.did;
}

void main() {
  late _FakeVtcService vtc;

  setUp(() => vtc = _FakeVtcService());

  Future<void> pumpView(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(vtc),
          vtcTrustServiceProvider.overrideWithValue(_FakeTrustService()),
          communityOfferServiceProvider.overrideWithValue(
            CommunityOfferService(
              sdk: () async => FakeOfferSdk(),
              mediatorDid: () => 'did:web:mediator.example',
            ),
          ),
          identitiesServiceProvider.overrideWith(
            () => FakeIdentitiesService(
              IdentitiesServiceState(
                currentIdentity: FakeIdentities.primaryIdentity,
                identities: [FakeIdentities.primaryIdentity],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: CommunitySettingsView(
              communityDid: _club,
              communityName: 'Football club',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lets an administrator manage the join phrase', (tester) async {
    vtc.role = 'admin';

    await pumpView(tester);

    expect(find.byType(VtcFindableView), findsOneWidget);
    expect(find.byType(VtcJoinPhraseView), findsOneWidget);
  });

  for (final role in ['member', 'custom:admin', null]) {
    testWidgets('offers ${role ?? 'no role'} only how members find them', (
      tester,
    ) async {
      vtc.role = role;

      await pumpView(tester);

      expect(find.byType(VtcFindableView), findsOneWidget);
      expect(find.byType(VtcJoinPhraseView), findsNothing);
    });
  }

  testWidgets('still offers how members find them when the VTA is unlinked', (
    tester,
  ) async {
    vtc.failure = const VtaNotLinkedException();

    await pumpView(tester);

    expect(find.byType(VtcFindableView), findsOneWidget);
    expect(find.byType(VtcJoinPhraseView), findsNothing);
  });
}
