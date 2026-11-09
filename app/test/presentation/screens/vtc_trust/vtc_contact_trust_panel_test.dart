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
    DirectoryEntry(entryId: 'dir_bobby', displayName: 'Bobby'),
  ];
  PublishedRelationship? outgoing;
  PublishedRelationship? incoming;
  VtcTrustFailure? refusal;
  final List<String> vouched = [];
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
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    vouched.add(personaDid);
    return outgoing = PublishedRelationship(
      id: 'edge-1',
      issuerDid: _me,
      subjectDid: personaDid,
      vrcDigestMultibase: 'zQm1',
      vrc: const {'type': 'VerifiableCredential'},
    );
  }

  @override
  Future<void> withdraw(String communityDid, PublishedRelationship edge) async {
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
    expect(
      find.text("Bobby hasn't let members of Football club find them yet."),
      findsOneWidget,
    );

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
    expect(find.text('You vouched'), findsOneWidget);

    await tapText(tester, 'Withdraw');
    expect(
      find.text('Stop vouching for Bob in Football club?'),
      findsOneWidget,
    );
    await tapText(tester, 'Withdraw');

    expect(service.withdrawn, ['edge-1']);
    expect(find.text('You vouched'), findsNothing);
    expect(find.text('No vouches yet'), findsOneWidget);
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

    expect(find.text('Bob vouched for you'), findsOneWidget);
    expect(find.text('Withdraw'), findsNothing);

    await tapText(tester, 'Vouch back');
    await tapText(tester, 'Vouch');

    expect(service.vouched, [_bob]);
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

    await tapText(tester, 'You vouched');

    expect(find.text('Your vouch for Bob'), findsOneWidget);
    expect(find.byKey(const Key('vtc_vouch_json')), findsOneWidget);
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
