import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/mock_credential_template.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_card_delivery.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_left_membership.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_member_link.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_membership_entry.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_removal.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_role_change.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_vetter_desk.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_vetting.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/mock_credential_issuer.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_persona.dart';
import '../../../fakes/fake_vetter_desk.dart';
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
      expect(vta.received.single['type'], VtaTask.ping);
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

  group('VtcService communities', () {
    VtcCommunity community(
      String did, {
      bool isMember = true,
      String? joinRequestId,
    }) => VtcCommunity(
      communityDid: did,
      personaDid: 'did:key:z$did',
      contextId: 'vta',
      isMember: isMember,
      joinRequestId: joinRequestId,
    );

    test('lists memberships and open applications only', () async {
      final repository = SecureStorageVtcRepository();
      await repository.saveCommunity(community('did:web:member'));
      await repository.saveCommunity(
        community(
          'did:web:applying',
          isMember: false,
          joinRequestId: 'request-1',
        ),
      );
      await repository.saveCommunity(
        community('did:web:rejected', isMember: false),
      );

      final communities = await service.communities();

      expect(communities.map((c) => c.communityDid), [
        'did:web:member',
        'did:web:applying',
      ]);
    });
  });

  group('VtcService join', () {
    late FakeVtcNetwork network;
    late Ed25519DidKeySigner persona;
    late VtaPersona joinAs;

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
      joinAs = VtaPersona(
        did: persona.did,
        contextId: 'mpx-ada',
        signingKeyId: '${persona.did}#key-1',
      );
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

    test(
      'joins as the chosen identity\'s persona and keeps the cards',
      () async {
        final manifest = await service.readCommunity(' $fakeVtcDid ');

        final verdict = await service.join(manifest, persona: joinAs);

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
        expect(community?.contextId, 'mpx-ada');
        expect(vtaTasks(), isNot(contains(VtaTask.didsCreate)));
      },
    );

    group('as a new persona of an identity', () {
      final ada = FakeIdentities.primaryIdentity.copyWith(
        vtaContextId: 'mpx-ada',
        vtaProfileId: '01PROFILE',
      );

      Map<String, dynamic> payloadOf(String type) =>
          network.vta.received.lastWhere(
                (request) => request['type'] == type,
              )['payload']
              as Map<String, dynamic>;

      setUp(() {
        network.vta.answers[VtaTask.didsCreate] = {
          'did': persona.did,
          'contextId': 'mpx-ada',
          'signingKeyId': '${persona.did}#key-1',
        };
      });

      test("joins in the identity's context, wearing its profile", () async {
        final verdict = await service.join(
          await service.readCommunity(fakeVtcDid),
          identity: ada,
        );

        expect(verdict, isA<JoinAdmitted>());
        expect(payloadOf(VtaTask.didsCreate)['contextId'], 'mpx-ada');
        expect(payloadOf(VtaTask.localBindingSet), {
          'contextId': 'mpx-ada',
          'personaDid': persona.did,
          'profileId': '01PROFILE',
        });
        final community = await service.community(fakeVtcDid);
        expect(community?.personaDid, persona.did);
        expect(community?.contextId, 'mpx-ada');
        expect(vtaTasks(), isNot(contains(VtaTask.contextsList)));
      });

      test('applies again as the persona recorded', () async {
        final manifest = await service.readCommunity(fakeVtcDid);
        await service.joiningIdentity(manifest, persona: joinAs);

        await service.joiningIdentity(manifest, identity: ada);

        expect(vtaTasks(), isNot(contains(VtaTask.didsCreate)));
        expect((await service.community(fakeVtcDid))?.personaDid, joinAs.did);
      });

      test('refuses an identity the VTA does not hold', () async {
        await expectLater(
          service.joiningIdentity(
            await service.readCommunity(fakeVtcDid),
            identity: FakeIdentities.primaryIdentity,
          ),
          throwsArgumentError,
        );
        expect(vtaTasks(), isNot(contains(VtaTask.didsCreate)));
      });
    });

    test('is a member even when the VTA keeps no card', () async {
      network.vta.refusals[VtaTask.credentialsReceive] = {
        'code': 'vault/credentials/receive:proofSetUnsupported',
      };

      final verdict = await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );

      expect((await service.community(fakeVtcDid))?.isMember, isTrue);
      // Not the VTA's to show.
      expect((verdict as JoinAdmitted).membershipCard, isNull);
    });

    test('returns the membership card the VTA kept', () async {
      final verdict = await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );

      expect((verdict as JoinAdmitted).membershipCard?['id'], 'urn:uuid:vmc');
    });

    test('records a referred application, not a membership', () async {
      network.joinVerdict = {
        'effect': 'refer',
        'with': {'queue': 'review'},
      };

      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );

      final community = await service.community(fakeVtcDid);
      expect(community?.isApplying, isTrue);
      expect(community?.joinRequestId, 'request-1');
      expect(community?.submitReceipt?.type, JoinTask.submit);
      expect(community?.submitReceipt?.signer, persona.did);
      expect(community?.submitReceipt?.answeredBy, fakeVtcDid);
      expect(community?.submitExchange?.request.type, JoinTask.submit);
      expect(community?.submitExchange?.answer.issuer, fakeVtcDid);
      expect(await service.recordedMembership(fakeVtcDid), isNull);
    });

    test('reports each step of an admission, in order', () async {
      final steps = <VtcApplyStep>[];

      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
        onStep: steps.add,
      );

      expect(steps, VtcApplyStep.values);
    });

    test('reports no admission steps while the application waits', () async {
      network.joinVerdict = {'effect': 'refer'};
      final steps = <VtcApplyStep>[];

      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
        onStep: steps.add,
      );

      expect(steps, [VtcApplyStep.preparingIdentity, VtcApplyStep.sending]);
    });

    test('records the membership once the application is approved', () async {
      network.joinVerdict = {'effect': 'refer'};
      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );

      expect(
        (await service.checkApplication(fakeVtcDid))?.status,
        JoinRequestStatus.pending,
      );
      final applying = await service.community(fakeVtcDid);
      expect(applying?.isApplying, isTrue);
      expect(applying?.submitReceipt?.type, JoinTask.submit);

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

    test('reads the membership card the VTA holds', () async {
      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );
      expect(await service.membershipCard(fakeVtcDid), isNull);

      network.vta
        ..answers[VtaTask.credentialsQuery] = {
          'credentials': [
            {'id': 'card-1'},
          ],
        }
        ..answers[VtaTask.credentialsGet] = {
          'credential': {
            'id': 'urn:uuid:vmc',
            'type': ['VerifiableCredential', 'MembershipCredential'],
            'issuer': fakeVtcDid,
            'credentialSubject': {'id': persona.did},
          },
        };

      final card = await service.membershipCard(fakeVtcDid);
      expect(card?.issuer, fakeVtcDid);
      expect(card?.memberDid, persona.did);
    });

    test('reads the role the VTA holds', () async {
      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );
      network.vta.answerTo[VtaTask.credentialsQuery] = (payload) => {
        'credentials': [
          if (payload['type'] == 'AuthorityCredential' &&
              payload['issuerDid'] == fakeVtcDid &&
              payload['subjectDid'] == persona.did)
            {
              'id': 'role-1',
              'types': ['VerifiableCredential', 'AuthorityCredential'],
            },
        ],
      };
      network.vta.answers[VtaTask.credentialsGet] = {
        'credential': {
          'type': ['VerifiableCredential', 'AuthorityCredential'],
          'issuer': fakeVtcDid,
          'credentialSubject': {
            'id': persona.did,
            'authority': {
              'scope': fakeVtcDid,
              'actions': ['role:moderator'],
            },
          },
        },
      };

      expect(await service.communityRole(fakeVtcDid), 'moderator');
    });

    test('reads no role while the application waits', () async {
      network.joinVerdict = {'effect': 'refer'};
      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );

      expect(await service.communityRole(fakeVtcDid), isNull);
    });

    test('reads no card while the application waits', () async {
      network.joinVerdict = {'effect': 'refer'};
      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );

      expect(await service.membershipCard(fakeVtcDid), isNull);
    });

    test(
      'reads the identity check the VTA holds, not an endorsement',
      () async {
        await service.join(
          await service.readCommunity(fakeVtcDid),
          persona: joinAs,
        );
        Map<String, dynamic> statement(String predicate) => {
          'type': ['VerifiableCredential', 'StatementCredential'],
          'issuer': fakeVtcDid,
          'credentialSubject': {
            'id': persona.did,
            'predicate': predicate,
            'object': {
              'value': {
                'community': fakeVtcDid,
                'method': 'inPerson',
                'claimsVerified': ['name.legal'],
                'livenessConfirmed': true,
              },
            },
          },
        };
        final statements = {
          'endorsement': statement(
            'https://registry.trustoverip.org/dtg/vsc/endorses/1',
          ),
          'check': statement(
            'https://registry.trustoverip.org/dtg/vsc/vetted/1',
          ),
        };
        network.vta.answerTo[VtaTask.credentialsQuery] = (payload) => {
          'credentials': [
            if (payload['type'] == 'StatementCredential' &&
                payload['issuerDid'] == fakeVtcDid &&
                payload['subjectDid'] == persona.did)
              for (final id in statements.keys)
                {
                  'id': id,
                  'types': ['VerifiableCredential', 'StatementCredential'],
                },
          ],
        };
        network.vta.answerTo[VtaTask.credentialsGet] = (payload) => {
          'credential': statements[payload['id']],
        };

        final check = await service.identityCheck(fakeVtcDid);

        expect(check?.memberDid, persona.did);
        expect(check?.method, 'inPerson');
        expect(check?.claimsVerified, ['name.legal']);
      },
    );

    test('reads no identity check while the application waits', () async {
      network.joinVerdict = {'effect': 'refer'};
      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );

      expect(await service.identityCheck(fakeVtcDid), isNull);
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
      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );
      network.joinStatus = 'rejected';

      await service.checkApplication(fakeVtcDid);

      final community = await service.community(fakeVtcDid);
      expect(community?.isMember, isFalse);
      expect(community?.isApplying, isFalse);
      expect(await service.checkApplication(fakeVtcDid), isNull);
    });

    group('withdraw', () {
      setUp(() async {
        network.joinVerdict = {'effect': 'refer'};
        await service.join(
          await service.readCommunity(fakeVtcDid),
          persona: joinAs,
        );
      });

      test('withdraws the open application as the persona', () async {
        final exchange = await service.withdraw(fakeVtcDid);

        final request = network.joinRequests.last;
        expect(request['type'], JoinTask.withdraw);
        expect(request['issuer'], persona.did);
        expect(request['payload'], {'requestId': 'request-1'});
        // The signed withdraw and the community's answer, as on the wire.
        expect(exchange?.request.toJson(), request);
        expect(exchange?.answer.payload['status'], 'withdrawn');
        final community = await service.community(fakeVtcDid);
        expect(community?.isApplying, isFalse);
        expect(community?.isMember, isFalse);
        expect(community?.submitExchange, isNull);
        expect(community?.personaDid, persona.did);
      });

      test('forgets an application the community no longer holds', () async {
        network.withdrawRefusal = 'vtc/join-requests/withdraw:notFound';

        // Nothing withdrawn, so nothing signed by the community to keep.
        expect(await service.withdraw(fakeVtcDid), isNull);

        expect((await service.community(fakeVtcDid))?.isApplying, isFalse);
      });

      test('records a decision the community made already', () async {
        network
          ..withdrawRefusal = 'vtc/join-requests/withdraw:alreadyDecided'
          ..joinStatus = 'rejected'
          ..joinRejectionReason = 'Members only';

        await expectLater(
          service.withdraw(fakeVtcDid),
          throwsA(isA<MeetingPlaceVtcSDKException>()),
        );

        final community = await service.community(fakeVtcDid);
        expect(community?.isApplying, isFalse);
        expect(community?.rejectionReason, 'Members only');
      });

      test('keeps the application when the community refuses', () async {
        network.withdrawRefusal = 'vtc/join-requests/withdraw:unavailable';

        await expectLater(
          service.withdraw(fakeVtcDid),
          throwsA(isA<MeetingPlaceVtcSDKException>()),
        );

        expect((await service.community(fakeVtcDid))?.isApplying, isTrue);
      });
    });

    test('applies again as the same persona', () async {
      network.joinVerdict = {
        'effect': 'deny',
        'with': {'reason': 'Not now'},
      };
      final manifest = await service.readCommunity(fakeVtcDid);
      await service.join(manifest, persona: joinAs);
      network.joinVerdict = {'effect': 'allow', 'with': <String, dynamic>{}};

      await service.join(manifest, persona: joinAs);

      expect(vtaTasks(), isNot(contains(VtaTask.didsCreate)));
      expect((await service.community(fakeVtcDid))?.personaDid, persona.did);
      expect((await service.community(fakeVtcDid))?.isMember, isTrue);
    });

    group('refresh membership', () {
      /// The VTA holds a role card granting [role].
      void holdRole(String role) {
        network.vta.answerTo[VtaTask.credentialsQuery] = (_) => {
          'credentials': [
            {
              'id': 'role-1',
              'types': ['VerifiableCredential', 'AuthorityCredential'],
            },
          ],
        };
        network.vta.answers[VtaTask.credentialsGet] = {
          'credential': {
            'type': ['VerifiableCredential', 'AuthorityCredential'],
            'issuer': fakeVtcDid,
            'credentialSubject': {
              'id': persona.did,
              'authority': {
                'scope': fakeVtcDid,
                'actions': ['role:$role'],
              },
            },
          },
        };
      }

      setUp(() async {
        // Lets the membership confirmation through, so the join settles.
        network.vta.answers[VtaTask.signDocument] = {
          'document': {
            'issuer': persona.did,
            'proof': {'proofPurpose': 'assertionMethod'},
          },
        };
        await service.join(
          await service.readCommunity(fakeVtcDid),
          persona: joinAs,
        );
        holdRole('member');
        network.vta.received.clear();
      });

      List<Object?> kept() => [
        for (final request in network.vta.received)
          if (request['type'] == VtaTask.credentialsReceive)
            ((request['payload'] as Map)['credential'] as Map)['id'],
      ];

      test('keeps the cards of a new role and says so', () async {
        network.renewedRole = 'admin';
        var changes = 0;
        final listening = service.membershipsChanged.listen((_) => changes++);
        final roles = <String>[];
        final roleListening = service.roleChanged.listen(
          (change) => roles.add(change.role),
        );

        await service.refreshMembership(fakeVtcDid);
        await Future<void>.delayed(Duration.zero);
        await listening.cancel();
        await roleListening.cancel();

        final renewal = network.memberRequests.firstWhere(
          (request) => request['type'] == MemberTask.renew,
        );
        expect(renewal['issuer'], persona.did);
        expect(kept(), ['urn:uuid:vmc-renewed', 'urn:uuid:vac-renewed']);
        expect(changes, 1);
        expect(roles, ['admin']);
      });

      test('keeps nothing while the role is unchanged', () async {
        var changes = 0;
        final listening = service.membershipsChanged.listen((_) => changes++);

        await service.refreshMembership(fakeVtcDid);
        await Future<void>.delayed(Duration.zero);
        await listening.cancel();

        expect(
          network.memberRequests.map((request) => request['type']),
          contains(MemberTask.renew),
        );
        expect(kept(), isEmpty);
        expect(changes, 0);
      });

      test('confirms the renewed membership card back', () async {
        network.memberRequests.clear();

        await service.refreshMembership(fakeVtcDid);

        expect(network.memberRequests.map((request) => request['type']), [
          MemberTask.renew,
          MemberTask.vmc,
        ]);
        final signed = network.vta.received.lastWhere(
          (request) => request['type'] == VtaTask.signDocument,
        );
        final vc =
            (signed['payload'] as Map)['document'] as Map<String, dynamic>;
        expect(
          (vc['credentialSubject'] as Map)['digestMultibase'],
          digestMultibase({
            'id': 'urn:uuid:vmc-renewed',
            'type': ['VerifiableCredential', 'MembershipCredential'],
            'issuer': fakeVtcDid,
            'credentialSubject': {'id': persona.did},
          }),
          reason: 'bound to the renewed card, not the first one',
        );
      });

      test('refreshes all the same when the confirmation is refused', () async {
        network.refusals[MemberTask.vmc] = (409, 'vtc/members/vmc:conflict');
        network.renewedRole = 'admin';

        await service.refreshMembership(fakeVtcDid);

        expect(kept(), ['urn:uuid:vmc-renewed', 'urn:uuid:vac-renewed']);
      });

      test('keeps the cards when the VTA holds no role card', () async {
        network.vta.answerTo[VtaTask.credentialsQuery] = (_) => {
          'credentials': <Object>[],
        };

        await service.refreshMembership(fakeVtcDid);

        expect(kept(), hasLength(2));
      });

      test('changes nothing once no longer a member', () async {
        network.renewRefusal = (404, MemberTask.notMember);

        await service.refreshMembership(fakeVtcDid);

        expect(kept(), isEmpty);
        expect((await service.community(fakeVtcDid))?.isMember, isTrue);
      });

      test('passes on a refusal for another reason', () {
        network.renewRefusal = (403, 'permissionDenied');

        expect(
          service.refreshMembership(fakeVtcDid),
          throwsA(isA<MeetingPlaceVtcSDKException>()),
        );
      });

      test('asks nothing while the application waits', () async {
        network.joinVerdict = {'effect': 'refer'};
        await service.leave(fakeVtcDid);
        await service.join(await service.readCommunity(fakeVtcDid));
        network.memberRequests.clear();

        await service.refreshMembership(fakeVtcDid);

        expect(network.memberRequests, isEmpty);
      });

      test('refreshes once per while on coming to the foreground', () async {
        network.renewedRole = 'admin';

        await service.checkApplications();
        await service.checkApplications();

        final renewals = network.memberRequests.where(
          (request) => request['type'] == MemberTask.renew,
        );
        expect(renewals, hasLength(1));
        expect(kept(), contains('urn:uuid:vac-renewed'));
      });

      test('leaves an unreachable community for the next check', () async {
        network.renewRefusal = (503, 'unavailable');

        await expectLater(service.checkApplications(), completes);
      });
    });

    group('leave', () {
      setUp(() async {
        await service.join(await service.readCommunity(fakeVtcDid));
        network.vta
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
      });

      List<Map<String, dynamic>> archived() => [
        for (final request in network.vta.received)
          if (request['type'] == VtaTask.credentialsArchive)
            request['payload'] as Map<String, dynamic>,
      ];

      test('leaves as the persona, archives its card and forgets it', () async {
        await service.leave(fakeVtcDid);

        final leave = network.memberRequests.last;
        expect(leave['type'], MemberTask.selfRemove);
        expect(leave['issuer'], persona.did);
        expect(archived(), [
          {'id': 'card-1'},
        ]);
        expect(await service.community(fakeVtcDid), isNull);
      });

      test('forgets the contacts linked to its members', () async {
        final repository = SecureStorageVtcRepository();
        await repository.saveMemberLink(
          VtcMemberLink(
            communityDid: fakeVtcDid,
            channelDid: 'did:web:channel-bob',
            entryId: 'dir_bob',
            personaDid: 'did:webvh:bob',
            name: 'Bob',
            linkedAt: DateTime.utc(2026, 11, 9),
          ),
        );

        await service.leave(fakeVtcDid);

        expect(await repository.memberLinks(), isEmpty);
      });

      test('reports each step of leaving, in order', () async {
        final steps = <VtcLeaveStep>[];

        await service.leave(fakeVtcDid, onStep: steps.add);

        expect(steps, VtcLeaveStep.values);
      });

      test('keeps the card and the signed answer once left', () async {
        await service.leave(fakeVtcDid);

        // As stored: read back through another repository.
        final left =
            (await SecureStorageVtcRepository().leftMemberships()).single;
        expect(left.communityDid, fakeVtcDid);
        expect(left.personaDid, persona.did);
        expect(left.card?['issuer'], fakeVtcDid);
        final exchange = left.leaveExchange!;
        expect(exchange.request.type, MemberTask.selfRemove);
        expect(exchange.request.toJson(), network.memberRequests.last);
        expect(exchange.answer.issuer, fakeVtcDid);
        expect(exchange.answer.payload['removed'], isTrue);
      });

      test(
        'forgets a community that counts the persona as no member',
        () async {
          network.leaveRefusal = (404, 'vtc/members/self-remove:notMember');

          await service.leave(fakeVtcDid);

          expect(archived(), hasLength(1));
          expect(await service.community(fakeVtcDid), isNull);
          // The card, but no answer to show.
          final left =
              (await SecureStorageVtcRepository().leftMemberships()).single;
          expect(left.card, isNotNull);
          expect(left.leaveExchange, isNull);
        },
      );

      test('keeps the community when it refuses the leave', () async {
        network.leaveRefusal = (409, 'conflict');

        await expectLater(
          service.leave(fakeVtcDid),
          throwsA(
            isA<MeetingPlaceVtcSDKException>().having(
              (e) => e.httpStatus,
              'httpStatus',
              409,
            ),
          ),
        );
        expect(archived(), isEmpty);
        expect((await service.community(fakeVtcDid))?.isMember, isTrue);
        expect(await SecureStorageVtcRepository().leftMemberships(), isEmpty);
      });
    });

    group('trust graph', () {
      const bob = 'did:webvh:QmBob:vta.example:bob';

      setUp(() async {
        await service.join(await service.readCommunity(fakeVtcDid));
        network.memberRequests.clear();
      });

      Map<String, dynamic> edge({String id = 'edge-1', String? issuer}) => {
        'id': id,
        'issuerDid': issuer ?? persona.did,
        'subjectDid': issuer == null ? bob : persona.did,
        'vrcDigestMultibase': 'zQm$id',
      };

      test('vouches for a member as the persona', () async {
        network.answerTo[RelationshipTask.publish] = (_) => edge();

        final published = await service.publishRelationship(
          fakeVtcDid,
          subjectDid: bob,
        );

        expect(published.id, 'edge-1');
        final request = network.memberRequests.single;
        expect(request['type'], RelationshipTask.publish);
        expect(request['issuer'], persona.did);
        final vrc = (request['payload'] as Map)['vrc'] as Map;
        expect(vrc['issuer'], persona.did);
        expect(vrc['credentialSubject'], {'id': bob});
        expect(vrc['proof'], isNotNull, reason: 'signed by the VTA');
      });

      test('lists the vouches of the persona, either way round', () async {
        network.answerTo[RelationshipTask.list] = (_) => {
          'items': [edge(), edge(id: 'edge-2', issuer: bob)],
        };

        final edges = await service.relationshipsOf(fakeVtcDid);

        expect(edges.map((e) => e.id), ['edge-1', 'edge-2']);
        final request = network.memberRequests.single;
        expect((request['payload'] as Map)['did'], persona.did);
      });

      test('withdraws a vouch by its id', () async {
        network.answerTo[RelationshipTask.revoke] = (payload) => {
          'id': payload['id'],
        };

        await service.withdrawRelationship(fakeVtcDid, id: 'edge-1');

        final request = network.memberRequests.single;
        expect(request['type'], RelationshipTask.revoke);
        expect(request['payload'], {'id': 'edge-1'});
      });

      test('passes on a community that refuses the vouch', () async {
        network.refusals[RelationshipTask.publish] = (
          422,
          RelationshipTask.subjectNotMember,
        );

        await expectLater(
          service.publishRelationship(fakeVtcDid, subjectDid: bob),
          throwsA(
            isA<MeetingPlaceVtcSDKException>().having(
              (e) => e.refusalCode,
              'refusalCode',
              RelationshipTask.subjectNotMember,
            ),
          ),
        );
      });

      test('refuses a community the phone holds no membership of', () {
        expect(
          service.publishRelationship('did:web:other.example', subjectDid: bob),
          throwsA(isA<NotACommunityMemberException>()),
        );
      });

      test('finds members by name', () async {
        network.answerTo[DirectoryTask.entriesList] = (_) => {
          'items': [
            {
              'entryId': 'dir_bob',
              'fields': {'displayName': 'Bob', 'did': bob},
            },
          ],
        };

        final found = await service.searchMembers(fakeVtcDid, query: 'Bob');

        expect(found.single.did, bob);
        expect(
          (network.memberRequests.single['payload'] as Map)['query'],
          'Bob',
        );
      });

      test('readies the persona signer once for many tasks', () async {
        network.answerTo[DirectoryTask.entriesShow] = (payload) => {
          'entry': {
            'entryId': payload['entryId'],
            'fields': {'displayName': 'Bob'},
          },
        };
        network.vta.received.clear();

        await service.memberEntry(fakeVtcDid, entryId: 'dir_bob');
        await service.memberEntry(fakeVtcDid, entryId: 'dir_carol');

        expect(
          network.vta.received.map((request) => request['type']),
          [VtaTask.signTrustTask, VtaTask.signTrustTask],
          reason: 'the vault entry readied on joining is not asked again',
        );
        expect(network.memberRequests, hasLength(2));
      });

      test('reads one member entry', () async {
        network.answerTo[DirectoryTask.entriesShow] = (payload) => {
          'entry': {
            'entryId': payload['entryId'],
            'fields': {'displayName': 'Bob'},
          },
        };

        final entry = await service.memberEntry(fakeVtcDid, entryId: 'dir_bob');

        expect(entry?.displayName, 'Bob');
        expect(entry?.did, isNull);
      });

      test('reads and sets whether members can find the persona', () async {
        network.answerTo[DirectoryTask.cardShow] = (_) => {
          'card': {
            'entryId': 'dir_me',
            'visibility': {'did': 'members'},
          },
          'missingRequired': <String>[],
        };

        final card = await service.myDirectoryCard(fakeVtcDid);
        await service.setFindableByMembers(fakeVtcDid, findable: true);

        expect(card.isDidVisibleToMembers, isTrue);
        final update = network.memberRequests.last;
        expect(update['type'], DirectoryTask.cardUpdate);
        expect(update['issuer'], persona.did);
        expect(update['payload'], {
          'visibility': {'did': 'members'},
          // A card with no discoverability yet is made findable.
          'discoverability': {
            'listing': 'findable',
            'search': 'byName',
            'external': false,
          },
        });
      });

      test('reads what the community shows of another member', () async {
        network.answerTo[RelationshipTask.list] = (payload) => {
          'items': [edge(issuer: bob)],
        };
        network.answerTo[DirectoryTask.cardPublic] = (_) => {
          'card': {'@type': 'Card'},
          'cardDigest': 'zQmCard',
          'publishedAt': '2026-11-09T10:00:00Z',
        };
        network.refusals[MemberTask.credentials] = (403, 'permissionDenied');

        final vouches = await service.relationshipsNaming(fakeVtcDid, did: bob);
        final card = await service.memberPublicCard(
          fakeVtcDid,
          entryId: 'dir_bob',
        );

        expect(vouches.single.issuerDid, bob);
        expect(
          (network.memberRequests.first['payload'] as Map)['did'],
          bob,
          reason: 'listed by the other member, not the persona',
        );
        expect(card?['@type'], 'Card');
        await expectLater(
          service.memberCredentials(fakeVtcDid, did: bob),
          throwsA(isA<MeetingPlaceVtcSDKException>()),
        );
      });

      test('shows a picture to members, uploaded first', () async {
        const image = {'sha256': 'abc', 'mediaType': 'image/jpeg'};
        network.answerTo[DirectoryTask.imagesUpload] = (_) => {
          'image': image,
          'expiresAt': '2026-11-10T10:00:00Z',
        };

        await service.setDirectoryPicture(
          fakeVtcDid,
          jpeg: Uint8List.fromList([1, 2, 3]),
        );

        expect(network.memberRequests.map((r) => r['type']), [
          DirectoryTask.imagesUpload,
          DirectoryTask.cardUpdate,
        ]);
        expect(network.memberRequests.last['payload'], {
          'values': {'avatar': image},
          'visibility': {'avatar': 'members'},
        });
      });

      test('fetches the picture a member shows', () async {
        network.answerTo[DirectoryTask.imagesGet] = (_) => {
          'image': {'sha256': 'abc', 'mediaType': 'image/jpeg'},
          'data': 'AQID',
        };

        final picture = await service.memberPicture(
          fakeVtcDid,
          entryId: 'dir_bob',
          sha256: 'abc',
        );

        expect(picture, [1, 2, 3]);
        expect(network.memberRequests.single['payload'], {
          'entryId': 'dir_bob',
          'field': 'avatar',
          'sha256': 'abc',
        });
      });

      test('sets the name members see, as the persona', () async {
        await service.setDirectoryName(fakeVtcDid, name: 'Ada');

        final update = network.memberRequests.single;
        expect(update['type'], DirectoryTask.cardUpdate);
        expect(update['issuer'], persona.did);
        expect(update['payload'], {
          'values': {'displayName': 'Ada'},
        });
      });
    });

    group('membership credentials', () {
      Map<String, dynamic> card({
        String id = 'urn:uuid:vmc',
        String issuer = fakeVtcDid,
        Map<String, dynamic>? status,
        String? validUntil,
      }) => {
        'id': id,
        'type': ['VerifiableCredential', 'MembershipCredential'],
        'issuer': issuer,
        'validUntil': ?validUntil,
        'credentialSubject': {'id': persona.did},
        'credentialStatus': ?status,
      };

      void hold(List<Map<String, dynamic>> cards) {
        network.vta
          ..answers[VtaTask.credentialsQuery] = {
            'credentials': [
              for (final card in cards) {'id': card['id']},
            ],
          }
          ..answerTo[VtaTask.credentialsGet] = (payload) => {
            'credential': cards.firstWhere((c) => c['id'] == payload['id']),
          };
      }

      setUp(() async {
        await service.join(await service.readCommunity(fakeVtcDid));
      });

      test('tells when a card is kept and when it is left', () async {
        var changes = 0;
        final listening = service.membershipsChanged.listen((_) => changes++);
        addTearDown(listening.cancel);
        await service.leave(fakeVtcDid);
        await Future<void>.delayed(Duration.zero);
        expect(changes, 1);

        await service.join(await service.readCommunity(fakeVtcDid));
        await Future<void>.delayed(Duration.zero);
        expect(changes, 2);
      });

      test('lists the cards communities issued, not test ones', () async {
        hold([
          card(status: FakeVtcNetwork.statusEntry(7)),
          card(id: 'urn:uuid:mock', issuer: await MockCredentialIssuer().did()),
        ]);

        final entries = await service.membershipCredentials();

        expect(entries.single.key, 'urn:uuid:vmc');
        expect(entries.single.communityName, 'Football club');
        expect(entries.single.left, isNull);
      });

      test('shows the cards last read, without asking the VTA', () async {
        expect(await service.savedMembershipCredentials(), isEmpty);
        hold([card(status: FakeVtcNetwork.statusEntry(7))]);
        await service.membershipCredentials();
        final asked = network.vta.received.length;
        network.vta.isDown = true;

        final saved = await service.savedMembershipCredentials();

        expect(saved.single.key, 'urn:uuid:vmc');
        expect(saved.single.communityName, 'Football club');
        expect(saved.single.stored?.id, 'urn:uuid:vmc');
        expect(network.vta.received, hasLength(asked));
      });

      test('shows a card last read once, as left, after leaving', () async {
        hold([card(status: FakeVtcNetwork.statusEntry(7))]);
        await service.membershipCredentials();

        await service.leave(fakeVtcDid);

        final saved = await service.savedMembershipCredentials();
        expect(saved.single.left, isNotNull);
      });

      test("leaves out a community group's credential", () async {
        hold([
          card(status: FakeVtcNetwork.statusEntry(7)),
          card(
            id: 'urn:uuid:group',
            issuer: 'did:webvh:QmGroup:vtc.example:group-dids:g1',
          ),
        ]);

        final entries = await service.membershipCredentials();

        expect(entries.single.key, 'urn:uuid:vmc');
      });

      test('reads a card valid, then revoked once left', () async {
        hold([card(status: FakeVtcNetwork.statusEntry(7))]);
        final active = (await service.membershipCredentials()).single;

        final valid = await service.checkMembershipStatus(active);
        expect(valid.state, VtcCardState.valid);
        expect(valid.index, 7);
        expect(valid.statusList?['issuer'], fakeVtcDid);

        await service.leave(fakeVtcDid);
        network.revoked.add(7);
        // The VTA still answers with the card; it shows once, as left.
        final left = (await service.membershipCredentials()).single;
        expect(left.left?.leaveExchange, isNotNull);

        final revoked = await service.checkMembershipStatus(left);
        expect(revoked.state, VtcCardState.revoked);
        final stored = (await SecureStorageVtcRepository().leftMemberships())
            .single
            .lastStatus;
        expect(stored?.revoked, isTrue);
        expect(stored?.statusList, revoked.statusList);
      });

      test('keeps the last list when the community is down', () async {
        hold([card(status: FakeVtcNetwork.statusEntry(7))]);
        await service.leave(fakeVtcDid);
        network.revoked.add(7);
        final left = (await service.membershipCredentials()).single;
        await service.checkMembershipStatus(left);
        network.isStatusListDown = true;

        final status = await service.checkMembershipStatus(left);

        expect(status.state, VtcCardState.unknown);
        expect(status.failure, MeetingPlaceVtcSDKErrorCode.transportFailed);
        expect(status.lastKnown?.revoked, isTrue);
      });

      test('says when a card cannot be revoked, or has expired', () async {
        hold([
          card(),
          card(
            id: 'urn:uuid:old',
            status: FakeVtcNetwork.statusEntry(7),
            validUntil: '2020-01-01T00:00:00Z',
          ),
        ]);
        final entries = await service.membershipCredentials();

        final states = [
          for (final entry in entries)
            (await service.checkMembershipStatus(entry)).state,
        ];

        expect(states, [VtcCardState.notRevocable, VtcCardState.expired]);
        expect(network.statusListFetches, 0);
      });
    });
  });

  group('VtcService mock credentials', () {
    const ada = 'did:webvh:QmAda:host.example';
    const bo = 'did:webvh:QmBo:host.example';

    setUp(() async {
      await service.startLink(vta.did);
      await service.checkGrant();
    });

    test('imports a test credential for an identity', () async {
      vta.answers[VtaTask.credentialsReceive] = {'status': 'valid'};

      final kept = await service.importMockCredential(
        mockCredentialTemplates.first,
        personaDid: ada,
        contextId: 'vta',
      );

      expect(kept, isTrue);
      final payload =
          vta.received.lastWhere(
                (r) => r['type'] == VtaTask.credentialsReceive,
              )['payload']
              as Map;
      expect(payload['contextId'], 'vta');
      final credential = payload['credential'] as Map;
      expect((credential['credentialSubject'] as Map)['id'], ada);
      expect(credential['type'], [
        'VerifiableCredential',
        'MembershipCredential',
      ]);
      expect(payload['id'], credential['id']);
    });

    test('says which identities hold each test credential', () async {
      vta.answerTo[VtaTask.credentialsQuery] = (payload) => {
        'credentials': [
          if (payload['subjectDid'] == ada)
            {
              'id': 'card-1',
              'types': ['VerifiableCredential', 'MembershipCredential'],
              'status': 'valid',
            },
        ],
      };

      final holders = await service.mockCredentialHolders([ada, bo]);

      expect(holders, {
        'membership': {ada},
      });
      final queries = [
        for (final r in vta.received)
          if (r['type'] == VtaTask.credentialsQuery) r['payload'] as Map,
      ];
      expect(queries, hasLength(2), reason: 'one query per identity');
      expect(
        queries.map((q) => q['issuerDid']).toSet().single,
        startsWith('did:key:'),
      );
    });
  });

  group('VtcService card collection', () {
    late FakeVtcNetwork network;
    late FakePersona persona;
    late List<VtcCardDelivery> deliveries;

    Map<String, dynamic> card() => {
      'id': 'urn:uuid:vmc',
      'type': ['VerifiableCredential', 'MembershipCredential'],
      'issuer': fakeVtcDid,
      'credentialSubject': {'id': persona.did},
    };

    Iterable<Object?> vtaTasks() =>
        network.vta.received.map((request) => request['type']);

    /// The last report's status of each step.
    Map<VtcDeliveryStep, VtcDeliveryStatus> statuses() => {
      for (final step in VtcDeliveryStep.values)
        step: deliveries.last.status(step),
    };

    Future<void> approve() async {
      network.joinVerdict = {'effect': 'refer'};
      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: VtaPersona(
          did: persona.did,
          contextId: 'mpx-ada',
          signingKeyId: persona.signingKeyId,
        ),
      );
      network.joinStatus = 'approved';
    }

    setUp(() async {
      network = FakeVtcNetwork();
      persona = FakePersona(mediatorDid: network.mediatorDid);
      deliveries = [];
      network.vta
        ..persona = persona
        ..otherDocuments[persona.did] = persona.document
        ..answers[VtaTask.vaultUpsert] = {
          'entry': {'id': 'entry-1'},
        }
        ..answers[VtaTask.signDocument] = {
          'document': {
            'issuer': persona.did,
            'proof': {'proofPurpose': 'assertionMethod'},
          },
        }
        ..answerTo[VtaTask.exportSecret] = (payload) =>
            persona.exportAnswer(payload['keyId']);
      service = VtcService(
        sdk: network.sdk(),
        repository: SecureStorageVtcRepository(),
        userVerificationKey: UserVerificationKey(keyStorage),
        platform: 'ios',
      );
      await service.startLink(network.vta.did);
      await service.checkGrant();
    });

    test('collects the card from the identity inbox and keeps it', () async {
      await approve();
      await network.deliver(persona, card());

      await service.checkApplication(
        fakeVtcDid,
        onCardDelivery: deliveries.add,
      );

      expect(statuses().values, everyElement(VtcDeliveryStatus.done));
      final delivery = deliveries.last;
      expect(delivery.personaDid, persona.did);
      expect(delivery.signingKeyId, persona.signingKeyId);
      expect(delivery.keyAgreementKeyId, persona.keyAgreementKeyId);
      expect(delivery.mediatorDid, network.mediatorDid);
      expect(delivery.waiting, 1);
      expect(delivery.issue?.type, credentialIssueTask);
      expect(delivery.issue?.issuer, fakeVtcDid);
      expect(delivery.isKeptAsValid, isTrue);
      // Kept on the VTA, then taken out of the inbox, then confirmed.
      final keep = network.vta.received.lastWhere(
        (request) => request['type'] == VtaTask.credentialsReceive,
      );
      expect((keep['payload'] as Map)['credential'], card());
      expect((keep['payload'] as Map)['contextId'], 'mpx-ada');
      expect(network.inboxDeleted, ['message-1']);
      expect(network.memberRequests.first['type'], MemberTask.vmc);
      expect((await service.community(fakeVtcDid))?.isSettled, isTrue);
    });

    test('waits for the community, asking it to deliver again', () async {
      await approve();

      await service.checkApplication(
        fakeVtcDid,
        onCardDelivery: deliveries.add,
      );

      expect(statuses(), {
        VtcDeliveryStep.keysLent: VtcDeliveryStatus.done,
        VtcDeliveryStep.signedIn: VtcDeliveryStatus.done,
        VtcDeliveryStep.pickedUp: VtcDeliveryStatus.waiting,
        VtcDeliveryStep.kept: VtcDeliveryStatus.next,
        VtcDeliveryStep.confirmed: VtcDeliveryStatus.next,
      });
      expect(deliveries.last.waiting, 0);
      expect(network.joinRequests.last['payload'], {
        'requestId': 'request-1',
        'resendCredentials': true,
      });
      expect((await service.community(fakeVtcDid))?.isSettled, isFalse);
    });

    test('says when the VTA does not lend the keys', () async {
      await approve();
      network.vta.refusals[VtaTask.exportSecret] = {
        'code': 'keys/export-secret:notExportable',
      };

      await service.checkApplication(
        fakeVtcDid,
        onCardDelivery: deliveries.add,
      );

      expect(
        deliveries.last.status(VtcDeliveryStep.keysLent),
        VtcDeliveryStatus.failed,
      );
      expect(network.inboxOpens, 0);
    });

    test('says when the inbox cannot be reached', () async {
      await approve();
      network.isMediatorDown = true;

      await service.checkApplication(
        fakeVtcDid,
        onCardDelivery: deliveries.add,
      );

      expect(
        deliveries.last.status(VtcDeliveryStep.signedIn),
        VtcDeliveryStatus.failed,
      );
    });

    test('borrows the keys once while it keeps checking', () async {
      await approve();

      await service.checkApplication(fakeVtcDid);
      await service.checkApplication(fakeVtcDid);

      int loans() =>
          vtaTasks().where((type) => type == VtaTask.exportSecret).length;
      // Two keys, lent once.
      expect(loans(), 2);
      expect(network.inboxOpens, 1);

      await service.endCardCollection(fakeVtcDid);
      await service.checkApplication(fakeVtcDid);

      expect(loans(), 4);
      expect(network.inboxOpens, 2);
    });

    test('reports nothing for a card the VTA already holds', () async {
      network.vta
        ..answers[VtaTask.credentialsQuery] = {
          'credentials': [
            {'id': 'card-1'},
          ],
        }
        ..answers[VtaTask.credentialsGet] = {'credential': card()};
      await approve();

      await service.checkApplication(
        fakeVtcDid,
        onCardDelivery: deliveries.add,
      );

      expect(deliveries, isEmpty);
      expect(vtaTasks(), isNot(contains(VtaTask.exportSecret)));
      expect((await service.community(fakeVtcDid))?.isSettled, isTrue);
    });
  });

  group('VtcService vetting', () {
    late FakeVtcNetwork network;
    late FakePersona persona;
    late JoinManifest manifest;

    JoinCriterion vetted() =>
        manifest.criteria.singleWhere((criterion) => criterion.id == 'vetted');

    VettingTicket ticket({String community = fakeVtcDid}) =>
        VettingTicket.spoken(
          community: community,
          vetter: network.vetterDid,
          code: 'K7QF-2M9X',
        )!;

    /// What [start] and sending the card reported, in order.
    final steps = <VtcVettingWork>[];

    Future<VtcVetting> start() => service.startVetting(
      manifest,
      criterion: vetted(),
      ticket: ticket(),
      vetterName: 'Bob',
      onStep: steps.add,
    );

    Future<VtcVettingRequest> requestAfterCheck() async =>
        (await service.checkVetting(fakeVtcDid))!.requests.single;

    setUp(() async {
      steps.clear();
      network = FakeVtcNetwork()
        ..joinManifest = {
          'communityDid': fakeVtcDid,
          'criteria': [
            {
              'id': 'vetted',
              'admission': 'automatic',
              'requirementsDigest': 'zVetted',
              'vetting': {
                'version': '0.1',
                'statementType': VettingStatement.predicate,
                'minStatements': 1,
                'acceptedMethods': ['inPerson'],
                'eligibleVetters': {'role': 'vetter'},
                'requiredClaims': ['name.legal'],
              },
            },
          ],
        };
      persona = FakePersona(mediatorDid: network.mediatorDid);
      network.vta
        ..persona = persona
        ..otherDocuments[persona.did] = persona.document
        ..answers[VtaTask.vaultUpsert] = {
          'entry': {'id': 'entry-1'},
        }
        ..answers[VtaTask.disclosurePreview] = {
          'previewId': 'preview-1',
          'claims': [
            {'type': 'name.legal', 'value': 'Ada Lovelace'},
          ],
        }
        ..answers[VtaTask.disclosurePresent] = {'presented': true}
        ..answerTo[VtaTask.exportSecret] = (payload) =>
            persona.exportAnswer(payload['keyId']);
      service = VtcService(
        sdk: network.sdk(),
        repository: SecureStorageVtcRepository(),
        userVerificationKey: UserVerificationKey(keyStorage),
        platform: 'ios',
      );
      await service.startLink(network.vta.did);
      await service.checkGrant();
      manifest = await service.readCommunity(fakeVtcDid);
      await service.joiningIdentity(
        manifest,
        persona: VtaPersona(
          did: persona.did,
          contextId: 'mpx-ada',
          signingKeyId: persona.signingKeyId,
        ),
      );
    });

    test('lists the vetters as the identity applying', () async {
      network.listedVetters = [
        {
          'vetterDid': network.vetterDid,
          'displayName': 'Bob',
          'methods': ['inPerson'],
        },
      ];

      final vetters = await service.vetters(manifest);

      expect(vetters.single.displayName, 'Bob');
    });

    test('asks the vetter and records the request', () async {
      final vetting = await start();

      expect(network.sentToMembers.single.next, network.vetterDid);
      expect(vetting.criterionId, 'vetted');
      expect(vetting.vetterRole, 'vetter');
      final request = vetting.requests.single;
      expect(request.status, VtcVettingStatus.requested);
      expect(request.vetterName, 'Bob');
      expect(request.requestDocument.payload['ticket'], {'code': 'K7QF-2M9X'});
      expect(await service.vetting(fakeVtcDid), isNotNull);
    });

    test('refuses a ticket of another community', () async {
      await expectLater(
        service.startVetting(
          manifest,
          criterion: vetted(),
          ticket: ticket(community: 'did:web:other.example'),
        ),
        throwsA(
          isA<VettingException>().having(
            (e) => e.failure,
            'failure',
            VettingFailure.otherCommunity,
          ),
        ),
      );
      expect(network.sentToMembers, isEmpty);
    });

    test('is vouched for through a whole session', () async {
      final request = (await start()).requests.single.request;
      expect(steps, [
        VtcVettingWork.unlockingIdentity,
        VtcVettingWork.sendingRequest,
      ]);

      await network.vetterAccepts(persona, request);
      expect((await requestAfterCheck()).status, VtcVettingStatus.accepted);

      await network.vetterOpensSession(persona);
      final inSession = await requestAfterCheck();
      expect(inSession.status, VtcVettingStatus.inSession);

      final preview = await service.previewVettingCard(
        fakeVtcDid,
        network.vetterDid,
      );
      expect(preview.claims.single.type, 'name.legal');
      steps.clear();
      final afterCard = (await service.sendVettingCard(
        fakeVtcDid,
        network.vetterDid,
        preview: preview,
        onStep: steps.add,
      )).requests.single;
      expect(afterCard.status, VtcVettingStatus.cardSent);
      expect(steps, [
        VtcVettingWork.recordingDisclosure,
        VtcVettingWork.sendingDetails,
      ]);
      expect(network.sentToMembers, hasLength(2));
      expect(
        network.vta.received.map((r) => r['type']),
        contains(VtaTask.disclosurePresent),
      );

      await network.vetterVouches(
        persona,
        session: inSession.session!,
        cardDigest: afterCard.cardDigest!,
        identityCommitment: afterCard.identityCommitment!,
      );
      final vouched = await requestAfterCheck();
      expect(vouched.status, VtcVettingStatus.vouched);
      expect(network.inbox, isEmpty);

      await service.join(manifest, criterion: vetted());
      final submit = network.joinRequests.lastWhere(
        (r) => r['type'] == JoinTask.submit,
      );
      final vp = (submit['payload'] as Map)['vp'] as Map;
      expect(vp['verifiableCredential'], [vouched.statement]);
    });

    test('records a vetter who cannot show the role as refused', () async {
      final request = (await start()).requests.single.request;
      await network.vetterAccepts(persona, request, role: 'admin');

      final refused = await requestAfterCheck();

      expect(refused.status, VtcVettingStatus.refused);
      expect(refused.failure, VettingFailure.notVetter);
    });

    test('records a decline, and a session the member ended', () async {
      final request = (await start()).requests.single.request;
      await network.vetterAccepts(persona, request);
      await network.vetterOpensSession(persona);
      await requestAfterCheck();

      final ended = await service.abandonVetting(fakeVtcDid, network.vetterDid);
      expect(ended.requests.single.status, VtcVettingStatus.abandoned);

      await start();
      await network.vetterAccepts(
        persona,
        (await service.vetting(fakeVtcDid))!.requests.single.request,
      );
      await network.vetterSends(persona, VettingTask.decline, {
        'requestId': 'vr-1',
        'code': 'couldNotVerify',
      });
      final declined = await requestAfterCheck();
      expect(declined.status, VtcVettingStatus.declined);
      expect(declined.declineCode, 'couldNotVerify');
    });
  });

  group('VtcService vetter desk', () {
    late FakeVetterDesk fixture;
    late FakeVtcNetwork network;
    late FakePersona vetter;

    Future<TrustTaskDocument> applicantSends(
      String type,
      Map<String, dynamic> payload,
    ) => fixture.applicantSends(type, payload);
    Future<TrustTaskDocument> requestWith(VettingTicket ticket) =>
        fixture.requestWith(ticket);
    Future<TrustTaskDocument> sendCard(TrustTaskDocument session) =>
        fixture.sendCard(session);
    Future<List<TrustTaskDocument>> sentToApplicant() =>
        fixture.sentToApplicant();

    setUp(() async {
      fixture = FakeVetterDesk();
      await fixture.setUp();
      network = fixture.network;
      vetter = fixture.vetter;
      service = fixture.service;
    });

    test('lets a member vet while their vetter card holds', () async {
      expect(await service.canVet(fakeVtcDid), isTrue);
      expect(await service.canVet('did:web:other.example'), isFalse);

      network.revoked.add(3);

      expect(await service.canVet(fakeVtcDid), isFalse);
      await expectLater(
        service.createVettingTicket(fakeVtcDid),
        throwsA(isA<NotVetterException>()),
      );
    });

    test('keeps the vetter card the community sent to the inbox', () async {
      // The VTA holds the card only once it was kept.
      bool kept() => network.vta.received.any(
        (task) =>
            task['type'] == VtaTask.credentialsReceive &&
            (task['payload'] as Map<String, dynamic>)['id'] ==
                'urn:uuid:vetter-card',
      );
      network.vta.answerTo[VtaTask.credentialsQuery] = (payload) => {
        'credentials': [
          if (payload['type'] == 'AuthorityCredential' && kept())
            {
              'id': 'role-1',
              'types': ['VerifiableCredential', 'AuthorityCredential'],
            },
        ],
      };
      final card = await network.vetterRoleCard(vetter.did);
      await network.deliver(vetter, card);

      expect(await service.canVet(fakeVtcDid), isTrue);

      final receive = network.vta.received.lastWhere(
        (task) => task['type'] == VtaTask.credentialsReceive,
      );
      expect((receive['payload'] as Map<String, dynamic>)['credential'], card);
      expect(network.inbox, isEmpty);
    });

    test('hands over the vetter card it checked', () async {
      final card = await service.vetterCard(fakeVtcDid);

      expect(card?.issuer, fakeVtcDid);
      expect(card?.vetterDid, vetter.did);
      expect(card?.validUntil, isNotNull);

      network.revoked.add(3);
      expect(await service.vetterCard(fakeVtcDid), isNull);
    });

    test('remembers whether the member could vet', () async {
      expect(await service.couldVet(fakeVtcDid), isFalse);

      await service.canVet(fakeVtcDid);
      expect(await service.couldVet(fakeVtcDid), isTrue);

      network.revoked.add(3);
      await service.canVet(fakeVtcDid);
      expect(await service.couldVet(fakeVtcDid), isFalse);
    });

    test('cannot vet while no vetter card was sent', () async {
      network.vta.answerTo[VtaTask.credentialsQuery] = (_) => {
        'credentials': <Object>[],
      };

      expect(await service.canVet(fakeVtcDid), isFalse);
    });

    group('vetter profile', () {
      const profile = VetterProfile(
        listed: true,
        displayName: 'Bob',
        languages: ['en'],
        methods: [VettingMethod.inPerson],
      );

      test('publishes it as the member and records it', () async {
        final desk = await service.publishVetterProfile(fakeVtcDid, profile);

        final request = network.vetterProfiles.single;
        expect(request['issuer'], vetter.did);
        expect(request['payload'], profile.toJson());
        final recorded = (await service.vetterDesk(fakeVtcDid))!.profile!;
        expect(recorded.profile.toJson(), profile.toJson());
        expect(recorded.listed, isTrue);
        expect(recorded.updatedAt, DateTime.utc(2026, 11, 6, 9));
        expect(recorded.roleCardId, 'urn:uuid:vetter-card');
        expect(desk.profile!.toJson(), recorded.toJson());
      });

      test('is needed until published under the card held', () async {
        expect(await service.vetterProfileNeeded(fakeVtcDid), isTrue);

        await service.publishVetterProfile(fakeVtcDid, profile);

        expect(await service.vetterProfileNeeded(fakeVtcDid), isFalse);
      });

      test('is needed again once a new card replaced the old', () async {
        await service.publishVetterProfile(fakeVtcDid, profile);
        final desk = (await service.vetterDesk(fakeVtcDid))!;
        await SecureStorageVtcRepository().saveVetterDesk(
          desk.withProfile(
            VtcVetterProfileRecord(
              profile: profile,
              listed: true,
              updatedAt: DateTime.utc(2026),
              roleCardId: 'urn:uuid:revoked-card',
            ),
          ),
        );

        expect(await service.vetterProfileNeeded(fakeVtcDid), isTrue);
      });

      test('is not needed, nor sent, by a member who may not vet', () async {
        network.revoked.add(3);

        expect(await service.vetterProfileNeeded(fakeVtcDid), isFalse);
        await expectLater(
          service.publishVetterProfile(fakeVtcDid, profile),
          throwsA(isA<NotVetterException>()),
        );
        expect(network.vetterProfiles, isEmpty);
      });

      test('reads the community saying no vetter as such', () async {
        network.vetterProfileRefusal = (
          403,
          VettingCommunityTask.profileNotEligible,
        );

        await expectLater(
          service.publishVetterProfile(fakeVtcDid, profile),
          throwsA(isA<NotVetterException>()),
        );
        expect((await service.vetterDesk(fakeVtcDid))?.profile, isNull);
      });
    });

    test('mints a ticket for one applicant, for 15 minutes', () async {
      final before = DateTime.now();
      final ticket = await service.createVettingTicket(fakeVtcDid);

      final desk = (await service.vetterDesk(fakeVtcDid))!;
      expect(desk.tickets.single.toJson(), ticket.toJson());
      expect(ticket.usesLeft, 1);
      final lasts = ticket.expiresAt.difference(before);
      expect(lasts, greaterThanOrEqualTo(VtcService.vettingTicketValidity));
      expect(
        lasts,
        lessThan(VtcService.vettingTicketValidity + const Duration(minutes: 1)),
      );
      expect(ticket.vetter, vetter.did);
    });

    test('cancels the tickets shown, so none admits an applicant', () async {
      final ticket = await service.createVettingTicket(fakeVtcDid);

      final desk = (await service.cancelVettingTickets(fakeVtcDid))!;
      expect(desk.tickets, isEmpty);
      expect((await service.vetterDesk(fakeVtcDid))!.tickets, isEmpty);

      await requestWith(ticket.spoken);
      final after = (await service.checkVetterDesk(fakeVtcDid))!;
      expect(after.sessions, isEmpty);
    });

    test('reports each step of minting a ticket', () async {
      final steps = <VtcTicketStep>[];

      await service.createVettingTicket(fakeVtcDid, onStep: steps.add);

      expect(steps, [VtcTicketStep.checkingCard, VtcTicketStep.creating]);
    });

    test('asks the applicant for the details already known', () async {
      final ticket = await service.createVettingTicket(fakeVtcDid);
      await requestWith(ticket.spoken);

      final desk = (await service.checkVetterDesk(
        fakeVtcDid,
        requiredClaims: ['name.given'],
      ))!;

      expect(desk.sessions.single.session!.requiredClaims, ['name.given']);
    });

    test('reports each step of taking a request', () async {
      final ticket = await service.createVettingTicket(fakeVtcDid);
      await requestWith(ticket.spoken);
      final steps = <VtcRequestStep>[];

      await service.checkVetterDesk(fakeVtcDid, onRequestStep: steps.add);

      expect(steps, [
        VtcRequestStep.checkingCard,
        VtcRequestStep.openingSession,
      ]);
    });

    test('vets an applicant from request to statement', () async {
      final ticket = await service.createVettingTicket(fakeVtcDid);
      await requestWith(ticket.spoken);

      var desk = (await service.checkVetterDesk(fakeVtcDid))!;
      final session = desk.sessions.single;
      expect(session.status, VtcVetterSessionStatus.inSession);
      expect(session.session!.requiredClaims, ['name.legal']);
      expect(desk.liveTickets(DateTime.now()), isEmpty);
      final [accepted, opened] = await sentToApplicant();
      expect(accepted.type, VettingTask.requestResponse);
      expect(opened.type, VettingTask.session);

      final card = await sendCard(opened);
      await service.checkVetterDesk(fakeVtcDid);
      final requestId = session.request.requestId;
      expect(
        service.vettingCard(requestId)!.claims.single.value,
        'Ada Lovelace',
      );
      expect(network.inbox.values, hasLength(1));

      await expectLater(
        service.issueVettingStatement(
          fakeVtcDid,
          requestId,
          documentClasses: ['passport'],
        ),
        throwsStateError,
      );
      await service.confirmVettingMatch(fakeVtcDid, requestId);
      desk = await service.issueVettingStatement(
        fakeVtcDid,
        requestId,
        documentClasses: ['passport'],
      );

      expect(desk.sessions.single.status, VtcVetterSessionStatus.issued);
      final issue = (await sentToApplicant()).last;
      expect(issue.type, VettingTask.issue);
      expect(issue.threadId, opened.id);
      expect(service.vettingCard(requestId), isNull);
      expect(network.inbox, isEmpty);
      expect(card.payload['card'], isNotNull);
      final [record] = await service.issuedVettingStatements(fakeVtcDid);
      expect(record.statementId, desk.sessions.single.statementId);
      expect('${network.vta.appState}', isNot(contains('Ada')));
    });

    test('leaves a wrong code unanswered', () async {
      await service.createVettingTicket(fakeVtcDid);
      await requestWith(
        VettingTicket.withCode(
          community: fakeVtcDid,
          vetter: vetter.did,
          code: '0000-0000',
        ),
      );

      final desk = (await service.checkVetterDesk(fakeVtcDid))!;

      expect(desk.sessions, isEmpty);
      expect(desk.tickets.single.usesLeft, 1);
      expect(await sentToApplicant(), isEmpty);
      expect(network.inbox, isEmpty);
    });

    test('declines, and ends a session the applicant declined', () async {
      await requestWith((await service.createVettingTicket(fakeVtcDid)).spoken);
      await requestWith((await service.createVettingTicket(fakeVtcDid)).spoken);
      final [first, second] = (await service.checkVetterDesk(
        fakeVtcDid,
      ))!.sessions;

      await service.declineVetting(
        fakeVtcDid,
        first.request.requestId,
        code: 'couldNotVerify',
      );
      await applicantSends(VettingTask.decline, {
        'requestId': second.request.requestId,
      });
      final desk = (await service.checkVetterDesk(fakeVtcDid))!;

      expect(
        desk.sessionFor(first.request.requestId)!.status,
        VtcVetterSessionStatus.declined,
      );
      expect(
        desk.sessionFor(second.request.requestId)!.status,
        VtcVetterSessionStatus.ended,
      );
      expect((await sentToApplicant()).last.payload, {
        'requestId': first.request.requestId,
        'code': 'couldNotVerify',
      });
    });
  });

  group('VtcService watching a community', () {
    late FakeVtcNetwork network;
    late FakePersona member;

    setUp(() async {
      // A member holding the vetter role.
      final fixture = FakeVetterDesk();
      await fixture.setUp();
      network = fixture.network;
      member = fixture.vetter;
      service = fixture.service;
      addTearDown(() => service.unwatchCommunity(fakeVtcDid));
    });

    bool kept(String cardId) => network.vta.received.any(
      (task) =>
          task['type'] == VtaTask.credentialsReceive &&
          (task['payload'] as Map<String, dynamic>)['id'] == cardId,
    );

    test(
      'keeps a role card pushed while watched and tells the new role',
      () async {
        await service.watchCommunity(fakeVtcDid);
        final change = service.roleChanged.first;

        await network.deliver(
          member,
          await network.roleCard(member.did, role: 'admin'),
        );
        network.inboxArrivals.add(null);

        expect(
          await change.timeout(const Duration(seconds: 5)),
          isA<VtcRoleChange>()
              .having((change) => change.communityDid, 'community', fakeVtcDid)
              .having((change) => change.role, 'role', 'admin'),
        );
        expect(kept('urn:uuid:admin-card'), isTrue);
        expect(network.inbox, isEmpty);
      },
    );

    test('tells no new role for a card of the role held', () async {
      await service.watchCommunity(fakeVtcDid);
      final roles = <String>[];
      final listening = service.roleChanged.listen(
        (change) => roles.add(change.role),
      );
      addTearDown(listening.cancel);
      final changed = service.membershipsChanged.first;

      await network.deliver(member, await network.vetterRoleCard(member.did));
      network.inboxArrivals.add(null);
      await changed.timeout(const Duration(seconds: 5));

      expect(kept('urn:uuid:vetter-card'), isTrue);
      expect(roles, isEmpty);
    });

    test('keeps what was pushed before watching', () async {
      await network.deliver(
        member,
        await network.roleCard(member.did, role: 'admin'),
      );
      final roles = <String>[];
      final listening = service.roleChanged.listen(
        (change) => roles.add(change.role),
      );
      addTearDown(listening.cancel);

      await service.watchCommunity(fakeVtcDid);
      await pumpEventQueue();

      expect(roles, ['admin']);
      expect(network.inbox, isEmpty);
    });

    group('removed', () {
      bool archived() => network.vta.received.any(
        (task) => task['type'] == VtaTask.credentialsArchive,
      );

      test('forgets the community once told it removed the member, and says '
          'why', () async {
        await service.watchCommunity(fakeVtcDid);
        final removal = service.removed.first;
        // The membership card the member's VTA keeps.
        network.vta.answerTo.remove(VtaTask.credentialsQuery);
        network.vta
          ..answers[VtaTask.credentialsQuery] = {
            'credentials': [
              {'id': 'card-1'},
            ],
          }
          ..answers[VtaTask.credentialsGet] = {
            'credential': {
              'issuer': fakeVtcDid,
              'credentialSubject': {'id': member.did},
            },
          };

        await network.notifyRemoval(member, reason: 'Spam.');
        network.inboxArrivals.add(null);

        expect(
          await removal.timeout(const Duration(seconds: 5)),
          isA<VtcRemoval>()
              .having((r) => r.communityDid, 'community', fakeVtcDid)
              .having((r) => r.reason, 'reason', 'Spam.'),
        );
        expect(await service.community(fakeVtcDid), isNull);
        expect(archived(), isTrue);
        final left =
            (await SecureStorageVtcRepository().leftMemberships()).single;
        expect(left.communityDid, fakeVtcDid);
        expect(left.card?['issuer'], fakeVtcDid);
        expect(left.leftAt, DateTime.utc(2026, 11, 10, 9));
        expect(left.leaveExchange, isNull);
        expect(left.removalNotice?.issuer, fakeVtcDid);
        expect(left.removalNotice?.payload['reason'], 'Spam.');
        expect(network.inbox, isEmpty);
        expect(network.inboxArrivals.hasListener, isFalse);
      });

      test('forgets the community told before watching', () async {
        await network.notifyRemoval(member);
        final removal = service.removed.first;

        await service.watchCommunity(fakeVtcDid);

        expect(
          (await removal.timeout(const Duration(seconds: 5))).reason,
          isNull,
        );
        expect(await service.community(fakeVtcDid), isNull);
        expect(network.inboxArrivals.hasListener, isFalse);
      });

      test('lets later unwatching be', () async {
        await network.notifyRemoval(member);
        await service.watchCommunity(fakeVtcDid);

        await service.unwatchCommunity(fakeVtcDid);

        expect(await service.community(fakeVtcDid), isNull);
      });
    });

    test('lets go of the inbox once unwatched', () async {
      await service.watchCommunity(fakeVtcDid);
      expect(network.inboxArrivals.hasListener, isTrue);

      await service.unwatchCommunity(fakeVtcDid);

      expect(network.inboxArrivals.hasListener, isFalse);
    });

    test('does nothing for a community it knows nothing of', () async {
      await service.watchCommunity('did:web:other.example');

      expect(network.inboxArrivals.hasListener, isFalse);
    });

    test('tells each arrival in the watched inbox', () async {
      await service.watchCommunity(fakeVtcDid);
      final arrived = service.inboxArrived.first;

      network.inboxArrivals.add(null);

      expect(await arrived.timeout(const Duration(seconds: 5)), fakeVtcDid);
    });

    test('keeps watching while another still holds the watch', () async {
      await service.watchCommunity(fakeVtcDid);
      await service.watchCommunity(fakeVtcDid);

      await service.unwatchCommunity(fakeVtcDid);
      expect(network.inboxArrivals.hasListener, isTrue);

      await service.unwatchCommunity(fakeVtcDid);
      expect(network.inboxArrivals.hasListener, isFalse);
    });

    test('watches the inbox of an applicant, not yet a member', () async {
      const appliedDid = 'did:web:applied.example';
      await SecureStorageVtcRepository().saveCommunity(
        VtcCommunity(
          communityDid: appliedDid,
          personaDid: member.did,
          contextId: 'mpx-bob',
          name: 'Applied club',
          isMember: false,
          joinRequestId: 'request-1',
        ),
      );
      addTearDown(() => service.unwatchCommunity(appliedDid));

      await service.watchCommunity(appliedDid);
      final arrived = service.inboxArrived.first;
      network.inboxArrivals.add(null);

      expect(await arrived.timeout(const Duration(seconds: 5)), appliedDid);
    });
  });
}
