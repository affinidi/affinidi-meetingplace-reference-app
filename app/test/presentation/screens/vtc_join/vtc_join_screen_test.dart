import 'dart:convert';
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
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_trail.dart';
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

  /// The screen's title reading [text]; its manifest icon sits inside it.
  Finder title(String text) => find.byWidgetPredicate(
    (widget) => widget is OnboardingTitle && widget.text == text,
  );

  /// Swipes the deck of ways in on to its next card. A drag spread over
  /// time swipes the deck rather than the page.
  Future<void> swipeWays(WidgetTester tester) async {
    final deck = find.byKey(const Key('vtc_join_ways'));
    await tester.ensureVisible(deck);
    await tester.pumpAndSettle();
    await tester.timedDrag(
      deck,
      const Offset(-500, 0),
      const Duration(milliseconds: 300),
    );
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
      expect(title('Football club'), findsOneWidget);
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

    testWidgets('shows the signed trail of a waiting application', (
      tester,
    ) async {
      network.joinVerdict = {'effect': 'refer'};
      await pumpScreen(tester);
      await enterCode(tester, fakeVtcDid);
      await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
      await settle(tester);

      expect(
        find.text(
          "Your application to Football club is waiting for the community's"
          ' decision.',
        ),
        findsOneWidget,
      );
      expect(find.byType(VtcJoinTrail), findsOneWidget);
      expect(find.text('Received by Football club'), findsOneWidget);
      expect(find.textContaining('eddsa-jcs-2022'), findsOneWidget);

      network.joinStatus = 'deferred';
      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, 'Check again'),
      );
      await settle(tester);
      expect(
        find.text('Put off by the administrators for now'),
        findsOneWidget,
      );
      expect(find.textContaining('Last checked at'), findsOneWidget);
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

      // Grouped by who sees it by default, the membership ID among them.
      const group = 'Show your Role and membership ID to the administrators';
      expect(find.text(group), findsOneWidget);
      const detail =
          'Role · you can share it up to all members · '
          "Set by the administrators; you can't change it";
      expect(find.text(detail), findsNothing);

      await tapVisible(tester, find.text(group));
      await tester.pumpAndSettle();

      expect(find.text(detail), findsOneWidget);
    });

    testWidgets('names the details the community asks for', (tester) async {
      network.joinManifest = {
        ...network.joinManifest,
        'requestedAttributes': [
          {'type': 'name.display'},
          {'type': 'x:shoe.size', 'required': false},
        ],
      };
      await pumpScreen(tester);

      await enterCode(tester, fakeVtcDid);

      expect(find.text('Receive your display name'), findsOneWidget);
      // A type this app has no name for is shown as is, not left out.
      expect(find.text('Receive your x:shoe.size'), findsOneWidget);
    });

    testWidgets('says without a tap whether a detail is required', (
      tester,
    ) async {
      network.joinManifest = {
        ...network.joinManifest,
        'requestedAttributes': [
          {'type': 'name.display', 'purpose': 'To greet you'},
          {'type': 'email.personal', 'required': false},
        ],
      };
      await pumpScreen(tester);

      await enterCode(tester, fakeVtcDid);

      expect(find.text('Required to apply'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
      expect(find.text('To greet you'), findsNothing);

      await tapVisible(tester, find.text('Receive your display name'));
      await tester.pumpAndSettle();

      expect(find.text('To greet you'), findsOneWidget);
    });

    testWidgets('flags what anyone sees', (tester) async {
      network.joinManifest = {
        ...network.joinManifest,
        'directoryDisclosure': _disclosure([
          _field('Nickname', 'public'),
          _field('Team', 'members'),
        ]),
      };
      await pumpScreen(tester);

      await enterCode(tester, fakeVtcDid);

      expect(find.text('Show your Nickname to anyone'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('lists the fields an audience sees as a sentence', (
      tester,
    ) async {
      network.joinManifest = {
        ...network.joinManifest,
        'directoryDisclosure': _disclosure([
          _field('Nickname', 'members'),
          _field('Team', 'members'),
          _field('Position', 'members'),
        ]),
      };
      await pumpScreen(tester);

      await enterCode(tester, fakeVtcDid);

      expect(
        find.text('Show your Nickname, Team and Position to all members'),
        findsOneWidget,
      );
    });

    testWidgets('tells screen readers a consent line opens', (tester) async {
      final semantics = tester.ensureSemantics();
      network.joinManifest = {
        ...network.joinManifest,
        'requestedAttributes': [
          {'type': 'name.display'},
        ],
      };
      await pumpScreen(tester);
      await enterCode(tester, fakeVtcDid);

      final line = find.text('Receive your display name');
      expect(
        tester.getSemantics(line),
        isSemantics(isButton: true, hasExpandedState: true),
      );
      expect(tester.getSemantics(line), isSemantics(isExpanded: false));

      await tapVisible(tester, line);
      await tester.pumpAndSettle();

      expect(tester.getSemantics(line), isSemantics(isExpanded: true));
      semantics.dispose();
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

    testWidgets('swipes to the way in to apply under', (tester) async {
      network.joinManifest = {
        ...network.joinManifest,
        'criteria': [
          {
            'id': 'open',
            'admission': 'automatic',
            'requirementsDigest': 'zOpen',
          },
          {
            'id': 'reviewed',
            'admission': 'review',
            'requirementsDigest': 'zReviewed',
            'description': 'For clubs from abroad',
          },
          {
            'id': 'invited',
            'admission': 'automatic',
            'requirementsDigest': 'zInvited',
            'invitationRequired': true,
          },
        ],
      };
      await pumpScreen(tester);
      await enterCode(tester, fakeVtcDid);

      final deck = find.byKey(const Key('vtc_join_ways'));
      expect(find.text('1 of 3 · swipe to see the others'), findsOneWidget);
      expect(
        find.descendant(
          of: deck,
          matching: find.text('You become a member when you apply'),
        ),
        findsOneWidget,
      );

      await swipeWays(tester);
      expect(find.text('2 of 3 · swipe to see the others'), findsOneWidget);

      await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
      await settle(tester);

      final submit = network.joinRequests.lastWhere(
        (r) => r['type'] == JoinTask.submit,
      );
      expect((submit['payload'] as Map)['criterion'], 'zReviewed');
    });

    testWidgets('cannot join under an unsupported way on top', (tester) async {
      network.joinManifest = {
        ...network.joinManifest,
        'criteria': [
          {
            'id': 'open',
            'admission': 'automatic',
            'requirementsDigest': 'zOpen',
          },
          {
            'id': 'invited',
            'admission': 'automatic',
            'requirementsDigest': 'zInvited',
            'invitationRequired': true,
          },
        ],
      };
      await pumpScreen(tester);
      await enterCode(tester, fakeVtcDid);
      ElevatedButton join() =>
          tester.widget(find.widgetWithText(ElevatedButton, 'Join'));
      expect(join().onPressed, isNotNull);

      await swipeWays(tester);

      expect(find.text('2 of 2 · swipe to see the others'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('vtc_join_ways')),
          matching: find.text('Not supported yet: needs an invitation'),
        ),
        findsOneWidget,
      );
      expect(join().onPressed, isNull);
    });

    testWidgets('shows a single way in as a deck of one', (tester) async {
      await pumpScreen(tester);
      await enterCode(tester, fakeVtcDid);

      expect(find.byKey(const Key('vtc_join_ways')), findsOneWidget);
      expect(find.byKey(const Key('vtc_join_way_position')), findsNothing);
    });

    testWidgets('shows the manifest as sent from the title', (tester) async {
      network.joinManifest = {
        ...network.joinManifest,
        'criteria': [
          ...network.joinManifest['criteria'] as List,
          {'id': 'unreadable', 'admission': 'automatic'},
        ],
      };
      await pumpScreen(tester);
      await enterCode(tester, fakeVtcDid);

      final json = find.byKey(const Key('vtc_join_manifest_json'));
      expect(json, findsNothing);

      await tapVisible(tester, find.byTooltip("Show the community's manifest"));
      await tester.pumpAndSettle();

      expect(find.text('Manifest'), findsOneWidget);
      final shown = tester.widget<SelectableText>(json).data!;
      expect(jsonDecode(shown), network.joinManifest);
      expect(shown, contains('"unreadable"'));

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(json, findsNothing);
    });

    testWidgets('titles a community without a name by what it asks', (
      tester,
    ) async {
      network.joinManifest = {...network.joinManifest}..remove('branding');
      network.publicProfile = null;
      await pumpScreen(tester);

      await enterCode(tester, fakeVtcDid);

      expect(title('A community'), findsOneWidget);
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

/// A directory disclosure of [fields], with nothing else shown.
Map<String, dynamic> _disclosure(List<Map<String, dynamic>> fields) => {
  'fields': fields,
  'newCard': {'listing': 'listed', 'search': 'byName'},
  'membershipIdentifiers': 'admins',
  'adminNotes': false,
  'externalCards': false,
  'statementDigest': 'zDigest',
};

/// A directory field the member fills in, shown to [visibility] by default.
Map<String, dynamic> _field(String label, String visibility) => {
  'key': label.toLowerCase(),
  'label': label,
  'type': 'text',
  'source': 'member',
  'ceiling': visibility,
  'defaultVisibility': visibility,
  'searchable': false,
};
