import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_sign_in/vtc_sign_in_state.dart';

import '../../../fakes/fake_vta.dart';
import '../../../fakes/fake_vtc_network.dart';

String _signInCode() =>
    'https://link.trustoverip.org/t#_from=$fakeVtcDid'
    '&_id=q3Vn7Zk2Xo9Rt1LwPb4HdA'
    '&_exp=${DateTime.now().millisecondsSinceEpoch ~/ 1000 + 120}'
    '&_type=/vti/flow/sign-in/0.1';

void main() {
  late FakeVtcNetwork network;
  late VtcService service;
  late ProviderContainer container;

  VtcSignInController controller() =>
      container.read(vtcSignInControllerProvider.notifier);
  VtcSignInState state() => container.read(vtcSignInControllerProvider);

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    network = FakeVtcNetwork();
    final persona = Ed25519DidKeySigner.generate();
    network.vta
      ..persona = persona
      ..answers[VtaTask.didsList] = {
        'dids': [
          {'did': persona.did, 'contextId': 'keyring'},
        ],
      }
      ..answers[VtaTask.credentialsQuery] = {
        'credentials': [
          {'id': 'card-1'},
        ],
      }
      ..answers[VtaTask.credentialsGet] = {
        'credential': {
          'issuer': fakeVtcDid,
          'name': 'Football Club',
          'credentialSubject': {'id': persona.did},
        },
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
    await service.confirmLink();

    container = ProviderContainer(
      overrides: [vtcServiceProvider.overrideWithValue(service)],
    );
    container.listen(vtcSignInControllerProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  group('VtcSignInController', () {
    test('signs an administrator in to the console', () async {
      await controller().onScanned(_signInCode());
      expect(state().step, VtcSignInStep.confirmMembership);
      expect(state().communityName, 'Football Club');

      await controller().confirmMembership();
      expect(state().step, VtcSignInStep.number);
      expect(state().audience, SignInAudience.admin);
      expect(state().website, fakeVtcOrigin);

      await controller().submitNumber('47');
      expect(state().step, VtcSignInStep.review);
      expect(state().requester?.location, 'Berlin, DE');

      await controller().approve();
      expect(state().step, VtcSignInStep.approved);
      expect(network.approved, isTrue);
    });

    test('asks again for a number that is not two digits', () async {
      await controller().onScanned(_signInCode());
      await controller().confirmMembership();

      await controller().submitNumber('4');

      expect(state().step, VtcSignInStep.number);
      expect(state().failure, SignInFailure.badNumber);
    });

    test('ends on a wrong number', () async {
      await controller().onScanned(_signInCode());
      await controller().confirmMembership();

      await controller().submitNumber('12');

      expect(state().step, VtcSignInStep.failed);
      expect(state().failure, SignInFailure.wrongNumber);
    });

    test('cancels a declined sign-in', () async {
      await controller().onScanned(_signInCode());
      await controller().confirmMembership();

      await controller().decline();

      expect(state().step, VtcSignInStep.declined);
      expect(network.cancels, 1);
      expect(network.approved, isFalse);
    });

    test('says a code that is not a sign-in code cannot be used', () async {
      await controller().onScanned('https://example.com/page');

      expect(state().step, VtcSignInStep.failed);
      expect(state().linkProblem, TriggerLinkUi.invalid);
    });

    test('reports a community the member does not belong to', () async {
      network.vta.answers[VtaTask.credentialsQuery] = {
        'credentials': <Object>[],
      };

      await controller().onScanned(_signInCode());

      expect(state().step, VtcSignInStep.failed);
      expect(state().failure, SignInFailure.notAMember);
    });

    test('asks to link a VTA first', () async {
      await service.unlink();

      await controller().onScanned(_signInCode());

      expect(state().step, VtcSignInStep.failed);
      expect(state().isVtaMissing, isTrue);
    });
  });
}
