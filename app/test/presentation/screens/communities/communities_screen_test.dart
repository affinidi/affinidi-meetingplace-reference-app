import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/build_context_extensions.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/credentials/membership_credentials_list.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/common/app_card.dart';

import '../../../fakes/fake_identities.dart';
import '../../../utils/app.dart';

const chessDid = 'did:web:chess.example';
const footballDid = 'did:web:football.example';

Future<void> openCommunitiesTab(WidgetTester tester) async {
  await navigateToLocation(
    tester,
    '/contacts',
    identities: [FakeIdentities.primaryIdentity],
  );
  await tester.pumpAndSettle();
}

/// Reads the communities again, as the member pulling the list down.
Future<void> pullToRefresh(WidgetTester tester) async {
  final l10n = await getL10n();
  await tester.fling(
    find.text(l10n.communitiesSubtitle),
    const Offset(0, 400),
    1000,
  );
  await tester.pumpAndSettle();
}

Future<void> saveCommunities() async {
  final repository = SecureStorageVtcRepository();
  await repository.saveCommunity(
    const VtcCommunity(
      communityDid: chessDid,
      personaDid: 'did:key:zAda',
      contextId: 'vta',
      name: 'Chess club',
    ),
  );
  await repository.saveCommunity(
    const VtcCommunity(
      communityDid: footballDid,
      personaDid: 'did:key:zBo',
      contextId: 'vta',
      name: 'Football club',
      isMember: false,
      joinRequestId: 'request-1',
    ),
  );
}

void main() {
  group('When opening the Communities tab', () {
    testWidgets('says the member has joined none yet', (tester) async {
      final l10n = await getL10n();
      await openCommunitiesTab(tester);

      expect(find.text(l10n.communitiesSubtitle), findsOneWidget);
      expect(find.text(l10n.communitiesNone), findsOneWidget);
      expect(find.byKey(const Key('join_community_button')), findsOneWidget);
    });

    testWidgets('lists joined and pending communities', (tester) async {
      final l10n = await getL10n();
      await openCommunitiesTab(tester);

      await saveCommunities();
      await pullToRefresh(tester);

      expect(find.text('Chess club'), findsOneWidget);
      expect(find.text('Football club'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('community_$footballDid')),
          matching: find.text(l10n.communityPending),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('community_$chessDid')),
          matching: find.text(l10n.communityPending),
        ),
        findsNothing,
      );
      expect(find.text(l10n.communitiesNone), findsNothing);
    });

    testWidgets('draws each community as a panel, pending in warning', (
      tester,
    ) async {
      await openCommunitiesTab(tester);

      await saveCommunities();
      await pullToRefresh(tester);

      for (final did in [footballDid, chessDid]) {
        expect(
          find.descendant(
            of: find.byKey(Key('community_$did')),
            matching: find.byType(AppCard),
          ),
          findsOneWidget,
        );
      }
      final pending = tester.widget<StatusChip>(
        find.descendant(
          of: find.byKey(const Key('community_$footballDid')),
          matching: find.byType(StatusChip),
        ),
      );
      expect(
        pending.color,
        tester
            .element(find.byKey(const Key('community_$footballDid')))
            .mcColors
            .warning,
      );
    });

    testWidgets('opens a joined community with its channels and members', (
      tester,
    ) async {
      final l10n = await getL10n();
      await openCommunitiesTab(tester);
      await saveCommunities();
      await pullToRefresh(tester);

      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      expect(find.text('Chess club'), findsOneWidget);
      expect(find.text(l10n.contactsPanelSubtitle), findsOneWidget);
      expect(find.text(l10n.communityChannelsTab), findsOneWidget);
      expect(find.text(l10n.communityMembersTab), findsOneWidget);
      expect(find.text(l10n.noContactsYet), findsOneWidget);

      await tester.tap(find.text(l10n.communityMembersTab));
      await tester.pumpAndSettle();
      expect(
        find.text(l10n.communityMembersPrompt('Chess club')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('section_header_back')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.communitiesSubtitle), findsOneWidget);
    });

    testWidgets('signs in to a community from its page', (tester) async {
      await openCommunitiesTab(tester);
      await saveCommunities();
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('community_sign_in_button')));
      // The code scanner keeps animating, so it never settles.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(VtcSignInScreen), findsOneWidget);
    });

    testWidgets('goes back to the communities, keeping the settings menu', (
      tester,
    ) async {
      final l10n = await getL10n();
      await openCommunitiesTab(tester);
      await saveCommunities();
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('section_header_back')), findsOneWidget);
      expect(find.byIcon(McIcons.menu), findsOneWidget);

      // As the system's back button does.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(l10n.communitiesSubtitle), findsOneWidget);
      expect(find.text('Chess club'), findsOneWidget);
      expect(find.byKey(const Key('section_header_back')), findsNothing);
    });
  });
}
