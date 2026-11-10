import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_removal.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/build_context_extensions.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/community_members_view.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/community_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/community_tabs_providers.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/removal_notice.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/credentials/membership_credentials_list.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_findable_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_vetting_desk/vtc_vetting_desk_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/common/hairline_grid.dart';

import '../../../fakes/fake_identities.dart';
import '../../../utils/app.dart';

const chessDid = 'did:web:chess.example';
const footballDid = 'did:web:football.example';

Future<void> openCommunitiesTab(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  await navigateToLocation(
    tester,
    '/contacts',
    identities: [FakeIdentities.vtaPrimaryIdentity],
    overrides: overrides,
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

/// The member's directory card, recording the names sent to it.
class _FakeTrustService extends Fake implements VtcTrustService {
  _FakeTrustService({required this.findable});

  final bool findable;
  final List<String> names = [];

  @override
  Future<MyDirectoryCard> directoryCard(String communityDid) async =>
      MyDirectoryCard(
        entryId: 'dir_me',
        isDidVisibleToMembers: findable,
        isHidden: false,
      );

  @override
  Future<String?> identityContextId(String communityDid) async =>
      FakeIdentities.vtaContextId;

  @override
  Future<void> setDirectoryName(
    String communityDid, {
    required String name,
  }) async => names.add(name);

  @override
  Future<List<DirectoryEntry>> communityMembers(String communityDid) async =>
      const [];
}

void main() {
  group('When opening the Communities tab', () {
    testWidgets('invites a member with no community to join one', (
      tester,
    ) async {
      final l10n = await getL10n();
      await openCommunitiesTab(tester);

      expect(find.text(l10n.communitiesSubtitle), findsOneWidget);
      expect(find.text(l10n.communitiesNone), findsOneWidget);
      expect(find.text(l10n.communitiesJoinHint), findsOneWidget);
      expect(find.byKey(const Key('join_community_cta')), findsOneWidget);
      // One way to join, not two.
      expect(find.byKey(const Key('join_community_button')), findsNothing);
    });

    testWidgets('joins a community from the call to action', (tester) async {
      await openCommunitiesTab(tester);

      await tester.tap(find.byKey(const Key('join_community_cta')));
      await tester.pumpAndSettle();

      expect(find.byType(VtcJoinScreen), findsOneWidget);
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
      expect(find.byKey(const Key('join_community_cta')), findsNothing);
      expect(find.byKey(const Key('join_community_button')), findsOneWidget);
    });

    testWidgets(
      'draws the communities as a hairline grid, pending in warning',
      (tester) async {
        await openCommunitiesTab(tester);

        await saveCommunities();
        await pullToRefresh(tester);

        for (final did in [footballDid, chessDid]) {
          expect(
            find.ancestor(
              of: find.byKey(Key('community_$did')),
              matching: find.byType(HairlineGrid),
            ),
            findsOneWidget,
          );
        }
        // Two to a row on a phone held upright.
        final chess = tester.getTopLeft(
          find.byKey(const Key('community_$chessDid')),
        );
        final football = tester.getTopLeft(
          find.byKey(const Key('community_$footballDid')),
        );
        expect(football.dy, chess.dy);
        // The logo sits centred in its cell.
        final chessCell = find.byKey(const Key('community_$chessDid'));
        expect(
          tester
              .getCenter(
                find.descendant(
                  of: chessCell,
                  matching: find.byIcon(McIcons.community),
                ),
              )
              .dx,
          tester.getCenter(chessCell).dx,
        );
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
      },
    );

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
      expect(find.text(l10n.communityChannelsTab), findsOneWidget);
      expect(find.text(l10n.communityMembersTab), findsOneWidget);
      expect(find.text(l10n.noContactsYet), findsOneWidget);
      // Channels are not filtered by kind.
      for (final kind in ['Any', 'Person', 'Group', 'AI Agent']) {
        expect(find.text(kind), findsNothing, reason: kind);
      }

      await tester.tap(find.text(l10n.communityMembersTab));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityMembersView), findsOneWidget);

      await tester.tap(find.byKey(const Key('section_header_back')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.communitiesSubtitle), findsOneWidget);
    });

    testWidgets('closes a community that removed the member, saying why', (
      tester,
    ) async {
      final l10n = await getL10n();
      final removals = StreamController<VtcRemoval>.broadcast();
      addTearDown(removals.close);
      await openCommunitiesTab(
        tester,
        overrides: [vtcRemovalsProvider.overrideWith((ref) => removals.stream)],
      );
      await saveCommunities();
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      removals.add(
        const VtcRemoval(
          communityDid: chessDid,
          name: 'Chess club',
          reason: 'Spam.',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CommunityScreen), findsNothing);
      expect(find.text(l10n.communitiesSubtitle), findsOneWidget);
      expect(
        find.text(l10n.vtcRemovedWithReason('Chess club', 'Spam.')),
        findsOneWidget,
      );
    });

    testWidgets('stays on a community when another removed the member', (
      tester,
    ) async {
      final removals = StreamController<VtcRemoval>.broadcast();
      addTearDown(removals.close);
      await openCommunitiesTab(
        tester,
        overrides: [vtcRemovalsProvider.overrideWith((ref) => removals.stream)],
      );
      await saveCommunities();
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      removals.add(const VtcRemoval(communityDid: footballDid));
      await tester.pumpAndSettle();

      expect(find.byType(CommunityScreen), findsOneWidget);
    });

    testWidgets('reads whether members find the member on opening it', (
      tester,
    ) async {
      await openCommunitiesTab(tester);
      await saveCommunities();
      await pullToRefresh(tester);

      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      // Before the Members tab is opened.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CommunityScreen)),
      );
      expect(container.exists(vtcFindableControllerProvider(chessDid)), isTrue);
    });

    Future<_FakeTrustService> openChessClub(
      WidgetTester tester, {
      required bool findable,
    }) async {
      final service = _FakeTrustService(findable: findable);
      await openCommunitiesTab(
        tester,
        overrides: [vtcTrustServiceProvider.overrideWithValue(service)],
      );
      await saveCommunities();
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();
      return service;
    }

    testWidgets(
      'shows a findable member to others under their name on opening it',
      (tester) async {
        final service = await openChessClub(tester, findable: true);

        // Before the Members tab is opened.
        expect(service.names, [
          FakeIdentities.vtaPrimaryIdentity.card.displayName.trim(),
        ]);
      },
    );

    testWidgets('sends no name for a member who is not findable', (
      tester,
    ) async {
      final service = await openChessClub(tester, findable: false);

      expect(service.names, isEmpty);
    });

    testWidgets('reads what its other tabs show on opening it', (tester) async {
      await openCommunitiesTab(tester);
      await saveCommunities();
      await pullToRefresh(tester);

      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      // Before the Membership tab is opened.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CommunityScreen)),
      );
      expect(container.exists(communityRoleProvider(chessDid)), isTrue);
      expect(
        container.exists(communityMembershipCardProvider(chessDid)),
        isTrue,
      );
      expect(container.exists(communityInfoProvider(chessDid)), isTrue);
    });

    testWidgets('shows a vetter their vetting desk in a tab of its own', (
      tester,
    ) async {
      final l10n = await getL10n();
      await openCommunitiesTab(
        tester,
        overrides: [
          communityCanVetProvider(chessDid).overrideWith((ref) async => true),
        ],
      );
      await saveCommunities();
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.communityVettingTab));
      await tester.pumpAndSettle();

      expect(find.byType(VtcVettingDeskView), findsOneWidget);
    });

    testWidgets('shows a known vetter the Vetting tab before the VTA answers', (
      tester,
    ) async {
      final l10n = await getL10n();
      final answer = Completer<bool>();
      await openCommunitiesTab(
        tester,
        overrides: [
          communityCanVetProvider(
            chessDid,
          ).overrideWith((ref) => answer.future),
        ],
      );
      await saveCommunities();
      final repository = SecureStorageVtcRepository();
      final chess = await repository.findCommunity(chessDid);
      await repository.saveCommunity(chess!.withVetter(isVetter: true));
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.communityVettingTab), findsOneWidget);

      answer.complete(false);
      await tester.pumpAndSettle();

      expect(find.text(l10n.communityVettingTab), findsNothing);
    });

    testWidgets('offers no Vetting tab to a member who is not a vetter', (
      tester,
    ) async {
      final l10n = await getL10n();
      await openCommunitiesTab(
        tester,
        overrides: [
          communityCanVetProvider(chessDid).overrideWith((ref) async => false),
        ],
      );
      await saveCommunities();
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      expect(find.text(l10n.communityMembershipTab), findsOneWidget);
      expect(find.text(l10n.communityVettingTab), findsNothing);
    });

    testWidgets('shows what a community is about under its name', (
      tester,
    ) async {
      final l10n = await getL10n();
      await openCommunitiesTab(
        tester,
        overrides: [
          communityInfoProvider(chessDid).overrideWith(
            (ref) async => (
              CommunityProfile(
                communityDid: chessDid,
                description: 'Chess for everyone',
                website: Uri.parse('https://chess.example/club'),
                contactEmail: 'hello@chess.example',
              ),
              null,
            ),
          ),
        ],
      );
      await saveCommunities();
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      expect(find.text('Chess for everyone'), findsOneWidget);
      expect(find.text('Info'), findsNothing);
      // Folded away until the description is tapped.
      expect(find.text('https://chess.example/club'), findsNothing);

      await tester.tap(find.byKey(const Key('section_header_details_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('https://chess.example/club'), findsOneWidget);
      expect(find.text('hello@chess.example'), findsOneWidget);
      expect(find.text(l10n.communityDidLabel), findsOneWidget);
      // Shown once: under the name, not again in what unfolds.
      expect(find.text('Chess for everyone'), findsOneWidget);
      expect(find.text(l10n.communityInfoUnavailable), findsNothing);

      await tester.tap(find.byKey(const Key('section_header_details_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('https://chess.example/club'), findsNothing);
    });

    testWidgets("unfolds a community's DID under its description", (
      tester,
    ) async {
      final l10n = await getL10n();
      await openCommunitiesTab(tester);
      await saveCommunities();
      await pullToRefresh(tester);
      await tester.tap(find.text('Chess club'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('section_header_details_toggle')));
      await tester.pumpAndSettle();

      expect(find.text(l10n.vtcJoinProfileHeading), findsOneWidget);
      expect(find.text(l10n.communityDidLabel), findsOneWidget);
      expect(find.textContaining('chess.example'), findsOneWidget);
      // The test community publishes no profile; its DID shows regardless.
      expect(find.text(l10n.communityInfoUnavailable), findsOneWidget);
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
