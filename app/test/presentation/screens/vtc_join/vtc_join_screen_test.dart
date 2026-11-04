import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';
import '../../../fakes/fake_vta.dart';
import '../../../fakes/fake_vtc_network.dart';

/// A device without a camera, so no camera plugin is reached.
class _NoCamera extends CameraService {
  @override
  CameraServiceState build() => CameraServiceState();
}

void main() {
  late FakeVtcNetwork network;
  late VtcService service;
  late Ed25519DidKeySigner persona;

  /// The member's identities on this phone.
  var identities = IdentitiesServiceState();

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/vtc_join_screen_test.log'),
    );
  });

  setUp(() async {
    identities = IdentitiesServiceState();
    FlutterSecureStorage.setMockInitialValues({});
    network = FakeVtcNetwork();
    persona = Ed25519DidKeySigner.generate();
    network.vta
      ..persona = persona
      ..answers[VtaTask.contextsList] = {
        'contexts': [
          {'id': 'vta'},
        ],
      }
      ..answers[VtaTask.serversList] = {
        'servers': [
          {'id': 'webvh-1'},
        ],
      }
      ..answers[VtaTask.didsCreate] = {
        'did': persona.did,
        'contextId': 'vta',
        'signingKeyId': '${persona.did}#key-0',
      }
      ..answers[VtaTask.vaultUpsert] = {
        'entry': {'id': 'entry-1'},
      };
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
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(service),
          identitiesServiceProvider.overrideWith(
            () => FakeIdentitiesService(identities),
          ),
          cameraServiceProvider.overrideWith(_NoCamera.new),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const VtcJoinScreen(),
        ),
      ),
    );
  }

  /// Lets the fake network answer, then the spinner give way.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  /// Taps [finder] once it is scrolled into view.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
  }

  Future<void> enterCode(WidgetTester tester, String code) async {
    await tester.enterText(
      find.descendant(
        of: find.byKey(const Key('vtc_join_did')),
        matching: find.byType(EditableText),
      ),
      code,
    );
    await tester.pump();
    await tapVisible(tester, find.text('Continue'));
    await settle(tester);
  }

  group('VtcJoinScreen', () {
    testWidgets('reviews, joins and leaves a community', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Become a member of a community'), findsOneWidget);

      await enterCode(tester, fakeVtcDid);
      expect(find.text('Football club'), findsOneWidget);
      expect(find.text('wants you to join'), findsOneWidget);
      expect(find.text('Ways in'), findsOneWidget);
      expect(
        tester
            .widget<SelectableText>(
              find.byKey(const Key('vtc_join_community_did')),
            )
            .data,
        fakeVtcDid,
      );

      final cards = tester
          .widgetList<GlassCard>(find.byType(GlassCard))
          .map((card) => card.title);
      expect(cards, [
        'About the community',
        'If you join, Football club can:',
        'Ways in',
      ]);

      await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
      await settle(tester);
      expect(find.text("You're a member of Football club."), findsOneWidget);

      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, 'Leave community'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Leave Football club?'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Leave community'),
        ),
      );
      await settle(tester);
      expect(find.text('You left Football club.'), findsOneWidget);
      expect(await service.community(fakeVtcDid), isNull);
    });

    testWidgets('shows the profile and what the directory shows', (
      tester,
    ) async {
      network.joinManifest = {
        ...network.joinManifest,
        'directoryDisclosure': {
          'fields': [
            {
              'key': 'role',
              'label': 'Role',
              'type': 'text',
              'source': 'admin',
              'ceiling': 'members',
              'defaultVisibility': 'admins',
              'searchable': false,
            },
          ],
          'newCard': {'listing': 'listed', 'search': 'byName'},
          'membershipIdentifiers': 'admins',
          'adminNotes': true,
          'externalCards': false,
          'statementDigest': 'zDigest',
        },
      };
      await pumpScreen(tester);

      await enterCode(tester, fakeVtcDid);

      final profile = find.byWidgetPredicate(
        (widget) =>
            widget is GlassCard && widget.title == 'About the community',
      );
      for (final text in [
        'Five-a-side on Sundays.',
        'https://club.example/',
        'hello@club.example',
        fakeVtcDid,
      ]) {
        expect(
          find.descendant(of: profile, matching: find.text(text)),
          findsOneWidget,
          reason: text,
        );
      }
      expect(find.text('https://club.example/'), findsOneWidget);
      expect(find.text('hello@club.example'), findsOneWidget);
      expect(find.text('Keep notes about you'), findsOneWidget);

      // Grouped by who sees it by default, the membership DID among them.
      const group = 'Show your Role, membership DID to the administrators';
      expect(find.text(group), findsOneWidget);
      const detail =
          'Role · you can share it up to all members · '
          "Set by the administrators; you can't change it";
      expect(find.text(detail), findsNothing);

      await tapVisible(tester, find.text(group));
      await tester.pumpAndSettle();

      expect(find.text(detail), findsOneWidget);
    });

    group('identity', () {
      setUp(() {
        // The member has one identity on their VTA, so joining asks which.
        identities = IdentitiesServiceState(
          identities: [_vtaIdentity(persona.did, 'Ada')],
        );
      });

      Iterable<Object?> vtaTasks() =>
          network.vta.received.map((request) => request['type']);

      Future<void> reachIdentities(WidgetTester tester) async {
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);
      }

      testWidgets('offers a new identity first, in a deck', (tester) async {
        await reachIdentities(tester);

        expect(find.text('Join with which identity?'), findsOneWidget);
        expect(find.byKey(const Key('vtc_join_new_identity')), findsOneWidget);
        expect(find.text('1 of 2 · swipe to see the others'), findsOneWidget);

        await tapVisible(
          tester,
          find.widgetWithText(ElevatedButton, 'Join with this identity'),
        );
        await settle(tester);

        expect(find.text("You're a member of Football club."), findsOneWidget);
        expect(vtaTasks(), contains(VtaTask.didsCreate));
      });

      testWidgets('joins as the identity swiped to', (tester) async {
        await reachIdentities(tester);
        await tester.ensureVisible(
          find.byKey(const Key('vtc_join_identities')),
        );
        await tester.pumpAndSettle();

        // The deck no longer fits the test screen, so the screen scrolls;
        // a drag spread over time swipes the deck rather than the page.
        await tester.timedDrag(
          find.byKey(const Key('vtc_join_identities')),
          const Offset(-500, 0),
          const Duration(milliseconds: 300),
        );
        await tester.pumpAndSettle();
        expect(find.text('2 of 2 · swipe to see the others'), findsOneWidget);
        expect(find.text('Ada'), findsOneWidget);
        // The details its profile holds.
        expect(find.text('John'), findsOneWidget);
        expect(find.text('john.doe@example.com'), findsOneWidget);
        expect(find.text('+1234567890'), findsOneWidget);

        await tapVisible(
          tester,
          find.widgetWithText(ElevatedButton, 'Join with this identity'),
        );
        await settle(tester);

        expect(find.text("You're a member of Football club."), findsOneWidget);
        expect(vtaTasks(), isNot(contains(VtaTask.didsCreate)));
        expect((await service.community(fakeVtcDid))?.personaDid, persona.did);
      });
    });

    testWidgets('titles a community without a name by what it asks', (
      tester,
    ) async {
      network.joinManifest = {...network.joinManifest}..remove('branding');
      network.publicProfile = null;
      await pumpScreen(tester);

      await enterCode(tester, fakeVtcDid);

      expect(find.text('A community'), findsOneWidget);
      // Only in the Community DID card, not as the title.
      expect(find.text(fakeVtcDid), findsOneWidget);
    });

    testWidgets('offers to try again with another code', (tester) async {
      await pumpScreen(tester);

      await enterCode(tester, 'https://example.com');
      expect(find.textContaining("isn't a community's code"), findsOneWidget);

      await tapVisible(tester, find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('vtc_join_did')), findsOneWidget);
    });
  });
}

/// The member's identity [name], a persona of their VTA whose DID is [did].
Identity _vtaIdentity(String did, String name) =>
    FakeIdentities.primaryIdentity.copyWith(
      did: did,
      card: FakeIdentities.primaryIdentity.card.copyWith(
        did: did,
        displayName: name,
      ),
      vtaContextId: 'vta',
      vtaProfileId: '01PROFILE',
    );
