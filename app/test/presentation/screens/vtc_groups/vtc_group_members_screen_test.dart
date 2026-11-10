import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_groups/vtc_group_members_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _me = 'did:webvh:QmMe:vta.example:me';
const _bob = 'did:webvh:QmBob:vta.example:bob';
const _carol = 'did:webvh:QmCarol:vta.example:carol';
const _dan = 'did:webvh:QmDan:vta.example:dan';

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
  /// Pictures by the digest a member's entry names.
  Map<String, Uint8List> memberPictures = {};

  @override
  Future<Uint8List?> memberPicture(
    String communityDid, {
    required DirectoryEntry entry,
  }) async => memberPictures[entry.avatarSha256];
  List<DirectoryEntry> members = const [
    DirectoryEntry(
      entryId: 'dir_bob',
      displayName: 'Bob',
      did: _bob,
      role: 'moderator',
    ),
    DirectoryEntry(
      entryId: 'dir_carol',
      displayName: 'Carol',
      did: _carol,
      role: 'custom:coach',
    ),
    DirectoryEntry(
      entryId: 'dir_dan',
      displayName: 'Dan',
      did: _dan,
      role: 'member',
    ),
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
    return _edge('edge-2', _me, personaDid);
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
    expect(
      inMember('dir_bob', find.byTooltip('Bob vouched for you')),
      findsOneWidget,
    );
    expect(inMember('dir_bob', find.text('Vouch back')), findsOneWidget);
    expect(
      inMember(
        'dir_carol',
        find.byTooltip(
          'You vouched for Carol. Waiting for them to vouch back.',
        ),
      ),
      findsOneWidget,
    );
    expect(
      inMember('dir_dan', find.byKey(const Key('vtc_vouches'))),
      findsNothing,
    );
    expect(inMember('dir_carol', find.byType(FilledButton)), findsNothing);
    expect(inMember('dir_dan', find.text('Vouch')), findsOneWidget);
    expect(inMember('dir_anon', find.text('Unnamed member')), findsOneWidget);
    expect(find.textContaining('did:'), findsNothing);
  });

  testWidgets('marks a vouch that waits for the other member to vouch back', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(inMember('dir_carol', find.byIcon(McIcons.pending)), findsOneWidget);
    expect(inMember('dir_bob', find.byIcon(McIcons.pending)), findsNothing);

    await tester.tap(inMember('dir_bob', find.text('Vouch back')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vouch').last);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Vouched for each other: nothing left to wait for.
    expect(inMember('dir_bob', find.byIcon(McIcons.pending)), findsNothing);
  });

  testWidgets('aligns the icons right of every member\'s name', (tester) async {
    await pumpScreen(tester);

    for (final entryId in ['dir_bob', 'dir_carol', 'dir_dan', 'dir_anon']) {
      expect(
        inMember(entryId, find.byKey(const Key('vtc_member_credentials'))),
        findsOneWidget,
      );
    }
    final name = tester.getTopRight(inMember('dir_bob', find.text('Bob')));
    final vouches = tester.getCenter(
      inMember('dir_bob', find.byKey(const Key('vtc_vouches'))),
    );
    final credentials = tester.getCenter(
      inMember('dir_bob', find.byKey(const Key('vtc_member_credentials'))),
    );
    expect(vouches.dx, greaterThan(name.dx));
    expect(credentials.dx, greaterThan(vouches.dx));
    // Right-aligned: Carol's icons line up with Bob's, whatever the names.
    expect(
      tester
          .getCenter(
            inMember(
              'dir_carol',
              find.byKey(const Key('vtc_member_credentials')),
            ),
          )
          .dx,
      moreOrLessEquals(credentials.dx),
    );
  });

  testWidgets('shows each member\'s role under their name', (tester) async {
    await pumpScreen(tester);

    expect(inMember('dir_bob', find.text('Moderator')), findsOneWidget);
    expect(
      inMember('dir_carol', find.text('coach')),
      findsOneWidget,
      reason: 'a role the community defined, by its own name',
    );
    expect(inMember('dir_dan', find.text('Member')), findsOneWidget);
    expect(
      inMember('dir_anon', find.byKey(const Key('vtc_member_role_dir_anon'))),
      findsNothing,
      reason: 'no role shown, none drawn',
    );
  });

  testWidgets('shows the picture a member shows, else a person', (
    tester,
  ) async {
    service
      ..members = const [
        DirectoryEntry(
          entryId: 'dir_bob',
          displayName: 'Bob',
          did: _bob,
          avatarSha256: 'sha-bob',
        ),
        DirectoryEntry(entryId: 'dir_carol', displayName: 'Carol', did: _carol),
      ]
      ..memberPictures = {
        'sha-bob': img.encodePng(img.Image(width: 4, height: 4)),
      };

    await pumpScreen(tester);

    expect(
      inMember('dir_bob', find.byKey(const Key('vtc_member_avatar_dir_bob'))),
      findsOneWidget,
    );
    expect(inMember('dir_carol', find.byType(CircleAvatar)), findsNothing);
    expect(inMember('dir_carol', find.byIcon(McIcons.person)), findsOneWidget);
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
    // Shown from the vouch itself: the fake's vouches never change.
    expect(inMember('dir_bob', find.text('Vouch back')), findsNothing);
    expect(
      inMember('dir_bob', find.byTooltip('You and Bob vouched for each other')),
      findsOneWidget,
    );

    await tester.tap(inMember('dir_bob', find.byKey(const Key('vtc_vouches'))));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('vtc_vouch_trail_outgoing')), findsOneWidget);
    expect(find.byKey(const Key('vtc_vouch_trail_incoming')), findsOneWidget);
  });

  testWidgets('draws a member by their picture in a vouch\'s diagram', (
    tester,
  ) async {
    service
      ..members = const [
        DirectoryEntry(
          entryId: 'dir_bob',
          displayName: 'Bob',
          did: _bob,
          avatarSha256: 'sha-bob',
        ),
      ]
      ..memberPictures = {
        'sha-bob': img.encodePng(img.Image(width: 4, height: 4)),
      }
      ..edges = {
        _bob: const VtcEdges(
          incoming: PublishedRelationship(
            id: 'edge-0',
            issuerDid: _bob,
            subjectDid: _me,
            vrcDigestMultibase: 'zQm0',
          ),
        ),
      };
    await pumpScreen(tester);

    await tester.tap(inMember('dir_bob', find.byKey(const Key('vtc_vouches'))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vtc_vouch_vouched')));
    await tester.pumpAndSettle();

    Finder pictured(Finder of) => find.descendant(
      of: of,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).image != null,
      ),
    );
    final flow = find.byKey(const Key('vtc_vouch_flow_vouched'));
    expect(pictured(flow), findsOneWidget, reason: 'Bob, by his picture');
    expect(
      find.descendant(of: flow, matching: find.byIcon(McIcons.person)),
      findsOneWidget,
      reason: 'you, without one, as a person',
    );
  });

  testWidgets('opens the signed vouch a member gave you', (tester) async {
    service.edges = {
      _bob: const VtcEdges(
        incoming: PublishedRelationship(
          id: 'edge-0',
          issuerDid: _bob,
          subjectDid: _me,
          vrcDigestMultibase: 'zQm0',
          vrc: {
            'type': ['VerifiableCredential', 'RelationshipCredential'],
            'issuer': _bob,
          },
        ),
      ),
    };
    await pumpScreen(tester);

    await tester.tap(inMember('dir_bob', find.byKey(const Key('vtc_vouches'))));
    await tester.pumpAndSettle();

    expect(find.text('Bob vouched for you'), findsOneWidget);
    expect(find.text("Signed by Bob's VTA"), findsOneWidget);
    expect(
      find.text('As the identity Bob joined Football club with.'),
      findsOneWidget,
    );

    // Pictured once a step is opened: who passed what to whom.
    List<String> flow(String step) {
      final texts = find.descendant(
        of: find.byKey(Key('vtc_vouch_flow_$step')),
        matching: find.byType(Text),
      );
      final found = [
        for (final element in texts.evaluate())
          (
            tester.getCenter(find.byWidget(element.widget)).dx,
            (element.widget as Text).data!,
          ),
      ]..sort((a, b) => a.$1.compareTo(b.$1));
      return [for (final (_, text) in found) text];
    }

    Future<void> expand(String step) async {
      final finder = find.byKey(Key('vtc_vouch_$step'));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const Key('vtc_vouch_flow_vouched')), findsNothing);
    await expand('vouched');
    expect(flow('vouched'), ['Bob', 'You']);
    await expand('signed');
    expect(flow('signed'), ["Bob's VTA", 'Bob']);
    expect(find.text(VtaTask.signDocument), findsOneWidget);
    await expand('stored');
    expect(flow('stored'), ['Bob', 'Football club']);
    expect(find.text(RelationshipTask.publish), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('vtc_vouch_record')));
    await tester.tap(find.byKey(const Key('vtc_vouch_record')));
    await tester.pumpAndSettle();
    expect(find.textContaining('vrcJsonld'), findsWidgets);
    expect(find.textContaining('edge-0'), findsWidgets);
  });

  testWidgets('says when there is nobody else to show', (tester) async {
    service.members = const [];

    await pumpScreen(tester);

    expect(find.textContaining('No other members to show.'), findsOneWidget);
    expect(
      find.textContaining('chose not to be listed in the directory'),
      findsOneWidget,
    );
  });

  testWidgets('says that unlisted members are not shown', (tester) async {
    await pumpScreen(tester);

    expect(
      find.text(
        'Members who chose not to be listed in the directory of Football '
        "club aren't shown.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('says why the members cannot be shown', (tester) async {
    service.refusal = VtcTrustFailure.network;

    await pumpScreen(tester);

    expect(find.text("Couldn't reach Football club."), findsOneWidget);
  });
}
