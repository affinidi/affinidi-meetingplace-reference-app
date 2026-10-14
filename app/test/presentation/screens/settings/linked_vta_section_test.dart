import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/settings/linked_vta_section.dart';

import '../../../fakes/fake_vta.dart';

class _BrokenKeyStorage extends FakeUserVerificationKeyStorage {
  @override
  Future<void> writeSeed(String value) async =>
      throw PlatformException(code: 'NoBiometrics');
}

void main() {
  late FakeVta vta;

  Future<void> pumpSection(
    WidgetTester tester, {
    UserVerificationKeyStorage? keyStorage,
    String? vtaDid,
  }) async {
    final service = VtcService(
      sdk: vta.sdk(),
      repository: SecureStorageVtcRepository(),
      userVerificationKey: UserVerificationKey(
        keyStorage ?? FakeUserVerificationKeyStorage(),
      ),
      platform: 'ios',
    );
    await tester.runAsync(() => service.startLink(vtaDid ?? vta.did));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [vtcServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
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
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> tapAdded(WidgetTester tester) async {
    await tester.tap(find.text("I've been added"));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
  }

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/linked_vta_section_test.log'),
    );
  });

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    vta = FakeVta();
  });

  group('LinkedVtaSection', () {
    testWidgets('says inside the drawer when the phone is not added yet', (
      tester,
    ) async {
      vta.refusals[VtaTask.whoAmI] = {'code': 'auth/whoami:notAuthorized'};
      await pumpSection(tester);

      await tapAdded(tester);

      expect(
        find.textContaining("This phone hasn't been added yet"),
        findsOneWidget,
      );
    });

    testWidgets('shows the link once the VTA granted the phone', (
      tester,
    ) async {
      await pumpSection(tester);

      await tapAdded(tester);

      expect(find.text('Linked to ${vta.did}'), findsOneWidget);
    });

    testWidgets('says when the VTA DID does not resolve', (tester) async {
      await pumpSection(tester, vtaDid: 'did:webvh:QmMissing:vta.example');

      await tapAdded(tester);

      expect(
        find.textContaining("Your VTA's DID couldn't be resolved"),
        findsOneWidget,
      );
    });

    testWidgets('says when the approval key cannot be created', (tester) async {
      await pumpSection(tester, keyStorage: _BrokenKeyStorage());

      await tapAdded(tester);

      expect(
        find.textContaining("couldn't set up its sign-in approval key"),
        findsOneWidget,
      );
    });
  });
}
