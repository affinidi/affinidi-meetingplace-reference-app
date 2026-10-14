import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';

import '../../../fakes/fake_vta.dart';

void main() {
  late FakeVta vta;
  late FakeUserVerificationKeyStorage keyStorage;
  late VtcService service;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    vta = FakeVta();
    keyStorage = FakeUserVerificationKeyStorage();
    service = VtcService(
      sdk: vta.sdk(),
      repository: SecureStorageVtcRepository(),
      userVerificationKey: UserVerificationKey(keyStorage),
      platform: 'ios',
    );
  });

  group('VtcService link', () {
    test('refuses text that is not a DID', () {
      expect(
        service.startLink('my agent'),
        throwsA(isA<InvalidVtaDidException>()),
      );
    });

    test('starts a link with a new manager key', () async {
      final managerDid = await service.startLink(' ${vta.did} ');

      final linked = await service.linkedVta();
      expect(managerDid, startsWith('did:key:z6Mk'));
      expect(await service.managerDid(), managerDid);
      expect(linked?.vtaDid, vta.did);
      expect(linked?.isGranted, isFalse);
    });

    test('stays pending while the VTA has not granted the key', () async {
      await service.startLink(vta.did);
      vta.refusals[VtaTask.whoAmI] = {'code': 'auth/whoami:notAuthorized'};

      expect(await service.confirmLink(), isFalse);
      expect((await service.linkedVta())?.isGranted, isFalse);
      expect(keyStorage.did, isNull);
    });

    test('enrols the approval key once the key is granted', () async {
      await service.startLink(vta.did);

      expect(await service.confirmLink(), isTrue);

      expect((await service.linkedVta())?.isGranted, isTrue);
      final register = vta.received.last;
      expect(register['type'], VtaTask.deviceRegister);
      final ext = (register['payload'] as Map)['ext'] as Map;
      expect((ext[uvKeyExtension] as Map)['did'], keyStorage.did);
      expect((register['payload'] as Map)['platform'], 'ios');
    });

    test('unlink forgets the VTA and the approval key', () async {
      await service.startLink(vta.did);
      await service.confirmLink();

      await service.unlink();

      expect(await service.linkedVta(), isNull);
      expect(keyStorage.did, isNull);
    });
  });
}
