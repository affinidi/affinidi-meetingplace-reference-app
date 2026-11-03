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
    test('refuses text that is not a DID, storing nothing', () async {
      await expectLater(
        service.startLink('my agent'),
        throwsA(isA<InvalidVtaDidException>()),
      );
      expect(await service.linkedVta(), isNull);
    });

    test('stores nothing when the VTA DID does not resolve', () async {
      await expectLater(
        service.startLink('did:webvh:QmMissing:vta.example'),
        throwsA(
          isA<MeetingPlaceVtcSDKException>().having(
            (e) => e.code,
            'code',
            MeetingPlaceVtcSDKErrorCode.didResolutionFailed,
          ),
        ),
      );
      expect(await service.linkedVta(), isNull);
    });

    test('stores nothing when the VTA cannot be reached', () async {
      vta.isDown = true;

      await expectLater(
        service.startLink(vta.did),
        throwsA(isA<MeetingPlaceVtcSDKException>()),
      );
      expect(await service.linkedVta(), isNull);
    });

    test('starts a link with a new manager key', () async {
      final managerDid = await service.startLink(' ${vta.did} ');

      final linked = await service.linkedVta();
      expect(managerDid, startsWith('did:key:z6Mk'));
      expect(await service.managerDid(), managerDid);
      expect(linked?.vtaDid, vta.did);
      expect(linked?.isGranted, isFalse);
      expect(vta.received.single['type'], VtaTask.challenge);
    });

    test('links one VTA at a time', () async {
      await service.startLink(vta.did);

      await expectLater(
        service.startLink(vta.did),
        throwsA(isA<VtaAlreadyLinkedException>()),
      );
    });

    test('stays pending while the VTA has not granted the key', () async {
      await service.startLink(vta.did);
      vta.refusals[VtaTask.whoAmI] = {'code': 'auth/whoami:notAuthorized'};

      expect(await service.checkGrant(), isNull);
      expect((await service.linkedVta())?.isGranted, isFalse);
    });

    test('stays pending until persona-holder is granted too', () async {
      await service.startLink(vta.did);
      vta.answers[VtaTask.whoAmI] = {
        'roles': ['admin'],
      };

      final access = await service.checkGrant();

      expect(access?.isAdmin, isTrue);
      expect(access?.isGranted, isFalse);
      expect((await service.linkedVta())?.isGranted, isFalse);
    });

    test('becomes active once granted, enrolling no approval key', () async {
      await service.startLink(vta.did);

      expect((await service.checkGrant())?.isGranted, isTrue);

      expect((await service.linkedVta())?.isGranted, isTrue);
      expect(
        vta.received.map((r) => r['type']),
        isNot(contains(VtaTask.deviceRegister)),
      );
      expect(keyStorage.did, isNull);
    });

    test('unlink signs out and forgets the VTA and its key', () async {
      await service.startLink(vta.did);
      await service.checkGrant();

      await service.unlink();

      expect(vta.received.last['type'], VtaTask.revokeSession);
      expect(await service.linkedVta(), isNull);
      expect(await service.managerDid(), isNull);
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
      await service.checkGrant();
    });

    Iterable<Object?> vtaTasks() =>
        network.vta.received.map((request) => request['type']);

    for (final (what, code) in [
      ('a code that is not a DID', 'https://community.example'),
      ('a DID of a method communities do not use', 'did:key:z6MkhaXgBZD'),
      ('a DID with a path', 'did:web:community.example/../admin'),
      ('a DID with spaces inside', 'did:web:community example'),
      ('a DID with nothing after the method', 'did:webvh:'),
    ]) {
      test('refuses $what, before any network call', () {
        expect(
          service.readCommunity(code),
          throwsA(isA<InvalidCommunityCodeException>()),
        );
        expect(network.joinRequests, isEmpty);
      });
    }

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
        (await service.checkApplication(fakeVtcDid))?.status,
        JoinRequestStatus.pending,
      );
      expect((await service.community(fakeVtcDid))?.isApplying, isTrue);

      network.joinStatus = 'approved';
      expect(
        (await service.checkApplication(fakeVtcDid))?.status,
        JoinRequestStatus.approved,
      );

      final member = await service.community(fakeVtcDid);
      expect(member?.isMember, isTrue);
      // The VTA holds no card yet: the community is asked to deliver it
      // again, and the admission waits to be settled.
      expect(network.joinRequests.last['payload'], {
        'requestId': 'request-1',
        'resendCredentials': true,
      });
      expect(member?.isSettled, isFalse);
    });

    test('settles a later approval with the card on the VTA', () async {
      network.vta
        ..answers[VtaTask.credentialsQuery] = {
          'credentials': [
            {'id': 'card-1'},
          ],
        }
        ..answers[VtaTask.credentialsGet] = {
          'credential': {
            'id': 'urn:uuid:vmc',
            'issuer': fakeVtcDid,
            'credentialSubject': {'id': persona.did},
          },
        }
        ..answers[VtaTask.signDocument] = {
          'document': {
            'issuer': persona.did,
            'proof': {'proofPurpose': 'assertionMethod'},
          },
        };
      network.joinVerdict = {'effect': 'refer'};
      await service.join(await service.readCommunity(fakeVtcDid));
      network.joinStatus = 'approved';

      await service.checkApplication(fakeVtcDid);

      expect(network.memberRequests.map((r) => r['type']), [
        MemberTask.vmc,
        MemberTask.directoryCardUpdate,
      ]);
      expect((await service.community(fakeVtcDid))?.isSettled, isTrue);
    });

    test('keeps the reason a rejection gives', () async {
      network.joinVerdict = {'effect': 'refer'};
      await service.join(await service.readCommunity(fakeVtcDid));
      network.joinStatus = 'rejected';
      network.joinRejectionReason = 'Members only';

      await service.checkApplication(fakeVtcDid);

      final community = await service.community(fakeVtcDid);
      expect(community?.isApplying, isFalse);
      expect(community?.rejectionReason, 'Members only');
    });

    test('checks every open application when asked', () async {
      network.joinVerdict = {'effect': 'refer'};
      await service.join(await service.readCommunity(fakeVtcDid));
      network.joinStatus = 'approved';

      await service.checkApplications();

      expect((await service.community(fakeVtcDid))?.isMember, isTrue);
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
