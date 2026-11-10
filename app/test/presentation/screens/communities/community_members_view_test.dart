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
const _bobEntry = DirectoryEntry(
  entryId: 'dir_bob',
  displayName: 'Bob',
  did: _bob,
  role: 'moderator',
);

/// A community's directory, where the member is not shown to other members.
class _FakeTrustService extends Fake implements VtcTrustService {
  @override
  Future<MyDirectoryCard> directoryCard(String communityDid) async =>
      const MyDirectoryCard(
        entryId: 'dir_me',
        isDidVisibleToMembers: false,
        isHidden: false,
      );

  @override
  Future<String?> identityContextId(String communityDid) async =>
      FakeIdentities.vtaContextId;

  Map<String, VtcEdges> edges = const {};
  VtcTrustFailure? refusal;
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
  Future<Map<String, VtcEdges>> edgesByMember(String communityDid) async =>
      edges;

  @override
  Future<VtcEdges> edgesWith(String communityDid, String personaDid) async =>
      edges[personaDid] ?? const VtcEdges();

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
    return edge;
  }
}

/// Tells the member's role changes in communities.
class _FakeVtcService extends Fake implements VtcService {
  final roleChanges = StreamController<VtcRoleChange>.broadcast();

  @override
  Stream<VtcRoleChange> get roleChanged => roleChanges.stream;
}

FakeIdentitiesService identities() => FakeIdentitiesService(
  IdentitiesServiceState(
    currentIdentity: FakeIdentities.vtaPrimaryIdentity,
    identities: [FakeIdentities.vtaPrimaryIdentity],
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

  Finder inMember(String entryId, Finder finder) => find.descendant(
    of: find.byKey(Key('community_member_$entryId')),
    matching: finder,
  );

  testWidgets("lists the members of the member's groups at once", (
    tester,
  ) async {
    await pumpView(tester);

    expect(inMember('dir_bea', find.text('Bea')), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
  });

  testWidgets('offers no search of the directory', (tester) async {
    await pumpView(tester);

    expect(find.byType(TextField), findsNothing);
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
    service.groupsMembers = [...service.groupsMembers, _bobEntry];

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
    service.groupsMembers = [...service.groupsMembers, _bobEntry];

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

    expect(find.textContaining(l10n.vtcGroupMembersNone), findsOneWidget);
  });

  testWidgets('says why the community did not answer', (tester) async {
    service.refusal = VtcTrustFailure.network;
    final l10n = await pumpView(tester);

    expect(
      find.text(
        l10n.vtcTrustFailure(VtcTrustFailure.network.name, 'Football club', ''),
      ),
      findsOneWidget,
    );
  });

  testWidgets('vouches for a member listed, once the member consents', (
    tester,
  ) async {
    service.groupsMembers = [...service.groupsMembers, _bobEntry];
    final l10n = await pumpView(tester);
    final listings = service.listings;

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
      inMember(
        'dir_bob',
        find.byTooltip('You vouched for Bob. Waiting for them to vouch back.'),
      ),
      findsOneWidget,
    );
    // Shown from the vouch itself: the members were not read again.
    expect(service.listings, listings);
  });

  testWidgets('shows the vouches as read again once opened', (tester) async {
    const mine = PublishedRelationship(
      id: 'edge-1',
      issuerDid: _me,
      subjectDid: _bob,
      vrcDigestMultibase: 'zQmedge-1',
    );
    service
      ..groupsMembers = [...service.groupsMembers, _bobEntry]
      ..edges = {_bob: const VtcEdges(outgoing: mine)};
    final l10n = await pumpView(tester);
    final listings = service.listings;
    // Bob vouched back since the members were read.
    service.edges = {
      _bob: const VtcEdges(
        outgoing: mine,
        incoming: PublishedRelationship(
          id: 'edge-2',
          issuerDid: _bob,
          subjectDid: _me,
          vrcDigestMultibase: 'zQmedge-2',
        ),
      ),
    };

    await tester.tap(inMember('dir_bob', find.byKey(const Key('vtc_vouches'))));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(
      inMember(
        'dir_bob',
        find.byTooltip(l10n.vtcTrustVouchedForEachOther('Bob')),
      ),
      findsOneWidget,
    );
    expect(service.listings, listings);
  });

  testWidgets('lets the member choose whether other members find them', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.byType(VtcFindableView), findsOneWidget);
  });
}
