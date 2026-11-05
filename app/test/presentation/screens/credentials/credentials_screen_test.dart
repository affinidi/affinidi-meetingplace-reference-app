import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/credential_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_left_membership.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/credentials/credentials_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';
import '../../../fakes/fake_vta.dart';
import '../../../fakes/fake_vtc_network.dart';

const ada = 'did:webvh:QmAda:host.example';
const bo = 'did:webvh:QmBo:host.example';

Map<String, dynamic> card({
  required String id,
  required String name,
  required String member,
  int? slot,
}) => {
  'id': id,
  'type': ['VerifiableCredential', 'MembershipCredential'],
  'issuer': fakeVtcDid,
  'name': name,
  'validUntil': '2027-11-04T10:00:00Z',
  'credentialSubject': {'id': member},
  if (slot != null) 'credentialStatus': FakeVtcNetwork.statusEntry(slot),
};

final chessCard = card(
  id: 'urn:uuid:chess',
  name: 'Chess club',
  member: ada,
  slot: 1,
);
final footballCard = card(
  id: 'urn:uuid:football',
  name: 'Football club',
  member: bo,
  slot: 2,
);

Map<String, dynamic> _proof(String key, String created) => {
  'type': 'DataIntegrityProof',
  'cryptosuite': 'eddsa-jcs-2022',
  'verificationMethod': key,
  'proofPurpose': 'authentication',
  'created': created,
  'proofValue': 'zSignature',
};

/// Bo's leave as the VTA signed it and the community answered.
final leaveExchange = TrustTaskExchange(
  request: TrustTaskDocument.fromJson({
    'id': 'urn:uuid:leave',
    'type': MemberTask.selfRemove,
    'issuer': bo,
    'recipient': fakeVtcDid,
    'issuedAt': '2026-11-05T09:40:00Z',
    'payload': <String, dynamic>{},
    'proof': _proof('$bo#key-0', '2026-11-05T09:40:00Z'),
  }),
  answer: TrustTaskDocument.fromJson({
    'id': 'urn:uuid:leave-answer',
    'type': '${MemberTask.selfRemove}#response',
    'issuer': fakeVtcDid,
    'recipient': bo,
    'threadId': 'urn:uuid:leave',
    'issuedAt': '2026-11-05T09:40:01Z',
    'payload': {'did': bo, 'disposition': 'tombstone', 'removed': true},
    'proof': _proof('$fakeVtcDid#key-0', '2026-11-05T09:40:01Z'),
  }),
);

void main() {
  late FakeVtcNetwork network;
  late VtcService service;

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/credentials_screen_test.log'),
    );
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    network = FakeVtcNetwork();
    network.vta
      ..answers[VtaTask.credentialsQuery] = {
        'credentials': [
          {
            'id': 'vault-chess',
            'types': ['VerifiableCredential', 'MembershipCredential'],
            'purpose': 'membership',
            'status': 'valid',
          },
        ],
      }
      ..answers[VtaTask.credentialsGet] = {'credential': chessCard};
    service = VtcService(
      sdk: network.sdk(),
      repository: SecureStorageVtcRepository(),
      userVerificationKey: UserVerificationKey(
        FakeUserVerificationKeyStorage(),
      ),
      platform: 'ios',
    );
    await service.startLink(network.vta.did);
    await service.checkGrant();
    // Bo left the football club, which then revoked the card.
    await SecureStorageVtcRepository().saveLeftMembership(
      VtcLeftMembership(
        communityDid: fakeVtcDid,
        personaDid: bo,
        leftAt: DateTime.utc(2026, 11, 5, 9, 40),
        name: 'Football club',
        card: footballCard,
        leaveExchange: leaveExchange,
      ),
    );
    network.revoked.add(2);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(service),
          credentialServiceProvider.overrideWith(
            (ref) => CredentialService(ref: ref),
          ),
          identitiesServiceProvider.overrideWith(
            () => FakeIdentitiesService(
              IdentitiesServiceState(
                identities: [_identity(ada, 'Ada'), _identity(bo, 'Bo')],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: CredentialsScreen()),
        ),
      ),
    );
    await settle(tester);
  }

  Finder chip(String key) => find.byKey(Key('membership_status_$key'));

  testWidgets('lists membership cards under All and Memberships', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Memberships'), findsOneWidget);
    expect(find.text('Chess club'), findsOneWidget);
    expect(find.text('as Ada · until Nov 4, 2027'), findsOneWidget);
    expect(find.text('Football club'), findsOneWidget);
    expect(find.text('as Bo · left Nov 5, 2026'), findsOneWidget);

    await tester.tap(find.text('Memberships'));
    await tester.pumpAndSettle();
    expect(find.text('Chess club'), findsOneWidget);
    expect(find.text('Football club'), findsOneWidget);
  });

  testWidgets("shows what each card's community says of it", (tester) async {
    await pumpScreen(tester);

    expect(
      find.descendant(of: chip('urn:uuid:chess'), matching: find.text('Valid')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: chip('urn:uuid:football'),
        matching: find.text('Revoked'),
      ),
      findsOneWidget,
    );
    expect(network.statusListFetches, 2);
  });

  testWidgets("says when a community's list cannot be read", (tester) async {
    network.isStatusListDown = true;

    await pumpScreen(tester);

    expect(find.text("Couldn't check"), findsNWidgets(2));
  });

  Future<void> open(WidgetTester tester, String community) async {
    await tester.tap(find.text(community));
    await settle(tester);
  }

  Future<void> expand(WidgetTester tester, String step) async {
    final finder = find.byKey(Key('membership_trail_$step'));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets("tells a held card's story, and who did each step", (
    tester,
  ) async {
    await pumpScreen(tester);
    await open(tester, 'Chess club');

    expect(find.text('Issued by Chess club'), findsOneWidget);
    expect(find.text('Kept on your VTA'), findsOneWidget);
    expect(
      find.textContaining('Your VTA holds the card for Ada · read from it at'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('membership_trail_left')), findsNothing);
    expect(find.text('Checked with Chess club'), findsOneWidget);
    expect(
      find.textContaining(
        'This phone asked Chess club directly, without your VTA · '
        'Still valid · checked at',
      ),
      findsOneWidget,
    );

    await expand(tester, 'kept');
    expect(find.text('Done by'), findsOneWidget);
    expect(find.text('Your VTA'), findsOneWidget);
    // What the VTA records of the card.
    expect(find.text('vault-chess'), findsOneWidget);
    expect(find.text('membership'), findsOneWidget);
    expect(find.text('Your VTA holds it as'), findsOneWidget);
    expect(find.text('valid'), findsOneWidget);
    expect(
      find.text('VerifiableCredential, MembershipCredential'),
      findsOneWidget,
    );
    await expand(tester, 'checked');
    expect(find.text('This phone'), findsOneWidget);
    expect(find.text(FakeVtcNetwork.statusListUrl), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    // Both steps of the VTA carry its marker.
    expect(
      find.descendant(
        of: find.byKey(const Key('membership_trail_kept')),
        matching: find.byIcon(Icons.draw_outlined),
      ),
      findsOneWidget,
    );
  });

  testWidgets("tells a left card's story, with the receipt and the list", (
    tester,
  ) async {
    await pumpScreen(tester);
    await open(tester, 'Football club');

    expect(find.text('Your VTA put the card away when you left'), findsOne);
    expect(find.text('You left Football club'), findsOneWidget);
    expect(
      find.text(
        'Your VTA signed it as your identity · Football club confirmed it '
        'and keeps only a note that you were a member',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Football club has revoked this card · its signed list says so',
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('membership_trail_left')),
        matching: find.byIcon(Icons.draw_outlined),
      ),
      findsOneWidget,
    );

    await expand(tester, 'left');
    expect(find.text('Your VTA, then Football club'), findsOneWidget);
    expect(find.text(MemberTask.selfRemove), findsOneWidget);

    await tester.tap(find.byKey(const Key('membership_trail_left_document')));
    await tester.pumpAndSettle();
    expect(find.text('Your leave and its receipt'), findsOneWidget);
    expect(find.textContaining('"disposition": "tombstone"'), findsOneWidget);
    await tester.tap(find.byKey(const Key('vtc_join_json_close')));
    await tester.pumpAndSettle();

    final list = find.byKey(const Key('membership_trail_status_document'));
    await tester.ensureVisible(list);
    await tester.tap(list);
    await tester.pumpAndSettle();
    expect(find.text("Football club's signed status list"), findsOneWidget);
    expect(
      find.textContaining('"type": "BitstringStatusList"'),
      findsOneWidget,
    );
  });

  testWidgets('keeps showing the last list when the community is down', (
    tester,
  ) async {
    await pumpScreen(tester);
    await open(tester, 'Football club');
    network.isStatusListDown = true;

    await tester.tap(find.byKey(const Key('membership_check_again')));
    await settle(tester);

    expect(
      find.textContaining("Couldn't reach Football club · last checked at"),
      findsOneWidget,
    );
    expect(find.textContaining('it was revoked'), findsOneWidget);
    expect(
      find.byKey(const Key('membership_trail_status_document')),
      findsOneWidget,
    );
  });

  testWidgets('reads the cards again when pulled down', (tester) async {
    network.vta.answers[VtaTask.credentialsQuery] = {'credentials': <Object>[]};
    await pumpScreen(tester);
    expect(find.text('Chess club'), findsNothing);

    // The card reaches the VTA while the tab stays open.
    network.vta.answers[VtaTask.credentialsQuery] = {
      'credentials': [
        {'id': 'urn:uuid:chess'},
      ],
    };
    await tester.fling(find.text('All'), const Offset(0, 400), 1000);
    await tester.pump();
    await settle(tester);

    expect(find.text('Chess club'), findsOneWidget);
  });

  testWidgets('says when no VTA can be reached', (tester) async {
    network.vta.isDown = true;

    await pumpScreen(tester);

    expect(
      find.text(
        "Your VTA couldn't be reached, so your membership cards can't be "
        'shown.',
      ),
      findsOneWidget,
    );
  });
}

/// Lets the fakes answer until no spinner and no card being checked is
/// left, then the screen settle. Neither settles on its own.
Future<void> settle(WidgetTester tester) async {
  final busy = find.byWidgetPredicate(
    (widget) =>
        widget is CircularProgressIndicator ||
        (widget is Text && widget.data == 'Checking…'),
  );
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    // Timers on the test's clock, such as the transport's, need it to move.
    await tester.pump(const Duration(milliseconds: 20));
    if (i >= 2 && busy.evaluate().isEmpty) break;
  }
  expect(busy, findsNothing, reason: 'the fakes answered');
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

Identity _identity(String did, String name) =>
    FakeIdentities.primaryIdentity.copyWith(
      id: did,
      did: did,
      card: FakeIdentities.primaryIdentity.card.copyWith(
        did: did,
        displayName: name,
      ),
      vtaContextId: 'vta',
      vtaProfileId: '01PROFILE',
    );
