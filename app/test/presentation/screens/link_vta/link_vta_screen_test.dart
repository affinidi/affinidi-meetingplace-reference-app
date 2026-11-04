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
import 'package:mpx_flutter_reference_app/presentation/screens/link_vta/link_vta_screen.dart';

import '../../../fakes/fake_vta.dart';

void main() {
  late FakeVta vta;

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1179, 2556)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(
            VtcService(
              sdk: vta.sdk(),
              repository: SecureStorageVtcRepository(),
              userVerificationKey: UserVerificationKey(
                FakeUserVerificationKeyStorage(),
              ),
              platform: 'ios',
            ),
          ),
          vtaLinkTimingProvider.overrideWithValue(
            const VtaLinkTiming(interval: Duration(hours: 1)),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LinkVtaScreen(),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
  }

  Future<void> link(WidgetTester tester, String did) async {
    await tester.enterText(find.byKey(const Key('vta_did_field')), did);
    await tester.tap(find.text('Link'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/link_vta_screen_test.log'),
    );
  });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    vta = FakeVta()
      ..answers[VtaTask.whoAmI] = {
        'roles': ['reader'],
      };
  });

  testWidgets('asks for the VTA DID', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Connect your VTA'), findsOneWidget);
    expect(find.byKey(const Key('vta_did_field')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('says when the text is not a DID', (tester) async {
    await pumpScreen(tester);

    await link(tester, 'my agent');

    expect(find.textContaining('Enter the DID of your VTA'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows what to grant, and that it waits', (tester) async {
    await pumpScreen(tester);

    await link(tester, vta.did);

    expect(find.text('Add this phone to your VTA'), findsOneWidget);
    final commands = tester
        .widget<SelectableText>(find.byKey(const Key('vta_grant_commands')))
        .data;
    expect(commands, contains('--capabilities persona-holder'));
    expect(find.text('Waiting for your admin…'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
