import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vta_link_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/settings/linked_vta_section.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_vta.dart';

void main() {
  late FakeVta vta;
  late VtcService service;

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpSection(WidgetTester tester, {ThemeData? theme}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(service),
          // Checks only by hand in these tests.
          vtaLinkTimingProvider.overrideWithValue(
            const VtaLinkTiming(interval: Duration(hours: 1)),
          ),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // As in the app: the settings live in an end drawer.
          home: Scaffold(
            endDrawer: const Drawer(
              child: SingleChildScrollView(child: LinkedVtaSection()),
            ),
            body: Builder(
              builder: (context) => TextButton(
                onPressed: Scaffold.of(context).openEndDrawer,
                child: const Text('settings'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('settings'));
    await settle(tester);
  }

  Future<void> link(WidgetTester tester, String did) async {
    await tester.enterText(find.byKey(const Key('vta_did_field')), did);
    await tester.tap(find.text('Link'));
    // Not settled: a pending link shows a spinner while it waits.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Unmounts the scope, so the link controller stops its timer.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
  }

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/linked_vta_section_test.log'),
    );
  });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    vta = FakeVta();
    service = VtcService(
      sdk: vta.sdk(),
      repository: SecureStorageVtcRepository(),
      userVerificationKey: UserVerificationKey(
        FakeUserVerificationKeyStorage(),
      ),
      platform: 'ios',
    );
  });

  group('LinkedVtaSection', () {
    for (final (name, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      testWidgets('renders in the $name theme', (tester) async {
        await pumpSection(tester, theme: theme);

        expect(tester.takeException(), isNull);
        expect(find.byKey(const Key('vta_did_field')), findsOneWidget);
        await unmount(tester);
      });
    }

    testWidgets('shows what to grant, and that it waits', (tester) async {
      vta.answers[VtaTask.whoAmI] = {
        'roles': ['reader'],
      };
      await pumpSection(tester);

      await link(tester, vta.did);

      final managerDid = await tester.runAsync(service.managerDid);
      final commands = tester
          .widget<SelectableText>(find.byKey(const Key('vta_grant_commands')))
          .data;
      expect(
        commands,
        'pnm acl create --did $managerDid --role admin '
        '--capabilities persona-holder --label "Meeting Place"',
      );
      expect(find.text('Waiting for your admin…'), findsOneWidget);
      expect(find.textContaining('Only grant it to a phone'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('says inside the drawer when the DID does not resolve', (
      tester,
    ) async {
      await pumpSection(tester);

      await link(tester, 'did:webvh:QmMissing:vta.example');

      expect(
        find.textContaining("Your VTA's DID couldn't be resolved"),
        findsOneWidget,
      );
      expect(find.byKey(const Key('vta_did_field')), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('says when the text is not a DID', (tester) async {
      await pumpSection(tester);

      await link(tester, 'my agent');

      expect(find.textContaining('Enter the DID of your VTA'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('shows an active link, and removes it', (tester) async {
      await tester.runAsync(() async {
        await service.startLink(vta.did);
        await service.checkGrant();
      });
      await pumpSection(tester);

      expect(
        tester
            .widget<SelectableText>(find.byKey(const Key('linked_vta_did')))
            .data,
        vta.did,
      );

      await tester.tap(find.text('Remove'));
      await settle(tester);

      expect(find.byKey(const Key('vta_did_field')), findsOneWidget);
      expect(await tester.runAsync(service.linkedVta), isNull);
      await unmount(tester);
    });
  });
}
