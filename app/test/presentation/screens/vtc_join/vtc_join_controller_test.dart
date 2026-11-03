import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_state.dart';

import '../../../fakes/fake_vta.dart';
import '../../../fakes/fake_vtc_network.dart';

void main() {
  late FakeVtcNetwork network;
  late VtcService service;
  late ProviderContainer container;

  VtcJoinController controller() =>
      container.read(vtcJoinControllerProvider.notifier);
  VtcJoinState state() => container.read(vtcJoinControllerProvider);

  void useService() {
    container = ProviderContainer(
      overrides: [vtcServiceProvider.overrideWithValue(service)],
    );
    container.listen(vtcJoinControllerProvider, (_, _) {});
  }

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/vtc_join_controller_test.log'),
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
    useService();
  });

  tearDown(() => container.dispose());

  group('VtcJoinController', () {
    test('joins a community that admits at once', () async {
      await controller().onScanned(fakeVtcDid);
      expect(state().step, VtcJoinStep.review);
      expect(state().communityName, 'Football club');
      expect(state().canApply, isTrue);
      expect(state().admitsAtOnce, isTrue);

      await controller().join();

      expect(state().step, VtcJoinStep.joined);
      expect(state().wasMember, isFalse);
    });

    test('says when the scanned community is already joined', () async {
      await service.join(await service.readCommunity(fakeVtcDid));

      await controller().onScanned(fakeVtcDid);

      expect(state().step, VtcJoinStep.joined);
      expect(state().wasMember, isTrue);
    });

    test('waits for a referred application, then sees it approved', () async {
      network.joinVerdict = {'effect': 'refer'};
      await controller().onScanned(fakeVtcDid);
      await controller().join();
      expect(state().step, VtcJoinStep.pending);

      await controller().checkAgain();
      expect(state().step, VtcJoinStep.pending);

      network.joinStatus = 'approved';
      await controller().checkAgain();
      expect(state().step, VtcJoinStep.joined);
    });

    test('shows a denial', () async {
      network.joinVerdict = {'effect': 'deny'};
      await controller().onScanned(fakeVtcDid);

      await controller().join();

      expect(state().step, VtcJoinStep.denied);
    });

    test('refuses a code that is not a community DID', () async {
      await controller().onScanned('https://example.com');

      expect(state().step, VtcJoinStep.failed);
      expect(state().failure, VtcJoinFailure.invalidCode);
    });

    test('says when the VTA cannot publish a persona', () async {
      network.vta.answers[VtaTask.serversList] = {'servers': <Object>[]};
      await controller().onScanned(fakeVtcDid);

      await controller().join();

      expect(state().failure, VtcJoinFailure.noDidHosting);
    });

    test('says when no VTA is linked', () async {
      await service.unlink();
      await controller().onScanned(fakeVtcDid);

      await controller().join();

      expect(state().failure, VtcJoinFailure.vtaMissing);
    });
  });
}
