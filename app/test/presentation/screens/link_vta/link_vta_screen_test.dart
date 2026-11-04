import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vta_link_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vta_enrolment_offer.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/vta_enrolment_client.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/link_vta/link_vta_screen.dart';

import '../../../fakes/fake_vta.dart';
import '../../../fakes/fake_vta_host.dart';

void main() {
  late FakeVta vta;
  late FakeVtaHost host;

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
              enrolmentClient: VtaEnrolmentClient(
                dio: Dio()..httpClientAdapter = host,
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
    host = FakeVtaHost(vtaDid: vta.did);
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

  testWidgets('offers to scan the code of the VTA host', (tester) async {
    await pumpScreen(tester);

    expect(find.byKey(const Key('vta_scan_button')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows the code to compare for a pasted enrolment link', (
    tester,
  ) async {
    await pumpScreen(tester);

    await link(
      tester,
      host.link(expiresAt: DateTime.now().add(const Duration(minutes: 5))),
    );

    expect(find.text('Compare the codes'), findsOneWidget);
    final code = tester
        .widget<Text>(find.byKey(const Key('vta_enrolment_code')))
        .data;
    expect(code, vtaEnrolmentCode(FakeVtaHost.nonce, host.did!));
    expect(find.textContaining("don't grant access"), findsOneWidget);
    expect(find.byKey(const Key('vta_grant_commands')), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('says when an enrolment code has expired', (tester) async {
    await pumpScreen(tester);

    await link(
      tester,
      host.link(expiresAt: DateTime.now().subtract(const Duration(minutes: 1))),
    );

    expect(find.textContaining('enrolment code has expired'), findsOneWidget);
    expect(host.did, isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
