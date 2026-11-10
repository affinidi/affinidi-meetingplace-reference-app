import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_vetter_desk.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:ssi/ssi.dart' show ProofPurpose;

import 'fake_persona.dart';
import 'fake_vta.dart';
import 'fake_vtc_network.dart';

/// A member who joined [fakeVtcDid] as its vetter, with the VTA keeping
/// their vetter role card, and an applicant who comes to them to be vetted.
/// Call [setUp] before each test.
class FakeVetterDesk {
  final network = FakeVtcNetwork()
    ..joinManifest = {
      'communityDid': fakeVtcDid,
      'criteria': [
        {'id': 'open', 'admission': 'automatic', 'requirementsDigest': 'zOpen'},
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
  late final FakePersona vetter = FakePersona(mediatorDid: network.mediatorDid);
  late final FakePersona applicant = FakePersona(
    mediatorDid: network.mediatorDid,
  );

  /// The vetter's app, linked to their VTA and a member of the community.
  late CheckedVtcService service;

  /// Links the vetter's app to their VTA and joins the community.
  Future<void> setUp() async {
    final roleCard = await network.vetterRoleCard(vetter.did);
    network.vta
      ..persona = vetter
      ..otherDocuments[vetter.did] = vetter.document
      ..otherDocuments[applicant.did] = applicant.document
      ..answers[VtaTask.vaultUpsert] = {
        'entry': {'id': 'entry-1'},
      }
      ..answers[VtaTask.credentialsGet] = {'credential': roleCard};
    network.vta.answerTo[VtaTask.exportSecret] = (payload) =>
        vetter.exportAnswer(payload['keyId']);
    network.vta.answerTo[VtaTask.credentialsQuery] = (payload) => {
      'credentials': [
        if (payload['type'] == 'AuthorityCredential')
          {
            'id': 'role-1',
            'types': ['VerifiableCredential', 'AuthorityCredential'],
          },
      ],
    };
    service = CheckedVtcService(
      sdk: network.sdk(),
      repository: SecureStorageVtcRepository(),
      userVerificationKey: UserVerificationKey(
        FakeUserVerificationKeyStorage(),
      ),
      platform: 'ios',
    );
    await service.startLink(network.vta.did);
    await service.checkGrant();
    await service.join(
      await service.readCommunity(fakeVtcDid),
      persona: VtaPersona(
        did: vetter.did,
        contextId: 'mpx-bob',
        signingKeyId: vetter.signingKeyId,
      ),
    );
  }

  /// The applicant sends the vetter a [type] document.
  Future<TrustTaskDocument> applicantSends(
    String type,
    Map<String, dynamic> payload, {
    String? threadId,
    String? parentThreadId,
  }) => network.memberSends(
    applicant,
    TrustTaskDocument.create(
      type: type,
      issuer: applicant.did,
      recipient: vetter.did,
      threadId: threadId,
      parentThreadId: parentThreadId,
      payload: payload,
    ),
  );

  /// The applicant asks the vetter to vet them, with [ticket].
  Future<TrustTaskDocument> requestWith(VettingTicket ticket) =>
      applicantSends(VettingTask.request, {
        'community': fakeVtcDid,
        'joinDid': applicant.did,
        'ticket': ticket.toJson(),
      });

  /// The applicant sends their card, stating their legal name, in
  /// [session], the vetter's session document.
  Future<TrustTaskDocument> sendCard(TrustTaskDocument session) async {
    final card = await EddsaJcs2022.sign(
      unsignedVettingCard(
        id: 'urn:uuid:card',
        publisher: applicant.did,
        audience: vetter.did,
        community: fakeVtcDid,
        challenge: session.payload['challenge'] as String,
        domain: fakeVtcDid,
        issuedAt: DateTime.now().toUtc(),
        validity: const Duration(minutes: 10),
        claims: const [
          VettingCardClaim(type: 'name.legal', value: 'Ada Lovelace'),
        ],
        identityTypes: const ['name.legal'],
        salt: newCommitmentSalt(),
      ),
      signer: applicant,
      purpose: ProofPurpose.assertionMethod,
    );
    return applicantSends(
      VettingTask.sessionResponse,
      {'card': card},
      threadId: session.id,
      parentThreadId: session.parentThreadId,
    );
  }

  /// What the vetter sent the applicant, oldest first.
  Future<List<TrustTaskDocument>> sentToApplicant() =>
      network.sentTo(applicant);
}

/// A [VtcService] that counts the vetter card checks that answered, so a
/// test can wait for the check a screen started rather than for a desk
/// that may never show.
class CheckedVtcService extends VtcService {
  CheckedVtcService({
    required super.sdk,
    required super.repository,
    required super.userVerificationKey,
    super.platform,
  });

  /// How many [canVet] checks answered, or failed.
  int vetterChecks = 0;

  @override
  Future<bool> canVet(String communityDid) =>
      super.canVet(communityDid).whenComplete(() => vetterChecks++);

  /// How many [checkVetterDesk] checks started.
  int deskChecks = 0;

  @override
  Future<VtcVetterDesk?> checkVetterDesk(
    String communityDid, {
    List<String>? requiredClaims,
    void Function(VtcRequestStep step)? onRequestStep,
  }) {
    deskChecks++;
    return super.checkVetterDesk(
      communityDid,
      requiredClaims: requiredClaims,
      onRequestStep: onRequestStep,
    );
  }
}
