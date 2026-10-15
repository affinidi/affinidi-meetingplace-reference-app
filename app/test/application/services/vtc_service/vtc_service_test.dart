import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';

import '../../../fakes/fake_vta.dart';
import '../../../fakes/fake_vtc_network.dart';

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

  group('VtcService join', () {
    late FakeVtcNetwork network;
    late Ed25519DidKeySigner persona;

    setUp(() async {
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
          'signingKeyId': '${persona.did}#key-1',
        }
        ..answers[VtaTask.vaultUpsert] = {
          'entry': {'id': 'entry-1'},
        };
      service = VtcService(
        sdk: network.sdk(),
        repository: SecureStorageVtcRepository(),
        userVerificationKey: UserVerificationKey(keyStorage),
        platform: 'ios',
      );
      await service.startLink(network.vta.did);
      await service.confirmLink();
    });

    Iterable<Object?> vtaTasks() =>
        network.vta.received.map((request) => request['type']);

    test('refuses a code that is not a DID', () {
      expect(
        service.readCommunity('https://community.example'),
        throwsA(isA<InvalidCommunityCodeException>()),
      );
    });

    test('joins as a new persona and keeps the cards', () async {
      final manifest = await service.readCommunity(' $fakeVtcDid ');

      final verdict = await service.join(manifest);

      expect(verdict, isA<JoinAdmitted>());
      final community = await service.community(fakeVtcDid);
      expect(community?.personaDid, persona.did);
      expect(community?.name, 'Football club');
      expect(community?.isMember, isTrue);
      expect(
        (await service.recordedMembership(fakeVtcDid))?.persona.signingKeyId,
        '${persona.did}#key-1',
      );
      expect(
        vtaTasks().where((type) => type == VtaTask.credentialsReceive),
        hasLength(2),
      );
      final submit = network.joinRequests.last;
      expect(submit['type'], JoinTask.submit);
      expect(submit['issuer'], persona.did);
    });

    test('is a member even when the VTA keeps no card', () async {
      network.vta.refusals[VtaTask.credentialsReceive] = {
        'code': 'vault/credentials/receive:proofSetUnsupported',
      };

      await service.join(await service.readCommunity(fakeVtcDid));

      expect((await service.community(fakeVtcDid))?.isMember, isTrue);
    });

    test('records a referred application, not a membership', () async {
      network.joinVerdict = {
        'effect': 'refer',
        'with': {'queue': 'review'},
      };

      await service.join(await service.readCommunity(fakeVtcDid));

      final community = await service.community(fakeVtcDid);
      expect(community?.isApplying, isTrue);
      expect(community?.joinRequestId, 'request-1');
      expect(await service.recordedMembership(fakeVtcDid), isNull);
    });

    test('records the membership once the application is approved', () async {
      network.joinVerdict = {'effect': 'refer'};
      await service.join(await service.readCommunity(fakeVtcDid));

      expect(
        await service.checkApplication(fakeVtcDid),
        JoinRequestStatus.pending,
      );
      expect((await service.community(fakeVtcDid))?.isApplying, isTrue);

      network.joinStatus = 'approved';
      expect(
        await service.checkApplication(fakeVtcDid),
        JoinRequestStatus.approved,
      );

      expect((await service.community(fakeVtcDid))?.isMember, isTrue);
      expect(network.joinRequests.last['payload'], {'requestId': 'request-1'});
    });

    test('closes a rejected application', () async {
      network.joinVerdict = {'effect': 'refer'};
      await service.join(await service.readCommunity(fakeVtcDid));
      network.joinStatus = 'rejected';

      await service.checkApplication(fakeVtcDid);

      final community = await service.community(fakeVtcDid);
      expect(community?.isMember, isFalse);
      expect(community?.isApplying, isFalse);
      expect(await service.checkApplication(fakeVtcDid), isNull);
    });

    test('applies again as the same persona', () async {
      network.joinVerdict = {
        'effect': 'deny',
        'with': {'reason': 'Not now'},
      };
      final manifest = await service.readCommunity(fakeVtcDid);
      await service.join(manifest);
      network.joinVerdict = {'effect': 'allow', 'with': <String, dynamic>{}};

      await service.join(manifest);

      expect(
        vtaTasks().where((type) => type == VtaTask.didsCreate),
        hasLength(1),
      );
      expect((await service.community(fakeVtcDid))?.isMember, isTrue);
    });
  });
}
