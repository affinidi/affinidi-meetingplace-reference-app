import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_groups/vtc_group_members_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _me = 'did:webvh:QmMe:vta.example:me';
const _bob = 'did:webvh:QmBob:vta.example:bob';
const _carol = 'did:webvh:QmCarol:vta.example:carol';

const _group = VtcGroup(
  groupId: 'g1',
  groupDid: 'did:webvh:QmGroup:vtc.example:group-dids:g1',
  name: 'Identity WG',
  isDynamic: false,
  visibility: GroupAudience.members,
  showMembers: GroupAudience.groupMembers,
);

PublishedRelationship _edge(String id, String issuer, String subject) =>
    PublishedRelationship(
      id: id,
      issuerDid: issuer,
      subjectDid: subject,
      vrcDigestMultibase: 'zQm$id',
    );

/// A group's members and the vouches with them.
class _FakeTrustService extends Fake implements VtcTrustService {
  List<DirectoryEntry> members = const [
    DirectoryEntry(entryId: 'dir_bob', displayName: 'Bob', did: _bob),
    DirectoryEntry(entryId: 'dir_carol', displayName: 'Carol', did: _carol),
    DirectoryEntry(entryId: 'dir_dan', displayName: 'Dan'),
    DirectoryEntry(entryId: 'dir_anon', did: 'did:webvh:QmAnon:vta.example'),
  ];
  Map<String, VtcEdges> edges = {
    _bob: VtcEdges(incoming: _edge('edge-0', _bob, _me)),
    _carol: VtcEdges(outgoing: _edge('edge-1', _me, _carol)),
  };
  VtcTrustFailure? refusal;
  final List<String> vouched = [];

  @override
  Future<List<DirectoryEntry>> groupMembers(
    String communityDid, {
    required String groupId,
  }) async {
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    return members;
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
    final edge = _edge('edge-2', _me, personaDid);
    edges = {
      ...edges,
      personaDid: VtcEdges(
        outgoing: edge,
        incoming: edges[personaDid]?.incoming,
      ),
    };
    return edge;
  }
}

void main() {
  late _FakeTrustService service;

  setUp(() => service = _FakeTrustService());

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcTrustServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const VtcGroupMembersScreen(
            communityDid: _club,
            communityName: 'Football club',
            group: _group,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder inMember(String entryId, Finder finder) => find.descendant(
    of: find.byKey(Key('vtc_group_member_$entryId')),
    matching: finder,
  );

  testWidgets('lists the members with the vouches between you', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Members of Identity WG'), findsOneWidget);
    expect(inMember('dir_bob', find.text('Vouches for you')), findsOneWidget);
    expect(inMember('dir_bob', find.text('Vouch back')), findsOneWidget);
    expect(inMember('dir_carol', find.text('Vouched')), findsOneWidget);
    expect(inMember('dir_carol', find.byType(FilledButton)), findsNothing);
    expect(
      inMember(
        'dir_dan',
        find.text("Dan hasn't let members of Football club find them yet."),
      ),
      findsOneWidget,
    );
    expect(inMember('dir_dan', find.byType(FilledButton)), findsNothing);
    expect(inMember('dir_anon', find.text('Unnamed member')), findsOneWidget);
    expect(find.textContaining('did:'), findsNothing);
  });

  testWidgets('vouches back once you consent', (tester) async {
    await pumpScreen(tester);

    await tester.tap(inMember('dir_bob', find.text('Vouch back')));
    await tester.pumpAndSettle();
    expect(find.text('Vouch for Bob in Football club?'), findsOneWidget);
    await tester.tap(find.text('Vouch').last);
    await tester.pumpAndSettle();

    expect(service.vouched, [_bob]);
    expect(find.text('You vouched for Bob'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(
      inMember('dir_bob', find.text('Vouched · Vouches for you')),
      findsOneWidget,
    );
  });

  testWidgets('says when there is nobody else to show', (tester) async {
    service.members = const [];

    await pumpScreen(tester);

    expect(find.text('No other members to show.'), findsOneWidget);
  });

  testWidgets('says why the members cannot be shown', (tester) async {
    service.refusal = VtcTrustFailure.network;

    await pumpScreen(tester);

    expect(find.text("Couldn't reach Football club."), findsOneWidget);
  });
}
