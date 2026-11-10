import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_role_change.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/community_members_view.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_findable_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _me = 'did:webvh:QmMe:vta.example:me';
const _bob = 'did:webvh:QmBob:vta.example:bob';

/// A community's directory, searched by name, where the member is not shown
/// to other members.
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

  List<DirectoryEntry> members = const [
    DirectoryEntry(
      entryId: 'dir_bob',
      displayName: 'Bob',
      did: _bob,
      role: 'moderator',
    ),
    DirectoryEntry(entryId: 'dir_bea', displayName: 'Bea', role: 'member'),
  ];
  Map<String, VtcEdges> edges = const {};
  VtcTrustFailure? refusal;
  final List<String> queries = [];
  final List<String> vouched = [];

  @override
  Future<Uint8List?> memberPicture(
    String communityDid, {
    required DirectoryEntry entry,
  }) async => null;

  /// The members of the member's groups.
  List<DirectoryEntry> groupsMembers = const [
    DirectoryEntry(entryId: 'dir_bea', displayName: 'Bea', role: 'member'),
  ];

  /// How often the members of the member's groups were read.
  int listings = 0;

  /// Holds the members of the member's groups back until completed.
  Completer<void>? listingGate;

  @override
  Future<List<DirectoryEntry>> communityMembers(String communityDid) async {
    listings++;
    await listingGate?.future;
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    return groupsMembers;
  }

  @override
  Future<List<DirectoryEntry>> findMembers(
    String communityDid, {
    required String query,
  }) async {
    queries.add(query);
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    return [
      for (final member in members)
        if (member.displayName!.toLowerCase().contains(query.toLowerCase()))
          member,
    ];
  }

  @override
  Future<Map<String, VtcEdges>> edgesByMember(String communityDid) async =>
      edges;

  @override
  Future<PublishedRelationship> vouch(
    String communityDid, {
    required String personaDid,
  }) async {
    vouched.add(personaDid);
    final edge = PublishedRelationship(
      id: 'edge-1',
      issuerDid: _me,
      subjectDid: personaDid,
      vrcDigestMultibase: 'zQmedge-1',
    );
    edges = {personaDid: VtcEdges(outgoing: edge)};
    return edge;
  }
}

/// Tells the member's role changes in communities, and whether they may vet.
class _FakeVtcService extends Fake implements VtcService {
  final roleChanges = StreamController<VtcRoleChange>.broadcast();
  final cardChanges = StreamController<void>.broadcast();

  /// Whether the member holds a vetter card for the community.
  bool isVetter = false;

  /// Why checking the vetter card fails, if it does.
  Exception? vetterCheckFailure;

  @override
  Stream<VtcRoleChange> get roleChanged => roleChanges.stream;

  @override
  Stream<void> get membershipsChanged => cardChanges.stream;

  @override
  Future<bool> canVet(String communityDid) async {
    if (vetterCheckFailure case final failure?) throw failure;
    return isVetter;
  }
}

FakeIdentitiesService identities() => FakeIdentitiesService(
  IdentitiesServiceState(
    currentIdentity: FakeIdentities.primaryIdentity,
    identities: [FakeIdentities.primaryIdentity],
  ),
);

void main() {
  late _FakeTrustService service;
  late _FakeVtcService vtc;

  setUp(() {
    service = _FakeTrustService();
    vtc = _FakeVtcService();
  });

  Future<AppLocalizations> pumpView(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcTrustServiceProvider.overrideWithValue(service),
          vtcServiceProvider.overrideWithValue(vtc),
          identitiesServiceProvider.overrideWith(identities),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: CommunityMembersView(
              communityDid: _club,
              communityName: 'Football club',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.of(
      tester.element(find.byType(CommunityMembersView)),
    )!;
  }

  /// Opens the Members tab with [container], which keeps what the app
  /// keeps between visits, or shows something else in its place.
  Future<void> showTab(
    WidgetTester tester,
    ProviderContainer container, {
    bool open = true,
  }) => tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: open
              ? const CommunityMembersView(
                  communityDid: _club,
                  communityName: 'Football club',
                )
              : const SizedBox.shrink(),
        ),
      ),
    ),
  );

  ProviderContainer keptMembers() {
    final container = ProviderContainer(
      overrides: [
        vtcTrustServiceProvider.overrideWithValue(service),
        vtcServiceProvider.overrideWithValue(vtc),
        identitiesServiceProvider.overrideWith(identities),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> search(WidgetTester tester, String text) async {
    await tester.enterText(
      find.byKey(const Key('community_members_search_field')),
      text,
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
  }

  Finder inMember(String entryId, Finder finder) => find.descendant(
    of: find.byKey(Key('community_member_$entryId')),
    matching: finder,
  );

  testWidgets("lists the members of the member's groups at once", (
    tester,
  ) async {
    final l10n = await pumpView(tester);

    expect(inMember('dir_bea', find.text('Bea')), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
    expect(
      find.text(l10n.communityMembersPrompt('Football club')),
      findsOneWidget,
    );
    expect(service.queries, isEmpty);
  });

  testWidgets('reads the members once when first opened', (tester) async {
    await pumpView(tester);

    expect(service.listings, 1);
  });

  testWidgets('shows the kept members at once and syncs them on opening', (
    tester,
  ) async {
    final container = keptMembers();
    await showTab(tester, container);
    await tester.pumpAndSettle();
    await showTab(tester, container, open: false);
    service.groupsMembers = [...service.groupsMembers, service.members.first];

    await showTab(tester, container);

    // Kept from before, while the community is asked again.
    expect(inMember('dir_bea', find.text('Bea')), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpAndSettle();
    expect(inMember('dir_bob', find.text('Bob')), findsOneWidget);
    expect(service.listings, 2);
  });

  testWidgets('shows that the kept members are being synced', (tester) async {
    final container = keptMembers();
    await showTab(tester, container);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('community_members_syncing')), findsNothing);
    await showTab(tester, container, open: false);
    service.listingGate = Completer();

    await showTab(tester, container);
    await tester.pump();

    expect(find.byKey(const Key('community_members_syncing')), findsOneWidget);
    expect(inMember('dir_bea', find.text('Bea')), findsOneWidget);
    service.listingGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('community_members_syncing')), findsNothing);
  });

  testWidgets("syncs the members when the member's role there changes", (
    tester,
  ) async {
    await pumpView(tester);
    service.groupsMembers = [...service.groupsMembers, service.members.first];

    vtc.roleChanges
      ..add(const VtcRoleChange(communityDid: 'did:web:other', role: 'admin'))
      ..add(const VtcRoleChange(communityDid: _club, role: 'admin'));
    await tester.pumpAndSettle();

    expect(service.listings, 2);
    expect(inMember('dir_bob', find.text('Bob')), findsOneWidget);
  });

  testWidgets('keeps the members when syncing them fails', (tester) async {
    final container = keptMembers();
    await showTab(tester, container);
    await tester.pumpAndSettle();
    await showTab(tester, container, open: false);
    service.refusal = VtcTrustFailure.network;

    await showTab(tester, container);
    await tester.pumpAndSettle();

    expect(service.listings, 2);
    expect(inMember('dir_bea', find.text('Bea')), findsOneWidget);
  });

  testWidgets('says when the groups show nobody else', (tester) async {
    service.groupsMembers = const [];
    final l10n = await pumpView(tester);
    await search(tester, 'bob');

    await search(tester, ' ');

    expect(find.textContaining(l10n.vtcGroupMembersNone), findsOneWidget);
  });

  testWidgets("shows the groups' members again after an empty search", (
    tester,
  ) async {
    await pumpView(tester);
    await search(tester, 'bob');
    expect(find.text('Bea'), findsNothing);

    await search(tester, '');

    expect(inMember('dir_bea', find.text('Bea')), findsOneWidget);
  });

  testWidgets('lists the members the directory finds', (tester) async {
    final l10n = await pumpView(tester);

    await search(tester, ' bob ');

    expect(service.queries, ['bob']);
    expect(inMember('dir_bob', find.text('Bob')), findsOneWidget);
    expect(find.text('Bea'), findsNothing);
    expect(
      find.text(l10n.vtcGroupMembersUnlistedNote('Football club')),
      findsOneWidget,
    );
  });

  testWidgets('asks for a longer search, without asking the community', (
    tester,
  ) async {
    final l10n = await pumpView(tester);

    await search(tester, 'bo');

    expect(service.queries, isEmpty);
    expect(
      find.text(
        l10n.vtcTrustFailure(
          VtcTrustFailure.searchTooShort.name,
          'Football club',
          'bo',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('says why the community did not answer', (tester) async {
    final l10n = await pumpView(tester);
    service.refusal = VtcTrustFailure.network;

    await search(tester, 'bob');

    expect(
      find.text(
        l10n.vtcTrustFailure(
          VtcTrustFailure.network.name,
          'Football club',
          'bob',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('vouches for a member found, once the member consents', (
    tester,
  ) async {
    final l10n = await pumpView(tester);
    await search(tester, 'bob');

    await tester.tap(inMember('dir_bob', find.text(l10n.vtcTrustVouch)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('vtc_vouch_consent')), findsOneWidget);
    await tester.tap(find.text(l10n.vtcTrustVouch).last);
    await tester.pumpAndSettle();

    expect(service.vouched, [_bob]);
    // Close the vouch's story to see the member again.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(inMember('dir_bob', find.text(l10n.vtcTrustVouch)), findsNothing);
    expect(
      inMember('dir_bob', find.byTooltip('You vouched for Bob')),
      findsOneWidget,
    );
  });

  group('vetting', () {
    const vettingDesk = Key('community_members_vetting_desk');

    testWidgets('offers a vetter to vet applicants', (tester) async {
      vtc.isVetter = true;

      final l10n = await pumpView(tester);

      expect(
        find.descendant(
          of: find.byKey(vettingDesk),
          matching: find.text(l10n.vtcVetterStart),
        ),
        findsOneWidget,
      );
    });

    testWidgets('offers no vetting to a member who is not a vetter', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.byKey(vettingDesk), findsNothing);
    });

    testWidgets('offers no vetting when the vetter card cannot be checked', (
      tester,
    ) async {
      vtc
        ..isVetter = true
        ..vetterCheckFailure = Exception('VTA unreachable');

      await pumpView(tester);

      expect(find.byKey(vettingDesk), findsNothing);
    });

    testWidgets('offers vetting once the community makes the member a vetter', (
      tester,
    ) async {
      await pumpView(tester);
      expect(find.byKey(vettingDesk), findsNothing);

      vtc
        ..isVetter = true
        ..cardChanges.add(null);
      await tester.pumpAndSettle();

      expect(find.byKey(vettingDesk), findsOneWidget);
    });
  });

  testWidgets('lets the member choose whether other members find them', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.byType(VtcFindableView), findsOneWidget);
  });
}
