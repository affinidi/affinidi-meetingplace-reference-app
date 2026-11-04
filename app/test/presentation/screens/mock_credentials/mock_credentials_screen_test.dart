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
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/mock_credentials/mock_credentials_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';
import '../../../fakes/fake_vta.dart';

void main() {
  const ada = 'did:webvh:QmAda:host.example';
  const bo = 'did:webvh:QmBo:host.example';

  late FakeVta vta;
  late VtcService service;
  var identities = IdentitiesServiceState();

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/mock_credentials_screen_test.log'),
    );
  });

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    identities = IdentitiesServiceState(
      identities: [_vtaIdentity(ada, 'Ada'), _vtaIdentity(bo, 'Bo')],
    );
    vta = FakeVta()
      ..answers[VtaTask.credentialsReceive] = {'status': 'valid'}
      // Ada already holds the membership card.
      ..answerTo[VtaTask.credentialsQuery] = (payload) => {
        'credentials': [
          if (payload['subjectDid'] == ada)
            {
              'id': 'card-1',
              'types': ['VerifiableCredential', 'MembershipCredential'],
              'status': 'valid',
            },
        ],
      };
    service = VtcService(
      sdk: vta.sdk(),
      repository: SecureStorageVtcRepository(),
      userVerificationKey: UserVerificationKey(
        FakeUserVerificationKeyStorage(),
      ),
      platform: 'ios',
    );
    await service.startLink(vta.did);
    await service.checkGrant();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    // Wide enough for the banner's title in the test font.
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(service),
          identitiesServiceProvider.overrideWith(
            () => FakeIdentitiesService(identities),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: MockCredentialsScreen()),
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('lists the test credentials and who holds them', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Mock credentials'), findsOneWidget);
    expect(find.text('Club membership'), findsOneWidget);
    expect(find.text('MembershipCredential'), findsOneWidget);
    expect(find.text('memberOf: Example Chess Club'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('mock_credential_membership')),
        matching: find.text('Held by Ada'),
      ),
      findsOneWidget,
    );
    expect(find.text('Held by Bo'), findsNothing);
  });

  testWidgets('imports a test credential for the identity chosen', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('mock_credential_employee')),
        matching: find.text('Import'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Import for which identity?'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Bo'));
    await settle(tester);

    expect(find.text('Imported for Bo'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('mock_credential_employee')),
        matching: find.text('Held by Bo'),
      ),
      findsOneWidget,
    );
    final payload =
        vta.received.lastWhere(
              (r) => r['type'] == VtaTask.credentialsReceive,
            )['payload']
            as Map;
    expect(payload['contextId'], 'vta');
    final credential = payload['credential'] as Map;
    expect((credential['credentialSubject'] as Map)['id'], bo);
    expect(credential['type'], ['VerifiableCredential', 'EmployeeCredential']);
  });

  testWidgets("says why the VTA refused a credential", (tester) async {
    vta.refusals[VtaTask.credentialsReceive] = {
      'code':
          'https://trusttasks.org/spec/trust-task-error/0.1#malformedRequest',
      'message': 'credential is not yet valid',
    };
    await pumpScreen(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('mock_credential_employee')),
        matching: find.text('Import'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Bo'));
    await settle(tester);

    expect(
      find.text('Your VTA refused the credential: credential is not yet valid'),
      findsOneWidget,
    );
    expect(find.text('Held by Bo'), findsNothing);
  });

  testWidgets('cannot import without an identity on the VTA', (tester) async {
    identities = IdentitiesServiceState();
    await pumpScreen(tester);

    expect(
      find.text(
        'Create an identity on your VTA to import a credential for it.',
      ),
      findsOneWidget,
    );
    final buttons = tester.widgetList<ButtonStyleButton>(
      find.ancestor(
        of: find.text('Import'),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );
    expect(buttons, isNotEmpty);
    expect(buttons.every((button) => button.onPressed == null), isTrue);
  });

  testWidgets('asks to link a VTA first', (tester) async {
    // The VTA's answers come on the real clock.
    await tester.runAsync(service.unlink);
    await pumpScreen(tester);

    expect(
      find.text('Link your VTA in Settings to import test credentials.'),
      findsOneWidget,
    );
    expect(find.text('Club membership'), findsNothing);
  });
}

/// Lets the fake VTA answer until no spinner is left, then the screen
/// settle. Spinners never settle, so waiting on them would hang.
Future<void> settle(WidgetTester tester) async {
  final spinner = find.byType(CircularProgressIndicator);
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    // Timers on the test's clock, such as the transport's, need it to move.
    await tester.pump(const Duration(milliseconds: 20));
    if (i >= 2 && spinner.evaluate().isEmpty) break;
  }
  expect(spinner, findsNothing, reason: 'the VTA answered');
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 5),
  );
}

/// The member's identity [name], a persona of their VTA whose DID is [did].
Identity _vtaIdentity(String did, String name) =>
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
