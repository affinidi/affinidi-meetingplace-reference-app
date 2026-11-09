import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/communities/community_members_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _me = 'did:webvh:QmMe:vta.example:me';
const _bob = 'did:webvh:QmBob:vta.example:bob';

/// A community's directory, searched by name.
class _FakeTrustService extends Fake implements VtcTrustService {
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

void main() {
  late _FakeTrustService service;

  setUp(() => service = _FakeTrustService());

  Future<AppLocalizations> pumpView(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcTrustServiceProvider.overrideWithValue(service)],
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

  testWidgets('asks to search before showing anyone', (tester) async {
    final l10n = await pumpView(tester);

    expect(
      find.text(l10n.communityMembersPrompt('Football club')),
      findsOneWidget,
    );
    expect(service.queries, isEmpty);
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
}
