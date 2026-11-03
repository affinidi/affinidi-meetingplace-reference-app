import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';

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

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/vtc_join_screen_test.log'),
    );
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    network = FakeVtcNetwork();
    final persona = Ed25519DidKeySigner.generate();
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
      expect(find.text('Join Football club?'), findsOneWidget);
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
      expect(cards.first, 'Ways in');
      expect(cards.last, 'Community DID');

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

    testWidgets('titles a community without a name by what it asks', (
      tester,
    ) async {
      network.joinManifest = {...network.joinManifest}..remove('branding');
      await pumpScreen(tester);

      await enterCode(tester, fakeVtcDid);

      expect(find.text('Join this community?'), findsOneWidget);
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
