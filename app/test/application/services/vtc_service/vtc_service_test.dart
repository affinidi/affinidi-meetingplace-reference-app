import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/mock_credential_template.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_card_delivery.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_membership_entry.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/mock_credential_issuer.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';

import '../../../fakes/fake_persona.dart';
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

    test('is a member even when the VTA keeps no card', () async {
      network.vta.refusals[VtaTask.credentialsReceive] = {
        'code': 'vault/credentials/receive:proofSetUnsupported',
      };

      await service.join(
        await service.readCommunity(fakeVtcDid),
        persona: joinAs,
      );

      expect((await service.community(fakeVtcDid))?.isMember, isTrue);
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
        await service.withdraw(fakeVtcDid);

        final request = network.joinRequests.last;
        expect(request['type'], JoinTask.withdraw);
        expect(request['issuer'], persona.did);
        expect(request['payload'], {'requestId': 'request-1'});
        final community = await service.community(fakeVtcDid);
        expect(community?.isApplying, isFalse);
        expect(community?.isMember, isFalse);
        expect(community?.submitExchange, isNull);
        expect(community?.personaDid, persona.did);
      });

      test('forgets an application the community no longer holds', () async {
        network.withdrawRefusal = 'vtc/join-requests/withdraw:notFound';

        await service.withdraw(fakeVtcDid);

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

        await service.refreshMembership(fakeVtcDid);
        await Future<void>.delayed(Duration.zero);
        await listening.cancel();

        final renewal = network.memberRequests.last;
        expect(renewal['type'], MemberTask.renew);
        expect(renewal['issuer'], persona.did);
        expect(kept(), ['urn:uuid:vmc-renewed', 'urn:uuid:vac-renewed']);
        expect(changes, 1);
      });

      test('keeps nothing while the role is unchanged', () async {
        var changes = 0;
        final listening = service.membershipsChanged.listen((_) => changes++);

        await service.refreshMembership(fakeVtcDid);
        await Future<void>.delayed(Duration.zero);
        await listening.cancel();

        expect(network.memberRequests.last['type'], MemberTask.renew);
        expect(kept(), isEmpty);
        expect(changes, 0);
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
}
