import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show MeetingPlaceCoreSDKException;
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/community_offer_service/community_offer_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_card_delivery.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_join_state.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';
import '../../../fakes/fake_persona.dart';
import '../../../fakes/fake_vta.dart';
import '../../../fakes/fake_vtc_network.dart';

/// Finds the communities of [phrases]; any other phrase fails with
/// [failure].
class _FakeCommunityOffers implements CommunityOfferService {
  final phrases = <String, String>{};
  Exception failure = const CommunityPhraseException(
    CommunityPhraseProblem.notFound,
  );
  final lookedUp = <String>[];

  @override
  Future<String> findCommunity(String phrase) async {
    lookedUp.add(phrase);
    return phrases[phrase] ?? (throw failure);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late FakeVtcNetwork network;
  late _FakeCommunityOffers communityOffers;
  late VtcService service;
  late ProviderContainer container;
  late Ed25519DidKeySigner persona;

  /// The member's identities on this phone.
  var identities = IdentitiesServiceState();

  VtcJoinController controller() =>
      container.read(vtcJoinControllerProvider.notifier);
  VtcJoinState state() => container.read(vtcJoinControllerProvider);

  void useService() {
    container = ProviderContainer(
      overrides: [
        vtcServiceProvider.overrideWithValue(service),
        communityOfferServiceProvider.overrideWithValue(communityOffers),
        identitiesServiceProvider.overrideWith(
          () => FakeIdentitiesService(identities),
        ),
      ],
    );
    container.listen(vtcJoinControllerProvider, (_, _) {});
  }

  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/vtc_join_controller_test.log'),
    );
  });

  setUp(() async {
    identities = IdentitiesServiceState();
    FlutterSecureStorage.setMockInitialValues({});
    communityOffers = _FakeCommunityOffers();
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
      expect(state().chosenWayId, 'open');
      expect(state().requestedDetails.single.type, 'name');
      expect(state().listsNewMembers, isTrue);
      expect(state().listInDirectory, isFalse, reason: 'off by default');

      controller().setListInDirectory(true);
      expect(state().listInDirectory, isTrue);
    });

    group('choosing the way in', () {
      setUp(() {
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
              'admission': 'automatic',
              'requirementsDigest': 'zOpen',
            },
            {
              'id': 'reviewed',
              'admission': 'review',
              'requirementsDigest': 'zReviewed',
            },
          ],
        };
      });

      Map<dynamic, dynamic> submitted() =>
          network.joinRequests.lastWhere(
                (r) => r['type'] == JoinTask.submit,
              )['payload']
              as Map;

      test('applies under the first supported way unless told', () async {
        await controller().onScanned(fakeVtcDid);
        expect(state().chosenWayId, 'open');

        await controller().join();

        expect(submitted()['criterion'], 'zOpen');
      });

      test('applies under the way the member chose', () async {
        await controller().onScanned(fakeVtcDid);

        controller().chooseWay('reviewed');
        expect(state().chosenWayId, 'reviewed');
        await controller().join();

        expect(submitted()['criterion'], 'zReviewed');
      });

      test('shows but does not apply under an unsupported way', () async {
        await controller().onScanned(fakeVtcDid);

        controller().chooseWay('unknown');
        expect(state().chosenWayId, 'open');

        controller().chooseWay('invited');
        expect(state().chosenWayId, 'invited');
        await controller().join();

        expect(state().step, VtcJoinStep.review);
        expect(
          network.joinRequests.map((r) => r['type']),
          isNot(contains(JoinTask.submit)),
        );
      });
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
      identities = IdentitiesServiceState(
        identities: [_vtaIdentity(persona.did, 'Ada')],
      );
    }

    bool createdPersona() =>
        network.vta.received.any((r) => r['type'] == VtaTask.didsCreate);

    test('joins as an identity the VTA already holds', () async {
      vtaHoldsPersona();
      await controller().onScanned(fakeVtcDid);

      await controller().join();
      expect(state().step, VtcJoinStep.chooseIdentity);
      expect(state().identityChoices, [persona.did]);
      expect(state().identities[persona.did]?.card.displayName, 'Ada');

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

  group('VtcJoinController credential', () {
    const other = 'did:webvh:QmOther:host.example';
    const membership = ['VerifiableCredential', 'MembershipCredential'];

    setUp(() {
      network.joinManifest = {
        ...network.joinManifest,
        'criteria': [
          {
            'id': 'members',
            'admission': 'automatic',
            'requirementsDigest': 'zMembers',
            'credentialIssuers': 'any',
            'presentationDefinition': {
              'credentials': [
                {
                  'id': 'membership',
                  'format': 'ldp_vc',
                  'meta': {
                    'type_values': [membership],
                  },
                },
              ],
            },
          },
        ],
      };
      identities = IdentitiesServiceState(
        identities: [
          _vtaIdentity(persona.did, 'Ada'),
          _vtaIdentity(other, 'Bo'),
        ],
      );
      // Only Ada holds a membership card.
      network.vta.answerTo[VtaTask.credentialsQuery] = (payload) => {
        'credentials': [
          if (payload['subjectDid'] == persona.did)
            {
              'id': 'card-1',
              'types': membership,
              'status': 'valid',
              'issuerDid': 'did:web:chess.example',
            },
        ],
      };
      network.vta.answers[VtaTask.credentialsGet] = {
        'credential': {
          'id': 'urn:uuid:card',
          'type': membership,
          'issuer': 'did:web:chess.example',
          'credentialSubject': {'id': persona.did, 'memberOf': 'Chess club'},
        },
      };
    });

    Iterable<Map<String, dynamic>> submits() =>
        network.joinRequests.where((r) => r['type'] == JoinTask.submit);

    test('offers the way once an identity holds the credential', () async {
      await controller().onScanned(fakeVtcDid);

      final way = state().ways.single;
      expect(way.canApply, isTrue);
      expect(way.heldBy, {persona.did});
      expect(way.credentialType, 'MembershipCredential');
    });

    test('says the credential is missing when no identity holds it', () async {
      network.vta.answerTo[VtaTask.credentialsQuery] = (_) => {
        'credentials': <Object>[],
      };

      await controller().onScanned(fakeVtcDid);
      await controller().join();

      expect(
        state().ways.single.unsupported,
        VtcJoinUnsupported.credentialMissing,
      );
      expect(state().step, VtcJoinStep.review);
      expect(submits(), isEmpty);
    });

    test('joins only as an identity holding it', () async {
      await controller().onScanned(fakeVtcDid);
      await controller().join();
      expect(state().step, VtcJoinStep.chooseIdentity);
      expect(state().credentialHolders, {persona.did});

      await controller().useIdentity(null);
      await controller().useIdentity(other);

      expect(state().step, VtcJoinStep.chooseIdentity);
      expect(submits(), isEmpty);
    });

    test('presents the credential the member approved, then applies', () async {
      await controller().onScanned(fakeVtcDid);
      await controller().join();
      await controller().useIdentity(persona.did);

      expect(state().step, VtcJoinStep.approveCredential);
      final shared = state().sharedCredential!;
      expect(shared.types, membership);
      expect(shared.issuerDid, 'did:web:chess.example');
      expect(shared.claims.single.type, 'memberOf');
      expect(shared.claims.single.value, 'Chess club');
      expect(submits(), isEmpty, reason: 'nothing sent before approval');

      await controller().approveCredential();

      // The VTA keeps consent receipts for did:key subjects only, so the
      // presentation is made here, of the credential as the VTA holds it.
      expect(
        network.vta.received.where(
          (r) => r['type'] == VtaTask.credentialsPresent,
        ),
        isEmpty,
      );
      final payload = submits().single['payload'] as Map;
      expect(payload['criterion'], 'zMembers');
      final vp = payload['vp'] as Map;
      expect(vp['holder'], persona.did);
      expect(
        ((vp['verifiableCredential'] as List).single as Map)['id'],
        'urn:uuid:card',
      );
      expect(state().step, VtcJoinStep.joined);
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
      expect(state().chosenWayId, 'open');

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

    test('shows the signed application while it waits', () async {
      network.joinVerdict = {'effect': 'refer'};
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      expect(state().submitExchange?.receipt.type, JoinTask.submit);
      expect(state().submitExchange?.receipt.signer, persona.did);
      expect(state().submitExchange?.receipt.answeredBy, fakeVtcDid);
      expect(state().requestId, 'request-1');
      expect(state().lastCheckedAt, isNull);

      // Reopened later, the screen shows the same application.
      container.dispose();
      useService();
      await controller().onScanned(fakeVtcDid);
      expect(state().step, VtcJoinStep.pending);
      expect(state().submitExchange?.receipt.type, JoinTask.submit);
    });

    test('says when the administrators put the application off', () async {
      network.joinVerdict = {'effect': 'refer'};
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      network.joinStatus = 'deferred';
      await controller().checkAgain();
      expect(state().step, VtcJoinStep.pending);
      expect(state().deferred, isTrue);
      expect(state().lastCheckedAt, isNotNull);
      expect(state().lastCheckExchange?.receipt.type, JoinTask.status);
      expect(state().lastCheckExchange?.receipt.answeredBy, fakeVtcDid);

      network.joinStatus = 'pending';
      await controller().checkAgain();
      expect(state().deferred, isFalse);
    });

    test('checks a waiting application without a spinner', () async {
      network.joinVerdict = {'effect': 'refer'};
      await controller().onScanned(fakeVtcDid);
      await controller().join();
      final steps = <VtcJoinStep>[];
      container.listen(
        vtcJoinControllerProvider,
        (_, next) => steps.add(next.step),
      );

      final checking = <bool>[];
      container.listen(
        vtcJoinControllerProvider.select((s) => s.checking),
        (_, next) => checking.add(next),
      );

      await controller().checkAgain();

      expect(steps, isNot(contains(VtcJoinStep.working)));
      expect(state().step, VtcJoinStep.pending);
      // Marked as under way while it runs, for the screen to show.
      expect(checking, [true, false]);
    });

    test('keeps waiting when a check fails', () async {
      network.joinVerdict = {'effect': 'refer'};
      await controller().onScanned(fakeVtcDid);
      await controller().join();

      // An answer the app cannot read, as from a community in trouble.
      network.joinStatus = 'lost';
      await controller().checkAgain();
      expect(state().step, VtcJoinStep.pending);
      expect(state().lastCheckedAt, isNull);

      network.joinStatus = 'approved';
      await controller().checkAgain();
      expect(state().step, VtcJoinStep.joined);
    });

    test('runs one check at a time', () async {
      network.joinVerdict = {'effect': 'refer'};
      await controller().onScanned(fakeVtcDid);
      await controller().join();
      final sent = network.joinRequests.length;

      await Future.wait([controller().checkAgain(), controller().checkAgain()]);

      expect(
        network.joinRequests
            .skip(sent)
            .where((r) => r['type'] == JoinTask.status),
        hasLength(1),
      );
    });

    test('withdraws a waiting application and applies again', () async {
      network.joinVerdict = {'effect': 'refer'};
      await controller().onScanned(fakeVtcDid);
      await controller().join();
      await controller().checkAgain();

      await controller().withdraw();

      expect(state().step, VtcJoinStep.withdrawn);
      expect(state().submitExchange, isNull);
      expect(state().requestId, isNull);
      expect(state().lastCheckExchange, isNull);
      expect(network.joinRequests.last['type'], JoinTask.withdraw);

      controller().applyAgain();
      expect(state().step, VtcJoinStep.review);

      await controller().join();
      expect(state().step, VtcJoinStep.pending);
      expect(state().submitExchange?.receipt.type, JoinTask.submit);
      expect(
        network.joinRequests.where((r) => r['type'] == JoinTask.submit),
        hasLength(2),
      );
    });

    test('shows the decision when withdrawing too late', () async {
      network.joinVerdict = {'effect': 'refer'};
      await controller().onScanned(fakeVtcDid);
      await controller().join();
      network
        ..withdrawRefusal = 'vtc/join-requests/withdraw:alreadyDecided'
        ..joinStatus = 'rejected'
        ..joinRejectionReason = 'Members only';

      await controller().withdraw();

      expect(state().step, VtcJoinStep.denied);
      expect(state().denialReason, 'Members only');
    });

    group('membership card', () {
      void vtaHoldsCard() => network.vta
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

      /// Lets the read the joined step starts finish.
      Future<void> readDone() async {
        for (var i = 0; i < 50 && state().membershipCard == null; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      }

      test('is shown once the administrators approved', () async {
        network.joinVerdict = {'effect': 'refer'};
        await controller().onScanned(fakeVtcDid);
        await controller().join();
        vtaHoldsCard();

        network.joinStatus = 'approved';
        await controller().checkAgain();
        expect(state().step, VtcJoinStep.joined);
        await readDone();

        expect(state().membershipCard?.issuer, fakeVtcDid);
        expect(state().membershipCard?.memberDid, persona.did);
      });

      test('is read again until the VTA holds it', () async {
        network.joinVerdict = {'effect': 'refer'};
        await controller().onScanned(fakeVtcDid);
        await controller().join();
        network.joinStatus = 'approved';
        await controller().checkAgain();
        await readDone();
        expect(state().membershipCard, isNull);

        vtaHoldsCard();
        await controller().readMembershipCard();

        expect(state().membershipCard?.memberDid, persona.did);
      });

      test('is shown for an admission at once', () async {
        vtaHoldsCard();
        await controller().onScanned(fakeVtcDid);
        await controller().join();
        expect(state().step, VtcJoinStep.joined);
        await readDone();

        expect(state().membershipCard?.issuer, fakeVtcDid);
      });

      group('from the identity inbox', () {
        late FakePersona mailPersona;

        Map<String, dynamic> card() => {
          'id': 'urn:uuid:vmc',
          'type': ['VerifiableCredential', 'MembershipCredential'],
          'issuer': fakeVtcDid,
          'credentialSubject': {'id': mailPersona.did},
        };

        /// The VTA holds the card, as it does once it kept it.
        void vtaKeptCard() => network.vta
          ..answers[VtaTask.credentialsQuery] = {
            'credentials': [
              {'id': 'card-1'},
            ],
          }
          ..answers[VtaTask.credentialsGet] = {'credential': card()};

        int loans() => network.vta.received
            .where((request) => request['type'] == VtaTask.exportSecret)
            .length;

        Future<void> approve() async {
          network.joinVerdict = {'effect': 'refer'};
          await controller().onScanned(fakeVtcDid);
          await controller().join();
          network.joinStatus = 'approved';
        }

        setUp(() {
          mailPersona = FakePersona(mediatorDid: network.mediatorDid);
          network.vta
            ..persona = mailPersona
            ..otherDocuments[mailPersona.did] = mailPersona.document
            ..answers[VtaTask.didsCreate] = {
              'did': mailPersona.did,
              'contextId': 'vta',
              'signingKeyId': mailPersona.signingKeyId,
            }
            ..answers[VtaTask.signDocument] = {
              'document': {
                'issuer': mailPersona.did,
                'proof': {'proofPurpose': 'assertionMethod'},
              },
            }
            ..answerTo[VtaTask.exportSecret] = (payload) =>
                mailPersona.exportAnswer(payload['keyId']);
        });

        test('is collected on approval, showing each step', () async {
          await approve();
          await network.deliver(mailPersona, card());

          await controller().checkAgain();

          expect(state().step, VtcJoinStep.joined);
          final delivery = state().cardDelivery;
          expect(delivery?.isDone, isTrue);
          expect(delivery?.issue?.issuer, fakeVtcDid);
          // The read the joined step started found no card yet.
          await readDone();
          vtaKeptCard();
          await controller().readMembershipCard();
          expect(state().membershipCard?.memberDid, mailPersona.did);
        });

        test('is waited for, then collected on a later check', () async {
          await approve();
          await controller().checkAgain();
          expect(
            state().cardDelivery?.status(VtcDeliveryStep.pickedUp),
            VtcDeliveryStatus.waiting,
          );

          await network.deliver(mailPersona, card());
          await controller().collectMembershipCard();

          expect(state().cardDelivery?.isDone, isTrue);
          expect(network.inboxDeleted, ['message-1']);
          // The keys were lent once for both checks.
          expect(loans(), 2);
        });

        test('forgets the lent keys when the screen closes', () async {
          await approve();
          await controller().checkAgain();
          expect(loans(), 2);

          container.dispose();
          await Future<void>.delayed(Duration.zero);
          useService();
          await service.checkApplication(fakeVtcDid);

          expect(loans(), 4);
        });
      });
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
      expect(communityOffers.lookedUp, isEmpty);
    });

    test('opens the community a join phrase leads to', () async {
      communityOffers.phrases['my-club'] = fakeVtcDid;

      await controller().onScanned(' my-club ');

      expect(communityOffers.lookedUp, ['my-club']);
      expect(state().step, VtcJoinStep.review);
      expect(state().communityDid, fakeVtcDid);
    });

    for (final (problem, failure) in [
      (CommunityPhraseProblem.notFound, VtcJoinFailure.phraseNotFound),
      (CommunityPhraseProblem.expired, VtcJoinFailure.phraseExpired),
      (CommunityPhraseProblem.notVouched, VtcJoinFailure.phraseNotVouched),
    ]) {
      test('says why a join phrase leads nowhere: ${problem.name}', () async {
        communityOffers.failure = CommunityPhraseException(problem);

        await controller().onScanned('my-club');

        expect(state().step, VtcJoinStep.failed);
        expect(state().failure, failure);
        expect(network.joinRequests, isEmpty);
      });
    }

    test('says when Meeting Place cannot be reached for a phrase', () async {
      communityOffers.failure = MeetingPlaceCoreSDKException(
        message: 'offline',
        code: 'transport',
        innerException: StateError('offline'),
      );

      await controller().onScanned('my-club');

      expect(state().failure, VtcJoinFailure.unreachable);
    });

    test('refuses a phrase that leads to a DID no community uses', () async {
      communityOffers.phrases['my-club'] = 'did:key:z6MkhaXgBZD';

      await controller().onScanned('my-club');

      expect(state().failure, VtcJoinFailure.invalidCode);
    });

    test('shows what the community publishes about itself', () async {
      network.joinManifest = {
        ...network.joinManifest,
        'branding': {
          'displayName': 'Football club',
          'logoUrl': 'https://club.example/logo.png',
        },
        'directoryDisclosure': {
          'fields': [
            {
              'key': 'name',
              'label': 'Name',
              'type': 'text',
              'source': 'member',
              'ceiling': 'members',
              'defaultVisibility': 'members',
              'searchable': true,
            },
          ],
          'newCard': {'listing': 'listed', 'search': 'byName'},
          'membershipIdentifiers': 'admins',
          'adminNotes': true,
          'externalCards': false,
          'statementDigest': 'zDigest',
        },
      };

      await controller().onScanned(fakeVtcDid);

      expect(state().logoUrl, Uri.parse('https://club.example/logo.png'));
      expect(state().description, 'Five-a-side on Sundays.');
      expect(state().website, Uri.parse('https://club.example/'));
      expect(state().contactEmail, 'hello@club.example');
      expect(state().directoryDisclosure?.fields.single.label, 'Name');
      expect(state().directoryDisclosure?.adminNotes, isTrue);
    });

    test('reviews a community that publishes no profile', () async {
      network.publicProfile = null;

      await controller().onScanned(fakeVtcDid);

      expect(state().step, VtcJoinStep.review);
      expect(state().description, isNull);
      expect(state().website, isNull);
    });

    test('starts over after a failure', () async {
      await controller().onScanned('https://example.com');

      controller().restart();
      await controller().onScanned(fakeVtcDid);

      expect(state().step, VtcJoinStep.review);
      expect(state().failure, isNull);
    });

    test('says when the VTA cannot publish a persona', () async {
      network.vta.answers[VtaTask.serversList] = {'servers': <Object>[]};
      await controller().onScanned(fakeVtcDid);

      await controller().join();

      expect(state().failure, VtcJoinFailure.noDidHosting);
    });

    test('leaves a joined community', () async {
      await service.join(await service.readCommunity(fakeVtcDid));
      await controller().onScanned(fakeVtcDid);

      await controller().leave();

      expect(state().step, VtcJoinStep.left);
      expect(network.memberRequests.last['type'], MemberTask.selfRemove);
      expect(await service.community(fakeVtcDid), isNull);
    });

    test('says when the member is the last administrator', () async {
      network.leaveRefusal = (409, 'conflict');
      await service.join(await service.readCommunity(fakeVtcDid));
      await controller().onScanned(fakeVtcDid);

      await controller().leave();

      expect(state().failure, VtcJoinFailure.lastAdministrator);
      expect((await service.community(fakeVtcDid))?.isMember, isTrue);
    });

    test('leaves nothing before the community is joined', () async {
      await controller().onScanned(fakeVtcDid);

      await controller().leave();

      expect(state().step, VtcJoinStep.review);
      expect(
        network.memberRequests.map((r) => r['type']),
        isNot(contains(MemberTask.selfRemove)),
      );
    });

    test('says when no VTA is linked', () async {
      await service.unlink();
      await controller().onScanned(fakeVtcDid);

      await controller().join();

      expect(state().failure, VtcJoinFailure.vtaMissing);
    });
  });
}

/// The member's identity [name], a persona of their VTA whose DID is [did].
Identity _vtaIdentity(String did, String name) =>
    FakeIdentities.primaryIdentity.copyWith(
      did: did,
      card: FakeIdentities.primaryIdentity.card.copyWith(
        did: did,
        displayName: name,
      ),
      vtaContextId: 'vta',
      vtaProfileId: '01PROFILE',
    );
