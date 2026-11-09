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
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_findable_view.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_flow_diagram.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_phrase_view.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_trail.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_progress_line.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_trail_step.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_elevation.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_icons.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';
import '../../../fakes/fake_persona.dart';
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

  Future<void> pumpScreen(
    WidgetTester tester, {
    String? communityDid,
    ThemeData? theme,
  }) async {
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
          theme: theme ?? AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: VtcJoinScreen(code: communityDid),
        ),
      ),
    );
  }

  /// Lets the fake network answer, then the spinner give way. Settles for
  /// a second at most: a step waiting on the vetter spins until they act.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    for (var i = 0; i < 10 && tester.binding.hasScheduledFrame; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// The parties of the diagram on show, left to right.
  List<String?> flowLabels(WidgetTester tester) => [
    for (final text in tester.widgetList<Text>(
      find.descendant(
        of: find.byType(VtcFlowDiagram),
        matching: find.byType(Text),
      ),
    ))
      text.data,
  ];

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
    testWidgets('shows the steps of opening the community', (tester) async {
      await pumpScreen(tester, communityDid: fakeVtcDid);
      await tester.pump();

      expect(find.byKey(const Key('vtc_join_opening')), findsOneWidget);
      expect(find.text('Opening the community…'), findsOneWidget);
      expect(
        find.byKey(const Key('vtc_open_step_checkingCredentials')),
        findsOneWidget,
      );
      final finding = tester.widget<VtcProgressLine>(
        find.byKey(const Key('vtc_open_step_finding')),
      );
      expect(
        finding.stage,
        VtcTrailStage.done,
        reason: 'a DID needs no search',
      );

      await settle(tester);

      expect(find.byKey(const Key('vtc_join_opening')), findsNothing);
      expect(title('Football club'), findsOneWidget);
    });

    testWidgets('opens a given community without a code', (tester) async {
      await pumpScreen(tester, communityDid: fakeVtcDid);
      await settle(tester);

      expect(find.byKey(const Key('vtc_join_did')), findsNothing);
      expect(title('Football club'), findsOneWidget);
      expect(find.text('wants you to join'), findsOneWidget);
      expect(
        find.image(const AssetImage('assets/images/powered_by_mpx.png')),
        findsOneWidget,
      );
      expect(
        find.image(
          const AssetImage('assets/images/meeting-place-splash-white-1024.png'),
        ),
        findsOneWidget,
      );
    });

    for (final (name, theme) in [
      ('dark', AppTheme.dark),
      ('light', AppTheme.light),
    ]) {
      testWidgets('renders the review in the $name theme', (tester) async {
        await pumpScreen(tester, communityDid: fakeVtcDid, theme: theme);
        await settle(tester);

        expect(title('Football club'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

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

    group('community page', () {
      Finder about(String text) => find.descendant(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is GlassCard && widget.title == 'About the community',
        ),
        matching: find.text(text),
      );

      Future<void> joinCommunity(WidgetTester tester) async {
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);
      }

      Future<void> openAbout(WidgetTester tester) async {
        await tester.tap(find.byKey(const Key('vtc_community_about')));
        await settle(tester);
      }

      testWidgets('welcomes a new member and says what the community is', (
        tester,
      ) async {
        await joinCommunity(tester);

        expect(find.text("You're a member of Football club."), findsOneWidget);
        expect(find.byKey(const Key('vtc_community_name')), findsNothing);
        expect(about('Five-a-side on Sundays.'), findsNothing);

        await openAbout(tester);

        expect(about('Five-a-side on Sundays.'), findsOneWidget);
      });

      /// Has the VTA hold a role card in which the community grants the
      /// persona [role].
      void vtaHoldsRole(String role) {
        network.vta.answerTo[VtaTask.credentialsQuery] = (payload) => {
          'credentials': [
            if (payload['type'] == 'AuthorityCredential')
              {
                'id': 'role-1',
                'types': ['VerifiableCredential', 'AuthorityCredential'],
              },
          ],
        };
        network.vta.answers[VtaTask.credentialsGet] = {
          'credential': {
            'type': ['VerifiableCredential', 'AuthorityCredential'],
            'issuer': fakeVtcDid,
            'credentialSubject': {
              'id': persona.did,
              'authority': {
                'scope': fakeVtcDid,
                'actions': ['role:$role'],
              },
            },
          },
        };
      }

      String? shownRole(WidgetTester tester) => tester
          .widget<OnboardingLine>(find.byKey(const Key('vtc_community_role')))
          .subtitle;

      testWidgets('shows the role the community granted', (tester) async {
        vtaHoldsRole('member');

        await joinCommunity(tester);

        expect(shownRole(tester), 'Member');
      });

      testWidgets('names a role the community defined itself', (tester) async {
        vtaHoldsRole('custom:admin');

        await joinCommunity(tester);

        expect(shownRole(tester), 'admin');
      });

      testWidgets('keeps the join phrase behind settings beside the role', (
        tester,
      ) async {
        vtaHoldsRole('admin');

        await joinCommunity(tester);
        expect(find.byType(VtcJoinPhraseView), findsNothing);

        await tester.tap(find.byKey(const Key('vtc_community_settings')));
        await settle(tester);

        expect(find.byType(VtcJoinPhraseView), findsOneWidget);
      });

      testWidgets('lines up the role on the left with settings on the right', (
        tester,
      ) async {
        vtaHoldsRole('admin');

        await joinCommunity(tester);

        final line = tester.getRect(
          find.byKey(const Key('vtc_community_role')),
        );
        final roleIcon = tester.getRect(
          find.descendant(
            of: find.byKey(const Key('vtc_community_role')),
            matching: find.byIcon(McIcons.badge),
          ),
        );
        final settings = tester.getRect(
          find.byKey(const Key('vtc_community_settings')),
        );
        expect(roleIcon.left, line.left);
        expect(settings.right, line.right);
        expect(roleIcon.center.dy, moreOrLessEquals(settings.center.dy));
      });

      for (final role in ['member', 'custom:admin']) {
        testWidgets('offers the role $role settings without the join phrase', (
          tester,
        ) async {
          vtaHoldsRole(role);

          await joinCommunity(tester);
          await tester.tap(find.byKey(const Key('vtc_community_settings')));
          await settle(tester);

          expect(find.byType(VtcFindableView), findsOneWidget);
          expect(find.byType(VtcJoinPhraseView), findsNothing);
        });
      }

      testWidgets('shows no role until the VTA holds the role card', (
        tester,
      ) async {
        await joinCommunity(tester);

        expect(find.byKey(const Key('vtc_community_role')), findsNothing);
      });

      testWidgets('opens again as the page of the community', (tester) async {
        await joinCommunity(tester);
        await tester.pumpWidget(const SizedBox.shrink());

        await pumpScreen(tester, communityDid: fakeVtcDid);
        await settle(tester);

        expect(
          tester.widget<Text>(find.byKey(const Key('vtc_community_name'))).data,
          'Football club',
        );
        expect(find.text("You're a member of Football club."), findsNothing);
        expect(about('Five-a-side on Sundays.'), findsNothing);

        await openAbout(tester);

        expect(about('Five-a-side on Sundays.'), findsOneWidget);
        expect(about('https://club.example/'), findsOneWidget);
        expect(
          find.widgetWithText(OutlinedButton, 'Leave community'),
          findsOneWidget,
        );
      });
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

    testWidgets('withdraws a waiting application, then applies again', (
      tester,
    ) async {
      network.joinVerdict = {'effect': 'refer'};
      await pumpScreen(tester);
      await enterCode(tester, fakeVtcDid);
      await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
      await settle(tester);

      await tapVisible(tester, find.text('Withdraw application'));
      await tester.pumpAndSettle();
      expect(
        find.text('Withdraw your application to Football club?'),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Withdraw application'),
        ),
      );
      await settle(tester);
      expect(
        find.text('You withdrew your application to Football club.'),
        findsOneWidget,
      );

      await tapVisible(
        tester,
        find.widgetWithText(OutlinedButton, 'Apply again'),
      );
      await tester.pumpAndSettle();
      expect(title('Football club'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Join'), findsOneWidget);
    });

    group('membership card', () {
      Map<String, dynamic> vtaHoldsCard({bool personhood = false}) {
        final card = {
          'id': 'urn:uuid:vmc',
          'type': [
            'VerifiableCredential',
            'MembershipCredential',
            if (personhood) 'PersonhoodCredential',
          ],
          'issuer': fakeVtcDid,
          'validFrom': '2026-11-04T10:00:00Z',
          'validUntil': '2027-11-04T10:00:00Z',
          'credentialSubject': {'id': persona.did},
        };
        network.vta
          ..answers[VtaTask.credentialsQuery] = {
            'credentials': [
              {'id': 'card-1'},
            ],
          }
          ..answers[VtaTask.credentialsGet] = {'credential': card};
        // The admission carries the card the VTA then keeps.
        (network.joinVerdict['with'] as Map)['vmc'] = card;
        return card;
      }

      testWidgets('lifts the card on the brand glow', (tester) async {
        vtaHoldsCard();
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);

        final glow = tester.widget<DecoratedBox>(
          find
              .ancestor(
                of: find.byKey(const Key('vtc_membership_card')),
                matching: find.byType(DecoratedBox),
              )
              .last,
        );
        expect(
          (glow.decoration as BoxDecoration).boxShadow,
          McElevation.glowCard(Brightness.dark),
        );
      });

      testWidgets('shows the card the community issued', (tester) async {
        final card = vtaHoldsCard();
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);

        expect(find.byKey(const Key('vtc_membership_card')), findsOneWidget);
        expect(find.text('Membership card'), findsOneWidget);
        expect(find.text(persona.did), findsOneWidget);
        expect(find.text('Issued by'), findsOneWidget);
        expect(find.text('Valid until'), findsOneWidget);
        expect(find.text('Kept on your VTA'), findsOneWidget);
        expect(find.text('Personhood'), findsNothing);

        await tapVisible(
          tester,
          find.byKey(const Key('vtc_membership_card_document')),
        );
        await tester.pumpAndSettle();
        final shown = tester
            .widget<SelectableText>(find.byKey(const Key('vtc_join_json')))
            .textSpan!
            .toPlainText();
        expect(jsonDecode(shown), card);
      });

      testWidgets('draws the card from the community via the identity '
          'to the VTA', (tester) async {
        vtaHoldsCard();
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);

        final route = find.byKey(const Key('vtc_join_card_route'));
        await tester.ensureVisible(route);
        // An identity this phone does not name.
        expect(flowLabels(tester), ['Community', 'Identity', 'Your VTA']);
        expect(
          find.descendant(
            of: route,
            matching: find.text(
              'Football club issued your membership card to Identity, '
              'which passed it on to your VTA',
            ),
          ),
          findsOneWidget,
        );
      });

      testWidgets('says when the card states personhood', (tester) async {
        vtaHoldsCard(personhood: true);
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);

        expect(find.text('Personhood'), findsOneWidget);
      });

      testWidgets('says the card is on its way until the VTA holds it', (
        tester,
      ) async {
        // The community delivers the card later.
        (network.joinVerdict['with'] as Map).remove('vmc');
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);

        expect(find.byKey(const Key('vtc_membership_card')), findsNothing);
        expect(find.byKey(const Key('vtc_join_card_route')), findsNothing);
        expect(
          find.text('Your membership card is on its way to your VTA'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(OutlinedButton, 'Leave community'),
          findsOneWidget,
        );
      });

      testWidgets('shows how the card came from the identity inbox', (
        tester,
      ) async {
        final mailPersona = FakePersona(mediatorDid: network.mediatorDid);
        final card = {
          'id': 'urn:uuid:vmc',
          'type': ['VerifiableCredential', 'MembershipCredential'],
          'issuer': fakeVtcDid,
          'credentialSubject': {'id': mailPersona.did},
        };
        network.vta
          ..persona = mailPersona
          ..otherDocuments[mailPersona.did] = mailPersona.document
          ..answers[VtaTask.didsCreate] = {
            'did': mailPersona.did,
            'contextId': 'vta',
            'signingKeyId': mailPersona.signingKeyId,
          }
          ..answers[VtaTask.signDocument] = {
            'document': {
              'issuer': mailPersona.did,
              'proof': {'proofPurpose': 'assertionMethod'},
            },
          }
          ..answerTo[VtaTask.exportSecret] = (payload) =>
              mailPersona.exportAnswer(payload['keyId']);
        network.joinVerdict = {'effect': 'refer'};
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);

        await tester.runAsync(() => network.deliver(mailPersona, card));
        network.joinStatus = 'approved';
        await tapVisible(
          tester,
          find.widgetWithText(OutlinedButton, 'Check again'),
        );
        await settle(tester);

        // On show as soon as the VTA kept it, with how it came folded away.
        expect(find.byKey(const Key('vtc_membership_card')), findsOneWidget);
        expect(find.text('How your card arrived'), findsOneWidget);
        expect(find.text('Keys lent by your VTA'), findsNothing);

        await tapVisible(tester, find.byKey(const Key('vtc_delivery_toggle')));
        await tester.pumpAndSettle();
        expect(find.text('Keys lent by your VTA'), findsOneWidget);
        expect(
          find.text('Membership confirmed with Football club'),
          findsOneWidget,
        );
      });
    });

    group('identity check', () {
      /// The VTA holds a statement of the community about the persona under
      /// [predicate], beside no membership card.
      Map<String, dynamic> vtaHoldsStatement(String predicate) {
        final statement = {
          'id': 'urn:uuid:check',
          'type': ['VerifiableCredential', 'StatementCredential'],
          'issuer': fakeVtcDid,
          'validFrom': '2026-11-04T10:00:00Z',
          'validUntil': '2027-11-04T10:00:00Z',
          'credentialSubject': {
            'id': persona.did,
            'predicate': predicate,
            'object': {
              'value': {
                'community': fakeVtcDid,
                'method': 'inPerson',
                'documentClasses': ['nationalId'],
                'claimsVerified': ['name.legal'],
                'livenessConfirmed': true,
              },
            },
          },
        };
        network.vta.answerTo[VtaTask.credentialsQuery] = (payload) => {
          'credentials': [
            if (payload['type'] == 'StatementCredential')
              {
                'id': 'check-1',
                'types': ['VerifiableCredential', 'StatementCredential'],
              },
          ],
        };
        network.vta.answers[VtaTask.credentialsGet] = {'credential': statement};
        return statement;
      }

      Future<void> join(WidgetTester tester) async {
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);
      }

      testWidgets('shows how the community checked the member', (tester) async {
        final statement = vtaHoldsStatement(
          'https://registry.trustoverip.org/dtg/vsc/vetted/1',
        );
        await join(tester);

        expect(find.byKey(const Key('vtc_identity_check')), findsOneWidget);
        for (final text in [
          'Football club checked your identity',
          'In person',
          'National ID card',
          'That you were there',
          'Checked on',
        ]) {
          expect(find.text(text), findsOneWidget, reason: text);
        }

        await tapVisible(
          tester,
          find.byKey(const Key('vtc_identity_check_document')),
        );
        await tester.pumpAndSettle();
        final shown = tester
            .widget<SelectableText>(find.byKey(const Key('vtc_join_json')))
            .textSpan!
            .toPlainText();
        expect(jsonDecode(shown), statement);
      });

      testWidgets('shows no endorsement as an identity check', (tester) async {
        vtaHoldsStatement(
          'https://registry.trustoverip.org/dtg/vsc/endorses/1',
        );
        await join(tester);

        expect(find.byKey(const Key('vtc_identity_check')), findsNothing);
      });

      testWidgets('shows nothing for a member never checked', (tester) async {
        await join(tester);

        expect(find.byKey(const Key('vtc_identity_check')), findsNothing);
        expect(find.byType(VtcJoinScreen), findsOneWidget);
      });
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
      const seenBy = 'Seen by: the administrators';
      expect(find.text(seenBy), findsNothing);

      await tapVisible(tester, find.text(group));
      await tester.pumpAndSettle();

      for (final text in [
        'Role',
        seenBy,
        'You can widen to: all members',
        'Set by admins',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('offers no wider audience than a field allows', (tester) async {
      network.joinManifest = {
        ...network.joinManifest,
        'directoryDisclosure': _disclosure([_field('Team', 'members')]),
      };
      await pumpScreen(tester);
      await enterCode(tester, fakeVtcDid);

      await tapVisible(tester, find.text('Show your Team to all members'));
      await tester.pumpAndSettle();

      // One bullet per field.
      expect(find.text('•'), findsOneWidget);
      expect(find.text('Seen by: all members'), findsOneWidget);
      expect(find.textContaining('You can widen to'), findsNothing);
      expect(find.text('Set by admins'), findsNothing);
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
      expect(find.byIcon(McIcons.public), findsOneWidget);
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

    group('credential', () {
      const other = 'did:webvh:QmOther:host.example';
      const membership = ['VerifiableCredential', 'MembershipCredential'];

      setUp(() {
        network.joinManifest = {
          ...network.joinManifest,
          'criteria': [
            {
              'id': 'members',
              'admission': 'automatic',
              'requirementsDigest': 'zMembers',
              'credentialIssuers': 'any',
              'presentationDefinition': {
                'credentials': [
                  {
                    'id': 'membership',
                    'format': 'ldp_vc',
                    'meta': {
                      'type_values': [membership],
                    },
                  },
                ],
              },
            },
          ],
        };
        identities = IdentitiesServiceState(
          identities: [
            _vtaIdentity(persona.did, 'Ada'),
            _vtaIdentity(other, 'Bo'),
          ],
        );
        // Only Ada holds a membership card.
        network.vta.answerTo[VtaTask.credentialsQuery] = (payload) => {
          'credentials': [
            if (payload['subjectDid'] == persona.did)
              {
                'id': 'card-1',
                'types': membership,
                'status': 'valid',
                'issuerDid': 'did:web:chess.example',
              },
          ],
        };
        network.vta.answers[VtaTask.credentialsGet] = {
          'credential': {
            'id': 'urn:uuid:card',
            'type': membership,
            'credentialSubject': {'id': persona.did, 'memberOf': 'Chess club'},
          },
        };
      });

      Future<void> reachIdentities(WidgetTester tester) async {
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);
        await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
        await settle(tester);
      }

      ElevatedButton useIdentity(WidgetTester tester) => tester.widget(
        find.widgetWithText(ElevatedButton, 'Join with this identity'),
      );

      Future<void> swipeIdentities(WidgetTester tester) async {
        final deck = find.byKey(const Key('vtc_join_identities'));
        await tester.ensureVisible(deck);
        await tester.pumpAndSettle();
        await tester.timedDrag(
          deck,
          const Offset(-500, 0),
          const Duration(milliseconds: 300),
        );
        await tester.pumpAndSettle();
      }

      testWidgets('shows the way with the credential it asks for', (
        tester,
      ) async {
        await pumpScreen(tester);
        await enterCode(tester, fakeVtcDid);

        expect(find.text('With your MembershipCredential'), findsOneWidget);
      });

      testWidgets('marks the identities missing the credential', (
        tester,
      ) async {
        await reachIdentities(tester);

        // The deck starts on Ada, who holds it.
        expect(find.text('2 of 3 · swipe to see the others'), findsOneWidget);
        expect(useIdentity(tester).onPressed, isNotNull);

        await swipeIdentities(tester);
        expect(find.text('3 of 3 · swipe to see the others'), findsOneWidget);
        expect(
          find.byKey(const Key('vta_identity_missing_credential')),
          findsWidgets,
        );
        expect(useIdentity(tester).onPressed, isNull);

        await swipeIdentities(tester);
        expect(find.text('1 of 3 · swipe to see the others'), findsOneWidget);
        expect(useIdentity(tester).onPressed, isNull);
      });

      testWidgets('presents the credential once approved', (tester) async {
        await reachIdentities(tester);
        await tapVisible(
          tester,
          find.widgetWithText(ElevatedButton, 'Join with this identity'),
        );
        await settle(tester);

        expect(
          find.text('Present this credential to Football club?'),
          findsOneWidget,
        );
        expect(find.text('Chess club'), findsOneWidget);
        expect(find.text('memberOf'), findsOneWidget);
        expect(find.text('did:web:chess.example'), findsOneWidget);

        await tapVisible(
          tester,
          find.widgetWithText(ElevatedButton, 'Share and apply'),
        );
        await settle(tester);

        expect(find.text("You're a member of Football club."), findsOneWidget);
        final submit = network.joinRequests.lastWhere(
          (r) => r['type'] == JoinTask.submit,
        );
        expect(
          ((submit['payload'] as Map)['vp'] as Map)['holder'],
          persona.did,
        );
      });
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

      testWidgets('names the identity the card came through', (tester) async {
        network.vta
          ..answers[VtaTask.credentialsQuery] = {
            'credentials': [
              {'id': 'card-1'},
            ],
          }
          ..answers[VtaTask.credentialsGet] = {
            'credential': {
              'id': 'urn:uuid:vmc',
              'type': ['VerifiableCredential', 'MembershipCredential'],
              'issuer': fakeVtcDid,
              'credentialSubject': {'id': persona.did},
            },
          };
        await reachIdentities(tester);
        await tester.ensureVisible(
          find.byKey(const Key('vtc_join_identities')),
        );
        await tester.pumpAndSettle();
        await tester.timedDrag(
          find.byKey(const Key('vtc_join_identities')),
          const Offset(-500, 0),
          const Duration(milliseconds: 300),
        );
        await tester.pumpAndSettle();
        await tapVisible(
          tester,
          find.widgetWithText(ElevatedButton, 'Join with this identity'),
        );
        await settle(tester);

        await tester.ensureVisible(
          find.byKey(const Key('vtc_join_card_route')),
        );
        expect(flowLabels(tester), ['Community', 'Ada', 'Your VTA']);
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
      final shown = tester.widget<SelectableText>(json).textSpan!.toPlainText();
      expect(jsonDecode(shown), network.joinManifest);
      expect(shown, contains('"unreadable"'));

      await tester.tap(find.byKey(const Key('vtc_join_json_close')));
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

  group('VtcJoinScreen vetting', () {
    late FakePersona applicant;

    setUp(() {
      applicant = FakePersona(mediatorDid: network.mediatorDid);
      network
        ..joinManifest = {
          'communityDid': fakeVtcDid,
          'branding': {'displayName': 'Football club'},
          'criteria': [
            {
              'id': 'vetted',
              'admission': 'automatic',
              'requirementsDigest': 'zVetted',
              'vetting': {
                'version': '0.1',
                'statementType': VettingStatement.predicate,
                'minStatements': 2,
                'acceptedMethods': ['inPerson'],
                'eligibleVetters': {'role': 'vetter'},
                'requiredClaims': ['name.legal'],
                'maxStatementAge': 'P30D',
              },
            },
          ],
        }
        ..listedVetters = [
          {
            'vetterDid': network.vetterDid,
            'displayName': 'Bob',
            'methods': ['inPerson'],
          },
        ];
      network.vta
        ..persona = applicant
        ..otherDocuments[applicant.did] = applicant.document
        ..answers[VtaTask.didsCreate] = {
          'did': applicant.did,
          'contextId': 'vta',
          'signingKeyId': applicant.signingKeyId,
        }
        ..answerTo[VtaTask.exportSecret] = (payload) =>
            applicant.exportAnswer(payload['keyId']);
    });

    Future<void> openVetting(WidgetTester tester) async {
      await pumpScreen(tester);
      await enterCode(tester, fakeVtcDid);
      await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Join'));
      await settle(tester);
    }

    Future<void> askBob(WidgetTester tester) async {
      await openVetting(tester);
      await tapVisible(tester, find.byKey(const Key('vtc_join_vetting_code')));
      await settle(tester);
      await tester.enterText(
        find.descendant(
          of: find.byKey(const Key('vtc_join_vetting_code_field')),
          matching: find.byType(EditableText),
        ),
        'K7QF-2M9X',
      );
      await tester.pump();
      await tapVisible(tester, find.text('Continue'));
      await settle(tester);
    }

    testWidgets('stops vetting, once confirmed, back to the community', (
      tester,
    ) async {
      await openVetting(tester);

      await tapVisible(tester, find.byKey(const Key('vtc_join_vetting_stop')));
      await settle(tester);
      await tapVisible(
        tester,
        find.widgetWithText(ElevatedButton, 'Stop vetting'),
      );
      await settle(tester);

      expect(find.byKey(const Key('vtc_join_vetting_stop')), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Join'), findsOneWidget);
    });

    testWidgets('says what the community asks of vetting', (tester) async {
      await openVetting(tester);

      expect(find.text('Step 1 of 5 · Meet a vetter'), findsOneWidget);
      // The flow's steps stand in for the logo and the footer.
      expect(
        find.image(const AssetImage('assets/images/powered_by_mpx.png')),
        findsNothing,
      );
      expect(
        find.image(
          const AssetImage('assets/images/meeting-place-splash-white-1024.png'),
        ),
        findsNothing,
      );
      expect(find.text('0 of 2 vetters vouched for you'), findsOneWidget);
      expect(find.text('A vouch counts for 30 days'), findsOneWidget);
      expect(find.byKey(const Key('vtc_join_vetting_send')), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('asks the vetter whose code the member types', (tester) async {
      await askBob(tester);

      expect(find.text('Step 2 of 5 · Ask the vetter'), findsOneWidget);
      expect(
        find.image(const AssetImage('assets/images/powered_by_mpx.png')),
        findsNothing,
      );
      expect(
        find.image(
          const AssetImage('assets/images/meeting-place-splash-white-1024.png'),
        ),
        findsNothing,
      );
      // What the phone does sits apart from what the vetter is to do.
      expect(
        find.descendant(
          of: find.byType(VtcBackgroundPanel),
          matching: find.text('Sending your request to Bob'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(VtcBackgroundPanel),
          matching: find.text('Waiting for Bob to open a session'),
        ),
        findsNothing,
      );
      expect(
        find.widgetWithText(
          VtcWaitingForParty,
          'Waiting for Bob to open a session',
        ),
        findsOneWidget,
      );
      expect(network.sentToMembers, hasLength(1));

      // Waiting on Bob spins on, so no settling before the tap.
      final back = find.byKey(const Key('vtc_join_vetting_back'));
      await tester.ensureVisible(back);
      await tester.tap(back);
      await settle(tester);
      expect(find.text('Step 1 of 5 · Meet a vetter'), findsOneWidget);
      expect(find.text('Listed as Bob'), findsOneWidget);
      // The rest of what Bob published, and his DID, behind his name.
      final details = tester
          .widget<Tooltip>(
            find.ancestor(
              of: find.text('Listed as Bob'),
              matching: find.byType(Tooltip),
            ),
          )
          .message;
      expect(details, 'How they vet: in person\nDID: ${network.vetterDid}');
      expect(find.text('Waiting for them to answer'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('calls a vetter listed without a name unnamed', (tester) async {
      network.listedVetters = [
        {
          'vetterDid': network.vetterDid,
          'methods': ['inPerson'],
        },
      ];

      await askBob(tester);

      expect(
        find.text('Sending your request to Unnamed vetter'),
        findsOneWidget,
      );
      expect(find.textContaining(network.vetterDid), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('celebrates once the vetter vouched', (tester) async {
      network.vta
        ..answers[VtaTask.disclosurePreview] = {
          'previewId': 'preview-1',
          'claims': [
            {'type': 'name.legal', 'value': 'Ada Lovelace'},
          ],
        }
        ..answers[VtaTask.disclosurePresent] = {'presented': true};
      await askBob(tester);
      final vetting = (await tester.runAsync(
        () => service.vetting(fakeVtcDid),
      ))!;
      await tester.runAsync(() async {
        await network.vetterAccepts(applicant, vetting.requests.single.request);
        await network.vetterOpensSession(applicant);
      });
      await tester.pump(VtcJoinController.vettingCheckInterval);
      await settle(tester);
      await tapVisible(tester, find.byKey(const Key('vtc_join_match_yes')));
      await settle(tester);
      await tapVisible(
        tester,
        find.byKey(const Key('vtc_join_vetting_card_share')),
      );
      await settle(tester);

      final sent = (await tester.runAsync(
        () => service.vetting(fakeVtcDid),
      ))!.requests.single;
      await tester.runAsync(
        () => network.vetterVouches(
          applicant,
          session: sent.session!,
          cardDigest: sent.cardDigest!,
          identityCommitment: sent.identityCommitment!,
        ),
      );
      await tester.pump(VtcJoinController.vettingCheckInterval);
      await settle(tester);

      expect(find.text('Step 5 of 5 · Done'), findsOneWidget);
      expect(find.text('Bob vouched for you'), findsOneWidget);
      expect(find.byKey(const Key('confetti_overlay')), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 10));
    });

    testWidgets('shows the match code of a session to compare', (tester) async {
      await askBob(tester);
      final vetting = (await tester.runAsync(
        () => service.vetting(fakeVtcDid),
      ))!;
      late TrustTaskDocument session;
      await tester.runAsync(() async {
        await network.vetterAccepts(applicant, vetting.requests.single.request);
        session = await network.vetterOpensSession(applicant);
      });
      // Waiting on the vetter, the flow checks every second.
      await tester.pump(VtcJoinController.vettingCheckInterval);
      await settle(tester);

      expect(find.text('Step 3 of 5 · Compare codes'), findsOneWidget);
      expect(title('Do the codes match?'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('vtc_join_match_code'))).data,
        vettingMatchCode(session.id),
      );
      expect(find.textContaining('Bob is a vetter of Football club'), findsOne);

      await tapVisible(tester, find.byKey(const Key('vtc_join_match_no')));
      await settle(tester);

      expect(find.text('Step 5 of 5 · Done'), findsOneWidget);
      expect(find.text('You ended the session with Bob'), findsOneWidget);
      expect(find.byKey(const Key('confetti_overlay')), findsNothing);
      await tapVisible(
        tester,
        find.byKey(const Key('vtc_join_vetting_outcome_back')),
      );
      await settle(tester);
      expect(find.text('You ended the session'), findsOneWidget);
      // The request, then the decline that ends the vetter's session.
      expect(network.sentToMembers, hasLength(2));
      await tester.pumpWidget(const SizedBox.shrink());
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
