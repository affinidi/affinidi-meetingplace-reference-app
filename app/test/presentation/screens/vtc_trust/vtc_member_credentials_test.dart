import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_trust_service/vtc_trust_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_trust/vtc_member_credentials.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

const _club = 'did:webvh:QmClub:vtc.example';
const _me = 'did:webvh:QmMe:vta.example:me';
const _bob = 'did:webvh:QmBob:vta.example:bob';
const _carol = 'did:webvh:QmCarol:vta.example:carol';
const _dan = 'did:webvh:QmDan:vta.example:dan';

const _bobEntry = DirectoryEntry(
  entryId: 'dir_bob',
  displayName: 'Bob',
  did: _bob,
);

PublishedRelationship _edge(String id, String issuer, String subject) =>
    PublishedRelationship(
      id: id,
      issuerDid: issuer,
      subjectDid: subject,
      vrcDigestMultibase: 'zQm$id',
      createdAt: DateTime.utc(2026, 11, 9, 10),
      vrc: const {
        'type': ['VerifiableCredential', 'RelationshipCredential'],
      },
    );

/// What the community shows of Bob, as the trust service gathers it.
class _FakeTrustService extends Fake implements VtcTrustService {
  VtcMemberCredentials shown = const VtcMemberCredentials();
  VtcTrustFailure? refusal;

  @override
  Future<VtcMemberCredentials> memberCredentials(
    String communityDid, {
    required DirectoryEntry entry,
  }) async {
    if (refusal case final refusal?) throw VtcTrustException(refusal);
    return shown;
  }

  @override
  Future<String?> identityDid(String communityDid) async => _me;
}

void main() {
  late _FakeTrustService service;

  setUp(() => service = _FakeTrustService());

  Future<void> pumpButton(WidgetTester tester) async {
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
            body: Center(
              child: VtcMemberCredentialsButton(
                communityDid: _club,
                communityName: 'Football club',
                entry: _bobEntry,
                name: 'Bob',
                names: {_carol: 'Carol'},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip("Bob's credentials"));
    await tester.pumpAndSettle();
  }

  testWidgets('shows every credential of the member the community shows', (
    tester,
  ) async {
    service.shown = VtcMemberCredentials(
      vouches: [
        _edge('edge-1', _me, _bob),
        _edge('edge-2', _bob, _carol),
        _edge('edge-3', _dan, _bob),
      ],
      publicCard: const {'@type': 'Card'},
      membership: const MemberCredentials(
        membershipCredential: {'id': 'urn:uuid:vmc'},
        roleCredential: {'id': 'urn:uuid:vac'},
        memberVmc: {'id': 'urn:uuid:ack'},
        isMemberVmcBound: true,
      ),
    );

    await pumpButton(tester);

    expect(find.text("Bob's credentials"), findsOneWidget);
    expect(find.text('As Football club shows them to you.'), findsOneWidget);
    expect(find.text('Membership card'), findsOneWidget);
    expect(find.text('Role card'), findsOneWidget);
    expect(
      find.text('Signed by Bob, for this membership card'),
      findsOneWidget,
    );
    expect(find.text('Public card'), findsOneWidget);
    expect(find.text('You vouched for Bob'), findsOneWidget);
    expect(find.text('Bob vouched for Carol'), findsOneWidget);
    expect(find.text('another member vouched for Bob'), findsOneWidget);
    expect(find.textContaining('did:'), findsNothing);
  });

  testWidgets('opens a credential as it was signed', (tester) async {
    service.shown = VtcMemberCredentials(
      vouches: [_edge('edge-2', _bob, _carol)],
    );
    await pumpButton(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('vtc_member_vouch_edge-2')),
        matching: find.byIcon(Icons.receipt_long_outlined),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('vrcJsonld'), findsWidgets);
    expect(find.textContaining('RelationshipCredential'), findsWidgets);
  });

  testWidgets('shows no membership pair the community keeps from you', (
    tester,
  ) async {
    service.shown = VtcMemberCredentials(vouches: [_edge('edge-1', _me, _bob)]);

    await pumpButton(tester);

    expect(find.text('Membership card'), findsNothing);
    expect(find.text('Public card'), findsNothing);
    expect(find.text('You vouched for Bob'), findsOneWidget);
  });

  testWidgets('says when the community shows nothing', (tester) async {
    await pumpButton(tester);

    expect(
      find.text("Football club shows you none of Bob's credentials."),
      findsOneWidget,
    );
  });

  testWidgets('says why the credentials could not be read', (tester) async {
    service.refusal = VtcTrustFailure.network;

    await pumpButton(tester);

    expect(find.text("Couldn't reach Football club."), findsOneWidget);
  });
}
