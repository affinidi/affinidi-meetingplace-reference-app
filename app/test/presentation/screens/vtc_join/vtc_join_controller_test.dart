import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
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
  late Ed25519DidKeySigner persona;

  VtcJoinController controller() =>
      container.read(vtcJoinControllerProvider.notifier);
  VtcJoinState state() => container.read(vtcJoinControllerProvider);

  void useService() {
    container = ProviderContainer(
      overrides: [vtcServiceProvider.overrideWithValue(service)],
    );
    container.listen(vtcJoinControllerProvider, (_, _) {});
  }

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
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

  group('VtcJoinController review', () {
    test('shows each way in, the details asked and the directory', () async {
      network.joinManifest = {
        ...network.joinManifest,
        'criteria': [
          {
            'id': 'invited',
            'admission': 'automatic',
            'requirementsDigest': 'zInvited',
            'invitationRequired': true,
          },
          {
            'id': 'open',
            'admission': 'review',
            'requirementsDigest': 'zOpen',
            'description': 'Anyone in Berlin',
          },
        ],
        'requestedAttributes': [
          {'type': 'name', 'purpose': 'To greet you'},
        ],
        'directoryDisclosure': {
          'newCard': {'listing': 'listed', 'search': 'byName'},
        },
      };

      await controller().onScanned(fakeVtcDid);

      final [invited, open] = state().ways;
      expect(invited.unsupported, VtcJoinUnsupported.invitation);
      expect(open.unsupported, isNull);
      expect(open.automatic, isFalse);
      expect(open.description, 'Anyone in Berlin');
      expect(state().canApply, isTrue);
      expect(state().admitsAtOnce, isFalse);
      expect(state().requestedDetails.single.type, 'name');
      expect(state().listsNewMembers, isTrue);
      expect(state().listInDirectory, isFalse, reason: 'off by default');

      controller().setListInDirectory(true);
      expect(state().listInDirectory, isTrue);
    });

    test('sends nothing when no way in is supported', () async {
      network.joinManifest = {
        ...network.joinManifest,
        'criteria': [
          {
            'id': 'vetted',
            'admission': 'review',
            'requirementsDigest': 'zVetted',
            'vetting': <String, dynamic>{},
          },
        ],
      };

      await controller().onScanned(fakeVtcDid);
      await controller().join();

      expect(state().ways.single.unsupported, VtcJoinUnsupported.vetting);
      expect(state().canApply, isFalse);
      expect(state().step, VtcJoinStep.review);
      expect(
        network.joinRequests.map((r) => r['type']),
        isNot(contains(JoinTask.submit)),
      );
    });
  });

  group('VtcJoinController identity', () {
    void vtaHoldsPersona() {
      network.vta.answers[VtaTask.didsList] = {
        'dids': [
          {'did': persona.did, 'contextId': 'vta'},
        ],
      };
    }

    bool createdPersona() =>
        network.vta.received.any((r) => r['type'] == VtaTask.didsCreate);

    test('joins as an identity the VTA already holds', () async {
      vtaHoldsPersona();
      await controller().onScanned(fakeVtcDid);

      await controller().join();
      expect(state().step, VtcJoinStep.chooseIdentity);
      expect(state().identityChoices, [persona.did]);

      await controller().useIdentity(persona.did);

      expect(state().step, VtcJoinStep.joined);
      expect(createdPersona(), isFalse);
      final submit = network.joinRequests.lastWhere(
        (r) => r['type'] == JoinTask.submit,
      );
      expect(submit['issuer'], persona.did);
    });

    test('joins as a new identity when chosen', () async {
      vtaHoldsPersona();
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      await controller().useIdentity(null);

      expect(state().step, VtcJoinStep.joined);
      expect(createdPersona(), isTrue);
    });

    test('ignores an identity the VTA did not offer', () async {
      vtaHoldsPersona();
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      await controller().useIdentity('did:webvh:QmOther:host.example');

      expect(state().step, VtcJoinStep.chooseIdentity);
      expect(
        network.joinRequests.map((r) => r['type']),
        isNot(contains(JoinTask.submit)),
      );
    });
  });

  group('VtcJoinController details', () {
    setUp(() {
      network.joinManifest = {
        ...network.joinManifest,
        'requestedAttributes': [
          {'type': 'name'},
          {'type': 'email', 'required': false},
        ],
      };
    });

    Iterable<Map<String, dynamic>> submits() =>
        network.joinRequests.where((r) => r['type'] == JoinTask.submit);

    test('shares only the approved details, through the VTA', () async {
      network.vta.answers[VtaTask.disclosurePreview] = {
        'previewId': 'preview-1',
        'claims': [
          {'type': 'name', 'value': 'Sam'},
          {'type': 'phone', 'value': '+49 30 1234'},
        ],
      };
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      expect(state().step, VtcJoinStep.approveDetails);
      expect(state().details.map((d) => (d.type, d.value)), [('name', 'Sam')]);
      expect(submits(), isEmpty, reason: 'nothing sent before approval');

      await controller().approveDetails();

      expect(state().step, VtcJoinStep.joined);
      final present = network.vta.received.lastWhere(
        (r) => r['type'] == VtaTask.disclosurePresent,
      );
      expect((present['payload'] as Map)['previewId'], 'preview-1');
      expect((submits().single['payload'] as Map)['attributes'], [
        {'type': 'name', 'value': 'Sam'},
      ]);
    });

    test('sends nothing when the VTA lacks a required detail', () async {
      network.vta.answers[VtaTask.disclosurePreview] = {
        'previewId': 'preview-1',
        'claims': [
          {'type': 'email', 'value': 'sam@example.com'},
        ],
      };
      await controller().onScanned(fakeVtcDid);

      await controller().join();

      expect(state().step, VtcJoinStep.failed);
      expect(state().failure, VtcJoinFailure.detailsMissing);
      expect(submits(), isEmpty);
    });

    test('says when the identity has no profile on the VTA', () async {
      network.vta.refusals[VtaTask.disclosurePreview] = {
        'code': 'persona/disclosure/preview:notBound',
      };
      await controller().onScanned(fakeVtcDid);

      await controller().join();

      expect(state().failure, VtcJoinFailure.profileMissing);
      expect(submits(), isEmpty);
    });
  });

  group('VtcJoinController admission', () {
    setUp(() {
      network.vta.answers[VtaTask.signDocument] = {
        'document': {
          'issuer': persona.did,
          'proof': {'proofPurpose': 'assertionMethod'},
        },
      };
    });

    Iterable<String> memberTasks() =>
        network.memberRequests.map((r) => r['type'] as String);

    test('confirms the membership and leaves the directory', () async {
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      expect(state().step, VtcJoinStep.joined);
      expect(memberTasks(), [MemberTask.vmc, MemberTask.directoryCardUpdate]);
      final confirmation = network.memberRequests.first['payload'] as Map;
      expect(confirmation['requestId'], 'request-1');
      final community = await service.community(fakeVtcDid);
      expect(community?.isMember, isTrue);
      expect(community?.isSettled, isTrue);
    });

    test('stays in the directory when the member opted in', () async {
      await controller().onScanned(fakeVtcDid);
      controller().setListInDirectory(true);
      await controller().join();

      expect(memberTasks(), [MemberTask.vmc]);
    });

    test('is a member, still to settle, when confirming fails', () async {
      network.vta.refusals[VtaTask.signDocument] = {
        'code': 'keys/sign-document:permissionDenied',
      };
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      expect(state().step, VtcJoinStep.joined);
      expect(memberTasks(), [MemberTask.directoryCardUpdate]);
      final community = await service.community(fakeVtcDid);
      expect(community?.isMember, isTrue);
      expect(community?.isSettled, isFalse);
    });

    test("shows the community's reason for a denial", () async {
      network.joinVerdict = {
        'effect': 'deny',
        'with': {'code': 'closed', 'reason': 'Berlin residents only'},
      };
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      expect(state().step, VtcJoinStep.denied);
      expect(state().denialReason, 'Berlin residents only');
    });

    test('shows the reason of a rejection found later', () async {
      network.joinVerdict = {'effect': 'refer'};
      await controller().onScanned(fakeVtcDid);
      await controller().join();
      expect(state().step, VtcJoinStep.pending);

      network
        ..joinStatus = 'rejected'
        ..joinRejectionReason = 'Members only';
      await controller().checkAgain();

      expect(state().step, VtcJoinStep.denied);
      expect(state().denialReason, 'Members only');
    });

    test('says when the community already counts the identity', () async {
      network.joinRefusal = 'vtc/join-requests/submit:alreadyMember';
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      expect(state().step, VtcJoinStep.joined);
      expect(state().wasMember, isTrue);
    });

    test('does not apply again for a membership the VTA holds', () async {
      network.vta
        ..answers[VtaTask.didsList] = {
          'dids': [
            {'did': persona.did, 'contextId': 'vta'},
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
            'credentialSubject': {'id': persona.did},
          },
        };

      await controller().onScanned(fakeVtcDid);

      expect(state().step, VtcJoinStep.joined);
      expect(state().wasMember, isTrue);
      expect(
        network.joinRequests.map((r) => r['type']),
        isNot(contains(JoinTask.submit)),
      );
    });
  });

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
