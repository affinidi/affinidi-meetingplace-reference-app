import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_member_link.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_trust/vtc_contact_trust_panel.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _chess = 'did:webvh:QmChess:vtc.example';
const _me = 'did:webvh:QmMe:vta.example:me';
const _bob = 'did:webvh:QmBob:vta.example:bob';
const _channel = 'did:web:mpx.example:channel-bob';

/// The member's communities and vouches, as vouching for a contact asks
/// them.
class _FakeTrustService extends Fake implements VtcTrustService {
  /// Pictures by the digest a member's entry names.
  Map<String, Uint8List> memberPictures = {};

  @override
  Future<Uint8List?> memberPicture(
    String communityDid, {
    required DirectoryEntry entry,
  }) async => memberPictures[entry.avatarSha256];
  List<VtcCommunity> memberOf = const [
    VtcCommunity(
      communityDid: _club,
      personaDid: _me,
      contextId: 'vta',
      name: 'Football club',
    ),
  ];
  final List<VtcMemberLink> stored = [];
  List<DirectoryEntry> found = const [
    DirectoryEntry(entryId: 'dir_bob', displayName: 'Bob Meyer', did: _bob),
  ];
  PublishedRelationship? outgoing;
  PublishedRelationship? incoming;
  VtcTrustFailure? refusal;
  final List<String> vouched = [];

  /// Holds vouching and withdrawing back until completed.
  Completer<void>? held;
  final List<String> withdrawn = [];

  @override
  Future<List<VtcCommunity>> communities() async => memberOf;

  @override
  Future<List<VtcMemberLink>> links(String channelDid) async => [
    ...stored.where((link) => link.channelDid == channelDid),
  ];

  @override
  Future<List<DirectoryEntry>> findMembers(
    String communityDid, {
    required String query,
  }) async => found;

  @override
  Future<VtcMemberLink> link({
    required String channelDid,
    required String communityDid,
    required DirectoryEntry entry,
  }) async {
    final link = VtcMemberLink(
      communityDid: communityDid,
      channelDid: channelDid,
      entryId: entry.entryId,
      personaDid: entry.did!,
      name: entry.displayName ?? '',
      linkedAt: DateTime.utc(2026, 11, 9),
    );
    stored.add(link);
    return link;
  }

  @override
  Future<VtcEdges> edgesWith(String communityDid, String personaDid) async =>
      VtcEdges(outgoing: outgoing, incoming: incoming);

  @override
  Future<PublishedRelationship> vouch(
    String communityDid, {
    required String personaDid,
  }) async {
    await held?.future;
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    vouched.add(personaDid);
    // Not kept as [outgoing]: the panel shows it from what this returns.
    return PublishedRelationship(
      id: 'edge-1',
      issuerDid: _me,
      subjectDid: personaDid,
      vrcDigestMultibase: 'zQm1',
      vrc: const {'type': 'VerifiableCredential'},
    );
  }

  @override
  Future<void> withdraw(String communityDid, PublishedRelationship edge) async {
    await held?.future;
    withdrawn.add(edge.id);
    outgoing = null;
  }
}

void main() {
  late _FakeTrustService service;

  setUp(() => service = _FakeTrustService());

  VtcMemberLink linkToBob([String community = _club]) => VtcMemberLink(
    communityDid: community,
    channelDid: _channel,
    entryId: 'dir_bob',
    personaDid: _bob,
    name: 'Bob Meyer',
    linkedAt: DateTime.utc(2026, 11, 9),
  );

  Future<void> pumpPanel(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcTrustServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: VtcContactTrustPanel(
                channelDid: _channel,
                contactName: 'Bob',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  testWidgets('stays hidden while the member is in no community', (
    tester,
  ) async {
    service.memberOf = const [];

    await pumpPanel(tester);

    expect(find.byKey(const Key('vtc_community_trust')), findsNothing);
  });

  testWidgets('finds the contact, asks consent and vouches', (tester) async {
    await pumpPanel(tester);
    expect(find.text('Community trust'), findsOneWidget);

    await tapText(tester, 'Vouch in a community');

    expect(find.text('Find Bob in Football club'), findsOneWidget);

    await tapText(tester, 'Bob Meyer');
    expect(find.text('Is this Bob?'), findsOneWidget);
    await tapText(tester, "Yes, that's them");

    expect(find.text('Vouch for Bob in Football club?'), findsOneWidget);
    expect(
      find.textContaining('see what the other shares with their connections'),
      findsOneWidget,
    );
    await tapText(tester, 'Vouch');

    expect(service.vouched, [_bob]);
    expect(find.text('You vouched for Bob'), findsOneWidget);
    expect(find.text('Signed by your VTA'), findsOneWidget);
    expect(find.text('Stored by Football club'), findsOneWidget);
    expect(service.stored.single.personaDid, _bob);

    await tester.tap(find.byKey(const Key('vtc_vouch_record')));
    await tester.pumpAndSettle();

    expect(find.text('What Football club keeps'), findsOneWidget);
    expect(find.textContaining('vrcJsonld'), findsWidgets);
    expect(find.textContaining('edge-1'), findsWidgets);
  });

  testWidgets('shows that it is vouching until it is done', (tester) async {
    final held = service.held = Completer<void>();
    service.stored.add(linkToBob());
    await pumpPanel(tester);

    await tapText(tester, 'Vouch');
    await tester.tap(find.text('Vouch').last);
    // Not settled: the progress indicator spins while vouching.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('vtc_vouch_progress')), findsOneWidget);
    expect(find.text('Vouching for Bob…'), findsOneWidget);
    expect(
      find.text('Your VTA signs it, then Football club stores it.'),
      findsOneWidget,
    );

    held.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vtc_vouch_progress')), findsNothing);
    expect(find.text('You vouched for Bob'), findsOneWidget);
  });

  testWidgets('publishes nothing without consent', (tester) async {
    service.stored.add(linkToBob());
    await pumpPanel(tester);

    await tapText(tester, 'Vouch');
    await tapText(tester, 'Cancel');

    expect(service.vouched, isEmpty);
  });

  testWidgets('asks which community when the member is in several', (
    tester,
  ) async {
    service.memberOf = const [
      VtcCommunity(
        communityDid: _club,
        personaDid: _me,
        contextId: 'vta',
        name: 'Football club',
      ),
      VtcCommunity(
        communityDid: _chess,
        personaDid: _me,
        contextId: 'vta',
        name: 'Chess society',
      ),
    ];
    await pumpPanel(tester);

    await tapText(tester, 'Vouch in a community');
    expect(find.text('Vouch in which community?'), findsOneWidget);
    await tapText(tester, 'Chess society');

    expect(find.text('Find Bob in Chess society'), findsOneWidget);
  });

  testWidgets('shows the member\'s vouch, and withdraws it once confirmed', (
    tester,
  ) async {
    service
      ..stored.add(linkToBob())
      ..outgoing = const PublishedRelationship(
        id: 'edge-1',
        issuerDid: _me,
        subjectDid: _bob,
        vrcDigestMultibase: 'zQm1',
      );
    await pumpPanel(tester);
    expect(find.text('Football club'), findsOneWidget);
    expect(find.byTooltip('You vouched for Bob'), findsOneWidget);

    await tapText(tester, 'Withdraw');
    expect(
      find.text('Stop vouching for Bob in Football club?'),
      findsOneWidget,
    );
    await tapText(tester, 'Withdraw');

    expect(service.withdrawn, ['edge-1']);
    expect(find.byKey(const Key('vtc_vouch_progress')), findsNothing);
    expect(find.text('You no longer vouch for Bob'), findsOneWidget);
    expect(find.byTooltip('You vouched for Bob'), findsNothing);
    expect(find.text('No vouches yet'), findsOneWidget);
  });

  testWidgets('shows that it is withdrawing until it is done', (tester) async {
    service
      ..stored.add(linkToBob())
      ..outgoing = const PublishedRelationship(
        id: 'edge-1',
        issuerDid: _me,
        subjectDid: _bob,
        vrcDigestMultibase: 'zQm1',
      );
    await pumpPanel(tester);
    final held = service.held = Completer<void>();

    await tapText(tester, 'Withdraw');
    await tester.tap(find.text('Withdraw').last);
    // Not settled: the progress indicator spins while withdrawing.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Withdrawing your vouch for Bob…'), findsOneWidget);
    expect(
      find.text('Football club stops showing it to its members.'),
      findsOneWidget,
    );

    held.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('vtc_vouch_progress')), findsNothing);
    expect(find.text('You no longer vouch for Bob'), findsOneWidget);
  });

  testWidgets('offers to vouch back for a contact who vouched first', (
    tester,
  ) async {
    service
      ..stored.add(linkToBob())
      ..incoming = const PublishedRelationship(
        id: 'edge-0',
        issuerDid: _bob,
        subjectDid: _me,
        vrcDigestMultibase: 'zQm0',
      );
    await pumpPanel(tester);

    expect(find.byTooltip('Bob vouched for you'), findsOneWidget);
    expect(find.text('Withdraw'), findsNothing);

    await tapText(tester, 'Vouch back');
    await tapText(tester, 'Vouch');

    expect(service.vouched, [_bob]);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Vouch back'), findsNothing);
    expect(
      find.byTooltip('You and Bob vouched for each other'),
      findsOneWidget,
    );
    expect(find.text('Withdraw'), findsOneWidget);
  });

  testWidgets('offers to vouch again once a vouch made here is withdrawn', (
    tester,
  ) async {
    service.stored.add(linkToBob());
    await pumpPanel(tester);

    await tapText(tester, 'Vouch');
    await tapText(tester, 'Vouch');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tapText(tester, 'Withdraw');
    await tapText(tester, 'Withdraw');

    expect(service.withdrawn, ['edge-1']);
    expect(find.text('Withdraw'), findsNothing);
    expect(find.text('Vouch'), findsOneWidget);
  });

  testWidgets('opens the signed vouch the member gave', (tester) async {
    service
      ..stored.add(linkToBob())
      ..outgoing = const PublishedRelationship(
        id: 'edge-1',
        issuerDid: _me,
        subjectDid: _bob,
        vrcDigestMultibase: 'zQm1',
        vrc: {
          'type': ['VerifiableCredential', 'RelationshipCredential'],
          'issuer': _me,
        },
      );
    await pumpPanel(tester);

    await tester.tap(find.byTooltip('You vouched for Bob'));
    await tester.pumpAndSettle();

    expect(find.text('You vouched for Bob'), findsOneWidget);
    expect(find.text('The vouch'), findsOneWidget);
    expect(find.text('Signed by your VTA'), findsOneWidget);
    expect(find.text('Stored by Football club'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vtc_vouch_document')));
    await tester.pumpAndSettle();
    expect(find.textContaining('RelationshipCredential'), findsWidgets);
  });

  testWidgets('says why a vouch did not work', (tester) async {
    service
      ..stored.add(linkToBob())
      ..refusal = VtcTrustFailure.contactNotMember;
    await pumpPanel(tester);

    await tapText(tester, 'Vouch');
    await tapText(tester, 'Vouch');

    expect(
      find.text("Bob isn't a member of Football club any more."),
      findsOneWidget,
    );
    expect(find.byKey(const Key('vtc_vouch_progress')), findsNothing);
  });

  testWidgets('leaves out links to communities the member left', (
    tester,
  ) async {
    service.stored.add(linkToBob(_chess));

    await pumpPanel(tester);

    expect(find.text('Chess society'), findsNothing);
    expect(find.text('Vouch in a community'), findsOneWidget);
  });
}
