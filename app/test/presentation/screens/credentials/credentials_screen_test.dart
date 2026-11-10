import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';

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

  Future<void> pumpScreen(WidgetTester tester, {bool settles = true}) async {
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
        child: MaterialApp.router(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const Scaffold(body: CredentialsScreen()),
              ),
              // The community's page, as the app routes to it.
              GoRoute(
                path: '/contacts/community/:communityDid',
                builder: (_, state) => Text(
                  'Community page of '
                  '${state.pathParameters['communityDid']}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (settles) await settle(tester);
  }

  Finder chip(String key) => find.byKey(Key('membership_status_$key'));
  final syncing = find.byKey(const Key('section_header_progress'));

  /// Keeps the chess card on this phone, as the VTA last described it.
  Future<void> keepChessCard() =>
      SecureStorageVtcRepository().saveMembershipCards([
        StoredCredential(
          record: const HeldCredential(
            id: 'vault-chess',
            types: ['VerifiableCredential', 'MembershipCredential'],
          ),
          credential: chessCard,
        ),
      ]);

  /// Lets the screen and the fakes run a little, without waiting for them
  /// to finish.
  Future<void> run(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  group('reading the VTA again', () {
    late Completer<void> answering;

    setUp(() {
      answering = Completer<void>();
      network.vta.heldUntil = answering.future;
    });

    testWidgets('shows the cards kept on this phone meanwhile', (tester) async {
      await keepChessCard();

      await pumpScreen(tester, settles: false);
      await run(tester);

      expect(find.text('Chess club'), findsOneWidget);
      expect(syncing, findsOneWidget);
      expect(find.byIcon(McIcons.menu), findsOneWidget);

      answering.complete();
      await settle(tester);

      expect(syncing, findsNothing);
      expect(find.text('Chess club'), findsOneWidget);
    });

    testWidgets('shows a spinner in place of cards when none is kept', (
      tester,
    ) async {
      // Not even the card of the membership left.
      await const FlutterSecureStorage().delete(key: 'vtc_left_memberships');

      await pumpScreen(tester, settles: false);
      await run(tester);

      expect(syncing, findsOneWidget);
      expect(find.text('Chess club'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));

      answering.complete();
      await settle(tester);

      expect(find.text('Chess club'), findsOneWidget);
    });
  });

  testWidgets('reads the cards again when the app comes back', (tester) async {
    await pumpScreen(tester);
    int queries() => network.vta.received
        .where((task) => task['type'] == VtaTask.credentialsQuery)
        .length;
    final before = queries();

    for (final state in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await settle(tester);

    expect(queries(), before + 1);
  });

  testWidgets('keeps the cards kept on this phone when the VTA is down', (
    tester,
  ) async {
    await keepChessCard();
    network.vta.isDown = true;

    await pumpScreen(tester);

    expect(find.text('Chess club'), findsOneWidget);
    expect(find.text('Football club'), findsOneWidget);
    expect(
      find.text(
        "Your VTA couldn't be reached. Showing the cards saved on this phone.",
      ),
      findsOneWidget,
    );
  });

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

  /// The diagram of [step], read left to right: its parties and arrows.
  List<String> flow(WidgetTester tester, String step) {
    final texts = find.descendant(
      of: find.byKey(Key('membership_flow_$step')),
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

    // Pictured only once a step is opened.
    expect(find.byKey(const Key('membership_flow_issued')), findsNothing);
    await expand(tester, 'issued');
    expect(flow(tester, 'issued'), ['Community', 'Ada']);
    // Spread across the step's full width.
    expect(
      tester.getSize(find.byKey(const Key('membership_flow_issued'))).width,
      moreOrLessEquals(
        tester.getSize(find.byKey(const Key('vtc_trail_flow_box'))).width - 20,
        epsilon: 1,
      ),
    );
    expect(
      tester.getCenter(find.text('Ada')).dx -
          tester.getCenter(find.text('Community')).dx,
      greaterThan(200),
    );
    // In a tinted box, with what it shows moved under it.
    final box = find.byKey(const Key('vtc_trail_flow_box'));
    final summary = find.textContaining('Your membership card for Ada');
    expect(find.descendant(of: box, matching: summary), findsOneWidget);
    expect(
      tester.getTopLeft(summary).dy,
      greaterThan(
        tester
            .getBottomLeft(find.byKey(const Key('membership_flow_issued')))
            .dy,
      ),
    );
    final issued = find.byKey(const Key('membership_flow_issued'));
    // Small: a circle and one line of name under it, centred in the step.
    expect(tester.getSize(issued).height, lessThanOrEqualTo(48));
    final row = find.descendant(of: issued, matching: find.byType(Row));
    final trail = find.byKey(const Key('membership_trail_issued'));
    // The step's column of text, which the diagram spans.
    final textColumn = tester.getRect(
      find.ancestor(of: issued, matching: find.byType(Expanded)).first,
    );
    expect(
      tester.getCenter(row.first).dx,
      moreOrLessEquals(textColumn.center.dx, epsilon: 1),
    );
    // Above the details, with room between.
    expect(
      tester
              .getBottomLeft(
                find
                    .descendant(of: box, matching: find.byType(DecoratedBox))
                    .first,
              )
              .dy +
          12,
      lessThanOrEqualTo(
        tester
            .getTopLeft(
              find.descendant(of: trail, matching: find.text('Done by')),
            )
            .dy,
      ),
    );
    expect(find.text(credentialIssueTask), findsOneWidget);
    await expand(tester, 'issued');

    await expand(tester, 'kept');
    expect(find.text(VtaTask.credentialsReceive), findsOneWidget);
    expect(flow(tester, 'kept'), ['Your VTA', 'This phone']);
    expect(find.text('Done by'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('membership_trail_kept')),
        matching: find.text('Your VTA'),
      ),
      findsNWidgets(2),
    );
    // What the VTA records of the card.
    expect(find.text('vault-chess'), findsOneWidget);
    expect(find.text('membership'), findsOneWidget);
    expect(find.text('Your VTA holds it as'), findsOneWidget);
    expect(find.text('valid'), findsOneWidget);
    // One type a line, each with its bullet.
    final types = find.ancestor(
      of: find.text('Types'),
      matching: find.byType(Column),
    );
    expect(
      find.descendant(of: types.first, matching: find.text('•')),
      findsNWidgets(2),
    );
    expect(
      tester.getTopLeft(find.text('VerifiableCredential')).dy,
      lessThan(tester.getTopLeft(find.text('MembershipCredential')).dy),
    );
    await expand(tester, 'checked');
    expect(flow(tester, 'checked'), ['This phone', 'Community']);
    expect(
      find.descendant(
        of: find.byKey(const Key('membership_trail_checked')),
        matching: find.text('This phone'),
      ),
      findsNWidgets(2),
    );
    expect(find.text(FakeVtcNetwork.statusListUrl), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(
      find.text("None: the community's status list is read over HTTPS"),
      findsOneWidget,
    );
    // Both steps of the VTA carry its marker.
    expect(
      find.descendant(
        of: find.byKey(const Key('membership_trail_kept')),
        matching: find.byIcon(McIcons.signature),
      ),
      findsOneWidget,
    );
  });

  testWidgets('links to the community in the app and on its website', (
    tester,
  ) async {
    await pumpScreen(tester);
    await open(tester, 'Chess club');

    final website = find.byKey(const Key('membership_open_website'));
    await tester.ensureVisible(website);
    expect(find.text('Visit website'), findsOneWidget);

    await tester.tap(find.text('Open community'));
    await settle(tester);
    expect(find.text('Community page of $fakeVtcDid'), findsOneWidget);
  });

  testWidgets('offers no way into a community that revoked the card', (
    tester,
  ) async {
    await pumpScreen(tester);
    await open(tester, 'Football club');

    expect(find.byKey(const Key('membership_open_community')), findsNothing);
  });

  testWidgets('offers no website when the community lists none', (
    tester,
  ) async {
    network.publicProfile = null;
    await pumpScreen(tester);
    await open(tester, 'Chess club');

    expect(find.byKey(const Key('membership_open_community')), findsOne);
    expect(find.byKey(const Key('membership_open_website')), findsNothing);
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
        matching: find.byIcon(McIcons.signature),
      ),
      findsOneWidget,
    );

    await expand(tester, 'kept');
    expect(flow(tester, 'kept'), ['This phone', 'Your VTA']);
    expect(find.text(VtaTask.credentialsArchive), findsOneWidget);
    await expand(tester, 'left');
    expect(flow(tester, 'left'), ['Your VTA', 'This phone', 'Community']);
    expect(find.text('Your VTA, then Football club'), findsOneWidget);
    expect(find.text(VtaTask.signTrustTask), findsOneWidget);
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

  testWidgets('says when no VTA can be reached, and no card is kept', (
    tester,
  ) async {
    await const FlutterSecureStorage().delete(key: 'vtc_left_memberships');
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
