import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/linked_vta.dart';
import '../../../domain/models/vtc/mock_credential_template.dart';
import '../../../domain/models/vtc/vtc_card_delivery.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/models/vtc/vtc_identity_check.dart';
import '../../../domain/models/vtc/vtc_left_membership.dart';
import '../../../domain/models/vtc/vtc_membership_card.dart';
import '../../../domain/models/vtc/vtc_membership_entry.dart';
import '../../../domain/repositories/vtc_repository.dart';
import '../../../infrastructure/providers/vtc_sdk_provider.dart';
import '../../../infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import '../../../infrastructure/vtc/mock_credential_issuer.dart';
import '../../../infrastructure/vtc/user_verification_key.dart';

/// Thrown when the text entered as a VTA is not a DID.
class InvalidVtaDidException implements Exception {
  /// Creates an [InvalidVtaDidException].
  const InvalidVtaDidException();
}

/// Thrown when a VTA is to be linked while one already is.
class VtaAlreadyLinkedException implements Exception {
  /// Creates a [VtaAlreadyLinkedException].
  const VtaAlreadyLinkedException();
}

/// Thrown when scanned text is not a community's DID.
class InvalidCommunityCodeException implements Exception {
  /// Creates an [InvalidCommunityCodeException].
  const InvalidCommunityCodeException();
}

/// Name the phone registers with on the member's VTA.
const _deviceName = 'Meeting Place';

/// Thrown when a VTC feature needs a linked, granted VTA and there is none.
class VtaNotLinkedException implements Exception {
  /// Creates a [VtaNotLinkedException].
  const VtaNotLinkedException();
}

/// Links Meeting Place to the member's VTA, joins Verifiable Trust
/// Communities as personas the VTA holds, and signs the member in to their
/// communities' portals.
///
/// The link is manual: the phone mints a manager key and shows its DID; the
/// VTA's administrator grants it; the phone then checks for the grant. The
/// biometric approval key is enrolled only when a sign-in first needs it.
class VtcService {
  /// Creates a [VtcService].
  VtcService({
    required this._sdk,
    required this._repository,
    required this._userVerificationKey,
    MockCredentialIssuer? mockCredentialIssuer,
    String? platform,
  }) : _platform = platform ?? Platform.operatingSystem,
       _mockIssuer = mockCredentialIssuer ?? MockCredentialIssuer();

  final MeetingPlaceVtcSDK _sdk;
  final VtcRepository _repository;
  final UserVerificationKey _userVerificationKey;
  final MockCredentialIssuer _mockIssuer;
  final String _platform;
  VtaClient? _client;
  final _membershipsChanged = StreamController<void>.broadcast();

  /// Fires each time the member's membership cards change: a card a
  /// community issued is kept on their VTA, or a membership is left.
  Stream<void> get membershipsChanged => _membershipsChanged.stream;

  /// The identity keys lent and inboxes open, by community, while a
  /// membership card is collected, so a check every few seconds borrows the
  /// keys once: the VTA audits each loan.
  final Map<String, _CardCollection> _collections = {};

  /// Connection DIDComm keys the VTA lent, by key id, for as long as the
  /// link lasts.
  final Map<String, Future<Uint8List>> _lentConnectionKeys = {};

  /// How long lent keys are held without a check before they are forgotten.
  static const _collectionIdle = Duration(minutes: 5);

  /// The linked VTA, or null when the phone is not linked.
  Future<LinkedVta?> linkedVta() => _repository.getLinkedVta();

  /// Starts linking the VTA [vtaDid] and returns the manager DID its
  /// administrator must grant.
  ///
  /// The link is stored only once [vtaDid] resolves to a VTA that answers
  /// over HTTPS, at the endpoint its DID document names.
  ///
  /// Throws [InvalidVtaDidException] when [vtaDid] is not a DID,
  /// [VtaAlreadyLinkedException] when a VTA is linked or being linked, and
  /// [MeetingPlaceVtcSDKException] when the DID does not resolve or the VTA
  /// cannot be reached.
  Future<String> startLink(String vtaDid) async {
    final did = vtaDid.trim();
    if (!_isDid(did)) throw const InvalidVtaDidException();
    if (await _repository.getLinkedVta() != null) {
      throw const VtaAlreadyLinkedException();
    }

    final manager = _sdk.newManagerKey();
    final client = _sdk.vtaClient(vtaDid: did, manager: manager);
    await client.checkReachable();

    await _repository.saveLinkedVta(
      LinkedVta(vtaDid: did, managerSeed: manager.seed, isGranted: false),
    );
    _client = client;
    return manager.did;
  }

  /// The manager DID of the pending or completed link, or null.
  Future<String?> managerDid() async {
    final linkedVta = await _repository.getLinkedVta();
    if (linkedVta == null) return null;
    return Ed25519DidKeySigner.fromSeed(linkedVta.managerSeed).did;
  }

  /// Asks the VTA what it grants the manager key, and marks the link active
  /// once it grants all the phone needs.
  ///
  /// Returns null when no link is pending or the key is not on the VTA's
  /// access list yet. Throws [MeetingPlaceVtcSDKException] when the VTA
  /// cannot be reached or its answer does not verify.
  Future<VtaAccess?> checkGrant() async {
    final linkedVta = await _repository.getLinkedVta();
    if (linkedVta == null) return null;

    final access = await VtaLink.access(_vtaClient(linkedVta));
    if (access != null && access.isGranted && !linkedVta.isGranted) {
      await _repository.saveLinkedVta(linkedVta.granted());
    }
    return access;
  }

  /// Forgets the VTA link, the manager key, the communities and the
  /// approval key, after ending the manager key's sessions on the VTA.
  ///
  /// The VTA keeps the key on its access list: only its administrator can
  /// remove it.
  Future<void> unlink() async {
    final linkedVta = await _repository.getLinkedVta();
    if (linkedVta != null) await _vtaClient(linkedVta).signOut();
    _client = null;
    await _forgetConnectionKeys();
    await _repository.clear();
    await _userVerificationKey.reset();
  }

  /// Creates an identity on the member's VTA: a persona in a context of its
  /// own, wearing a profile showing [profile]. All or nothing.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked and granted, and
  /// [MeetingPlaceVtcSDKException] when the VTA refuses or cannot be reached.
  Future<VtaIdentity> createIdentity(VtaProfile profile) async =>
      (await _grantedVta()).createIdentity(profile);

  /// Reads the profile [profileId] that the identity in [contextId] wears.
  /// Throws as [createIdentity] does.
  Future<VtaProfile> identityProfile({
    required String contextId,
    required String profileId,
  }) async =>
      (await _grantedVta()).profile(contextId: contextId, profileId: profileId);

  /// Reads the profile [profileId] that the identity in [contextId] wears,
  /// as the VTA keeps it. Throws as [createIdentity] does.
  Future<Map<String, dynamic>> identityProfileDocument({
    required String contextId,
    required String profileId,
  }) async => (await _grantedVta()).profileDocument(
    contextId: contextId,
    profileId: profileId,
  );

  /// Replaces the details of the profile [profileId] that the identity in
  /// [contextId] wears. Throws as [createIdentity] does.
  Future<void> updateIdentity({
    required String contextId,
    required String profileId,
    required VtaProfile profile,
  }) async => (await _grantedVta()).updateProfile(
    contextId: contextId,
    profileId: profileId,
    profile: profile,
  );

  /// Retires the identity's profile and deletes its persona DID and keys on
  /// the VTA. The DID cannot be used again. Throws as [createIdentity] does.
  Future<void> deleteIdentity({
    required String contextId,
    required String profileId,
  }) async => (await _grantedVta()).deleteIdentity(
    contextId: contextId,
    profileId: profileId,
  );

  /// Creates the keys of one connection DID on the member's VTA: one that
  /// signs its credentials, whose private key never leaves the VTA, and
  /// one for DIDComm, which the VTA lends through [lendConnectionKey].
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA refuses or cannot be
  /// reached.
  Future<({VtaConnectionKey signing, VtaConnectionKey agreement})>
  createConnectionKeys() async => (await _grantedVta()).createConnectionKeys();

  /// Borrows the connection DIDComm key [keyId] from the member's VTA,
  /// once for as long as the link lasts: every message needs it, and the
  /// VTA audits each loan. Held in memory only, and forgotten on [unlink].
  ///
  /// Returns a copy the caller may zero-fill. Throws as
  /// [createConnectionKeys] does.
  Future<Uint8List> lendConnectionKey(String keyId) async {
    final lending = _lentConnectionKeys[keyId] ??= _grantedVta().then(
      (vta) => vta.lendConnectionKey(keyId),
    );
    try {
      return Uint8List.fromList(await lending);
    } on Object {
      // Ask again next time rather than keep the failure.
      if (identical(_lentConnectionKeys[keyId], lending)) {
        _lentConnectionKeys.remove(keyId)?.ignore();
      }
      rethrow;
    }
  }

  /// Has the member's VTA sign [document] with the connection key [keyId],
  /// as the DID the document names as its issuer. Throws as
  /// [createConnectionKeys] does.
  Future<Map<String, dynamic>> signConnectionDocument(
    Map<String, dynamic> document, {
    required String keyId,
  }) async => (await _grantedVta()).signDocument(
    keyId: keyId,
    document: document,
    purpose: 'assertionMethod',
  );

  /// Reads scanned [text] as a trigger link, offline.
  TriggerLinkResult readLink(String text) => _sdk.readTriggerLink(text);

  /// A sign-in client that asks this phone's records whether it is a member
  /// before any network call.
  OobSignInClient signInClient() => _sdk.signInClient(
    isKnownCommunity: (vtcDid) async =>
        (await _repository.findCommunity(vtcDid))?.isMember ?? false,
  );

  /// The member's recorded membership of [communityDid], or null. An
  /// application is no membership.
  Future<CommunityMembership?> recordedMembership(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null || !community.isMember) return null;
    return CommunityMembership(
      communityDid: community.communityDid,
      persona: _persona(community),
      name: community.name,
    );
  }

  /// The member's record of [communityDid]: a membership, an application,
  /// or null.
  Future<VtcCommunity?> community(String communityDid) =>
      _repository.findCommunity(communityDid);

  /// Reads what the community whose DID is [scanned], as its QR code shows
  /// it, asks of applicants.
  ///
  /// Throws [InvalidCommunityCodeException] when [scanned] is not a DID, and
  /// [MeetingPlaceVtcSDKException] when the community cannot be reached.
  Future<JoinManifest> readCommunity(String scanned) async {
    final did = scanned.trim();
    if (!_isCommunityDid(did)) throw const InvalidCommunityCodeException();
    return _sdk.joinClient().readManifest(did);
  }

  /// Reads what the community [communityDid] publishes about itself. It is
  /// unsigned, so it is shown and never decides anything.
  ///
  /// Throws [MeetingPlaceVtcSDKException] when the community publishes none
  /// or cannot be reached.
  Future<CommunityProfile> readProfile(String communityDid) =>
      _sdk.joinClient().readProfile(communityDid);

  /// Applies to join [manifest]'s community as a persona of the member's
  /// VTA, and records the outcome.
  ///
  /// The application is made under [criterion], or else the first way in
  /// this app supports, with [presentation] when the criterion asks for a
  /// credential (see [joinPresentation]).
  ///
  /// The first application to a community is made as [persona], one of
  /// [vtaPersonas], or else as a new persona the VTA creates; a later one
  /// applies as the same persona. Once admitted, the issued cards are kept
  /// on the VTA, where other apps of the member find them.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA or the community refuses or
  /// cannot be reached.
  ///
  /// Once admitted, the membership is confirmed back to the community and,
  /// unless [listInDirectory], the member's directory card is withdrawn.
  /// Both are retried by [checkApplication] until they succeed.
  Future<JoinVerdict> join(
    JoinManifest manifest, {
    VtaPersona? persona,
    JoinCriterion? criterion,
    Map<String, dynamic>? presentation,
    List<JoinAttribute> attributes = const [],
    bool listInDirectory = false,
  }) async {
    final vta = await _grantedVta();
    await joiningIdentity(
      manifest,
      persona: persona,
      listInDirectory: listInDirectory,
    );
    final community = (await _repository.findCommunity(manifest.communityDid))!;

    final verdict = await _sdk.joinClient().apply(
      manifest,
      agent: vta,
      persona: await _personaSigner(vta, community),
      criterion: criterion,
      presentation: presentation,
      attributes: attributes,
    );
    switch (verdict) {
      case JoinAdmitted(:final credentials, :final membershipCard):
        final member = community.withApplication(isMember: true);
        await _repository.saveCommunity(member);
        await _keepCards(vta, credentials, community.contextId);
        _membershipsChanged.add(null);
        await _settle(vta, member, membershipCard, verdict.requestId);
      case JoinPending(:final requestId, :final exchange):
        await _repository.saveCommunity(
          community.withApplication(
            isMember: false,
            requestId: requestId,
            exchange: exchange,
          ),
        );
      case JoinDenied(:final reason):
        await _repository.saveCommunity(community.rejected(reason));
      case JoinNeedsMore():
        await _repository.saveCommunity(
          community.withApplication(isMember: false),
        );
    }
    return verdict;
  }

  /// The identity that applies to [manifest]'s community: the one recorded
  /// for it, else [persona], else a new persona the VTA creates. Recorded
  /// before anything is sent, so a retry applies as the same identity.
  ///
  /// Throws as [join] does.
  Future<VtaPersona> joiningIdentity(
    JoinManifest manifest, {
    VtaPersona? persona,
    bool listInDirectory = false,
  }) async {
    final recorded = await _repository.findCommunity(manifest.communityDid);
    if (recorded != null) {
      await _repository.saveCommunity(
        recorded.withDirectoryChoice(listInDirectory: listInDirectory),
      );
      return _persona(recorded);
    }

    final vta = await _grantedVta();
    persona ??= await vta.createPersona(
      label: manifest.name ?? manifest.communityDid,
    );
    await _repository.saveCommunity(
      VtcCommunity(
        communityDid: manifest.communityDid,
        personaDid: persona.did,
        contextId: persona.contextId,
        name: manifest.name,
        signingKeyId: persona.signingKeyId,
        isMember: false,
        listInDirectory: listInDirectory,
      ),
    );
    return persona;
  }

  /// Completes [member]'s admission on the community's side: confirms the
  /// membership with [membershipCard], the card the community issued, and,
  /// unless the member opted in, withdraws their directory card. Records
  /// whether both succeeded; neither failure undoes the membership.
  ///
  /// Returns whether the community took the confirmation.
  Future<bool> _settle(
    VtaClient vta,
    VtcCommunity member,
    Map<String, dynamic>? membershipCard,
    String? requestId,
  ) async {
    var confirmed = membershipCard != null;
    var settled = confirmed;
    final signer = await _personaSigner(vta, member);
    final client = _sdk.joinClient();
    if (membershipCard != null) {
      try {
        await client.confirmMembership(
          member.communityDid,
          agent: vta,
          persona: _persona(member),
          signer: signer,
          communityCard: membershipCard,
          requestId: requestId,
        );
      } on MeetingPlaceVtcSDKException {
        confirmed = settled = false;
      }
    }
    if (!member.listInDirectory) {
      try {
        await client.hideDirectoryCard(
          member.communityDid,
          agent: vta,
          persona: signer,
        );
      } on MeetingPlaceVtcSDKException {
        settled = false;
      }
    }
    await _repository.saveCommunity(member.settled(settled));
    return confirmed;
  }

  /// Previews what the VTA would disclose about [persona] for the profile
  /// details [manifest]'s community asks for. Nothing leaves the VTA.
  ///
  /// Throws [MeetingPlaceVtcSDKException] refused with `notBound` when the
  /// persona has no profile on the VTA.
  Future<DisclosurePreview> previewDetails(
    JoinManifest manifest,
    VtaPersona persona,
  ) async {
    final vta = await _grantedVta();
    return vta.previewDisclosure(
      persona: persona,
      verifierDid: manifest.communityDid,
      requestedClaims: [
        for (final detail in manifest.requestedAttributes) detail.type,
      ],
    );
  }

  /// For each way into [manifest]'s community met by presenting one held
  /// credential, the credential each of [personaDids] holds for it: by
  /// criterion id, then by persona DID. An identity holding none is left
  /// out.
  ///
  /// Throws as [join] does.
  Future<Map<String, Map<String, HeldCredential>>> credentialHolders(
    JoinManifest manifest,
    List<String> personaDids,
  ) async {
    final criteria = manifest.criteria.where(isMetByOneCredential).toList();
    if (criteria.isEmpty || personaDids.isEmpty) return const {};
    final vta = await _grantedVta();
    final holders = <String, Map<String, HeldCredential>>{};
    for (final criterion in criteria) {
      for (final did in personaDids) {
        final matches = await vta.matchCredentials(
          criterion.credentials!,
          subjectDid: did,
          communityDid: manifest.communityDid,
        );
        if (matches?.single case final held?) {
          (holders[criterion.id] ??= {})[did] = held;
        }
      }
    }
    return holders;
  }

  /// The held credential [id], as the VTA stores it, to show the member
  /// what presenting it discloses. Nothing leaves the VTA.
  Future<Map<String, dynamic>?> heldCredential(String id) async =>
      (await _grantedVta()).credential(id);

  /// Issues the test credential [template] to the identity [personaDid] and
  /// keeps it on the VTA in that identity's context [contextId], where a way
  /// into a community asking for it finds it. The VTA checks the issuer's
  /// signature before it keeps it.
  ///
  /// Returns whether the VTA keeps it as valid. Throws as [join] does.
  Future<bool> importMockCredential(
    MockCredentialTemplate template, {
    required String personaDid,
    required String contextId,
  }) async {
    final vta = await _grantedVta();
    final credential = await _mockIssuer.issue(
      template,
      subjectDid: personaDid,
    );
    return vta.keepCredential(credential, contextId: contextId);
  }

  /// Which of [personaDids] hold each test credential, by template id: the
  /// valid ones this phone issued and the VTA keeps.
  ///
  /// Throws as [join] does.
  Future<Map<String, Set<String>>> mockCredentialHolders(
    List<String> personaDids,
  ) async {
    final vta = await _grantedVta();
    final issuer = await _mockIssuer.did();
    final holders = <String, Set<String>>{};
    for (final did in personaDids) {
      final held = await vta.findCredentials(
        issuerDid: issuer,
        subjectDid: did,
      );
      for (final template in mockCredentialTemplates) {
        if (held.any(
          (credential) => credential.types.contains(template.type),
        )) {
          (holders[template.id] ??= {}).add(did);
        }
      }
    }
    return holders;
  }

  /// Discloses the preview [previewId] the member approved, through the
  /// VTA, which records the disclosure.
  Future<void> shareDetails(VtaPersona persona, String previewId) async {
    final vta = await _grantedVta();
    await vta.presentDisclosure(persona: persona, previewId: previewId);
  }

  /// Asks where the open application to [communityDid] stands, and records
  /// the community's decision once it has made one: an approval as a
  /// membership, completed as [join] completes one, a rejection with the
  /// community's reason. Also completes an admission still to settle.
  ///
  /// A card the community delivered to the identity's inbox, rather than to
  /// the VTA, is collected from there with keys the VTA lends, and each
  /// step of that is reported to [onCardDelivery]. The keys stay lent until
  /// [endCardCollection], the card is kept, or no check came for a while.
  ///
  /// Returns null when no application is open. Throws as [join] does.
  Future<JoinStatus?> checkApplication(
    String communityDid, {
    void Function(VtcCardDelivery delivery)? onCardDelivery,
  }) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null) return null;
    if (community.isMember && !community.isSettled) {
      await _settleFromVta(
        await _grantedVta(),
        community,
        requestId: null,
        onCardDelivery: onCardDelivery,
      );
      return null;
    }
    final requestId = community.joinRequestId;
    if (!community.isApplying || requestId == null) return null;

    final vta = await _grantedVta();
    final status = await _sdk.joinClient().status(
      communityDid,
      requestId: requestId,
      agent: vta,
      persona: await _personaSigner(vta, community),
    );
    switch (status.status) {
      case JoinRequestStatus.approved:
        final member = community.withApplication(isMember: true);
        await _repository.saveCommunity(member);
        await _settleFromVta(
          vta,
          member,
          requestId: requestId,
          onCardDelivery: onCardDelivery,
        );
      case JoinRequestStatus.rejected || JoinRequestStatus.withdrawn:
        await _repository.saveCommunity(community.rejected(status.reason));
      case JoinRequestStatus.pending || JoinRequestStatus.deferred:
        break;
    }
    return status;
  }

  /// Checks every open application and completes every admission still to
  /// settle, e.g. when the app comes to the foreground: a community decides
  /// on its own time. A community that cannot be reached is left for the
  /// next check. Does nothing while no VTA is linked.
  Future<void> checkApplications() async {
    final linkedVta = await _repository.getLinkedVta();
    if (linkedVta == null || !linkedVta.isGranted) return;
    for (final community in await _repository.communities()) {
      if (!community.isApplying &&
          (!community.isMember || community.isSettled)) {
        continue;
      }
      try {
        await checkApplication(community.communityDid);
      } on MeetingPlaceVtcSDKException {
        continue;
      } finally {
        await endCardCollection(community.communityDid);
      }
    }
  }

  /// Completes [member]'s admission with the membership card the community
  /// delivered: held by their VTA, or collected from the identity's inbox
  /// and kept on the VTA, each step reported to [onCardDelivery]. When
  /// neither holds it yet, asks the community to deliver it again and
  /// leaves the admission to settle at the next check.
  Future<void> _settleFromVta(
    VtaClient vta,
    VtcCommunity member, {
    required String? requestId,
    void Function(VtcCardDelivery delivery)? onCardDelivery,
  }) async {
    final report = _DeliveryReport(member.personaDid, onCardDelivery);
    final card =
        await _sdk
            .communityImport(vta)
            .membershipCard(
              member.communityDid,
              personaDid: member.personaDid,
            ) ??
        await _collectCards(vta, member, report);
    if (card == null) {
      if (requestId != null) {
        await _sdk.joinClient().status(
          member.communityDid,
          requestId: requestId,
          agent: vta,
          persona: await _personaSigner(vta, member),
          resendCredentials: true,
        );
      }
      await _repository.saveCommunity(member.settled(false));
      return;
    }
    if (report.isCollecting) {
      // Collected from the inbox just now: a card the VTA did not hold.
      _membershipsChanged.add(null);
      report.step(VtcDeliveryStep.confirmed, VtcDeliveryStatus.working);
    }
    final confirmed = await _settle(vta, member, card, requestId);
    if (report.isCollecting) {
      report.step(
        VtcDeliveryStep.confirmed,
        confirmed ? VtcDeliveryStatus.done : VtcDeliveryStatus.failed,
      );
      await endCardCollection(member.communityDid);
    }
  }

  /// Collects the cards [member]'s community delivered to the identity's
  /// inbox: borrows the identity's keys from [vta], signs in to the inbox,
  /// keeps each card the community issued to the identity on the VTA, and
  /// only then removes it from the inbox. Returns the membership card, or
  /// null when there is none yet or a step failed; [report] says which.
  Future<Map<String, dynamic>?> _collectCards(
    VtaClient vta,
    VtcCommunity member,
    _DeliveryReport report,
  ) async {
    report.step(VtcDeliveryStep.keysLent, VtcDeliveryStatus.working);
    final _CardCollection collection;
    try {
      collection = await _collection(vta, member);
    } on MeetingPlaceVtcSDKException {
      report.step(VtcDeliveryStep.keysLent, VtcDeliveryStatus.failed);
      return null;
    }
    report
      ..step(
        VtcDeliveryStep.keysLent,
        VtcDeliveryStatus.done,
        signingKeyId: collection.keys.authentication.first,
        keyAgreementKeyId: collection.keys.keyAgreement.first,
      )
      ..step(VtcDeliveryStep.signedIn, VtcDeliveryStatus.working);

    final InboxPickup pickup;
    try {
      await collection.inbox.open();
      pickup = await collection.inbox.issuedCredentials(
        issuerDid: member.communityDid,
      );
    } on MeetingPlaceVtcSDKException {
      report.step(VtcDeliveryStep.signedIn, VtcDeliveryStatus.failed);
      return null;
    }
    report.step(
      VtcDeliveryStep.signedIn,
      VtcDeliveryStatus.done,
      mediatorDid: collection.inbox.mediatorDid,
      waiting: pickup.waiting,
    );
    final membership = pickup.credentials
        .where(
          (issued) =>
              VtcMembershipCard.fromCredential(issued.credential) != null,
        )
        .firstOrNull;
    if (membership == null) {
      report.step(VtcDeliveryStep.pickedUp, VtcDeliveryStatus.waiting);
      return null;
    }
    report
      ..step(
        VtcDeliveryStep.pickedUp,
        VtcDeliveryStatus.done,
        issue: membership.document,
      )
      ..step(VtcDeliveryStep.kept, VtcDeliveryStatus.working);

    final bool isValid;
    try {
      isValid = await vta.keepCredential(
        membership.credential,
        contextId: member.contextId,
      );
    } on MeetingPlaceVtcSDKException {
      report.step(VtcDeliveryStep.kept, VtcDeliveryStatus.failed);
      return null;
    }
    final others = pickup.credentials.where((issued) => issued != membership);
    await _keepCards(vta, [
      for (final issued in others) issued.credential,
    ], member.contextId);
    try {
      await collection.inbox.remove([
        for (final issued in pickup.credentials) issued.messageId,
      ]);
    } on MeetingPlaceVtcSDKException {
      // Kept all the same; a copy left behind is kept again by its id.
    }
    report.step(
      VtcDeliveryStep.kept,
      VtcDeliveryStatus.done,
      isKeptAsValid: isValid,
    );
    return membership.credential;
  }

  /// The collection open for [member]'s community, or a new one with the
  /// identity's keys borrowed from [vta]. Held until [endCardCollection]
  /// or [_collectionIdle] without use.
  Future<_CardCollection> _collection(
    VtaClient vta,
    VtcCommunity member,
  ) async {
    final communityDid = member.communityDid;
    if (_collections[communityDid] case final open?) {
      return open..touch(() => endCardCollection(communityDid));
    }
    final keys = await vta.borrowPersonaKeys(_persona(member));
    return _collections[communityDid] = _CardCollection(
      keys,
      _sdk.personaInbox(keys),
      idle: _collectionIdle,
    )..touch(() => endCardCollection(communityDid));
  }

  /// Signs out of the identity's inbox for [communityDid] and forgets the
  /// keys the VTA lent for it, e.g. when the screen collecting the card
  /// closes. Does nothing when none are held.
  Future<void> endCardCollection(String communityDid) async {
    await _collections.remove(communityDid)?.end();
  }

  /// Withdraws the open application to [communityDid], so the member can
  /// apply again, as the same persona. Does nothing while none is open.
  ///
  /// An application the community no longer holds open as this persona's
  /// is forgotten all the same. One it already decided on is recorded as
  /// [checkApplication] records it, and the refusal passed on. Throws
  /// [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA or the community refuses or
  /// cannot be reached; the application is then kept.
  Future<void> withdraw(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    final requestId = community?.joinRequestId;
    if (community == null || !community.isApplying || requestId == null) {
      return;
    }

    final vta = await _grantedVta();
    try {
      await _sdk.joinClient().withdraw(
        communityDid,
        requestId: requestId,
        agent: vta,
        persona: await _personaSigner(vta, community),
      );
    } on MeetingPlaceVtcSDKException catch (error) {
      final code = error.refusalCode ?? '';
      if (code.endsWith(':alreadyDecided')) {
        await checkApplication(communityDid);
        rethrow;
      }
      if (!code.endsWith(':notFound')) rethrow;
    }
    await _repository.saveCommunity(community.withApplication(isMember: false));
  }

  /// Leaves [communityDid] as the persona the member joined it with: the
  /// community ends the membership, the VTA archives its membership cards,
  /// and this phone forgets the community. Does nothing for a community
  /// this phone does not know.
  ///
  /// What shows the membership and its end stays on this phone as a
  /// [VtcLeftMembership]: the card as the VTA kept it, if it held one, and
  /// the community's signed answer. A community that already counts the
  /// persona as no member is forgotten all the same, without an answer.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA or the community refuses or
  /// cannot be reached, e.g. with HTTP status 409 when the persona is the
  /// community's last administrator; the community is then kept, and no
  /// left membership recorded.
  Future<void> leave(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null) return;

    final vta = await _grantedVta();
    final cards = _sdk.communityImport(vta);
    final card = await cards.membershipCard(
      communityDid,
      personaDid: community.personaDid,
    );
    TrustTaskExchange? leaveExchange;
    try {
      final receipt = await _sdk.joinClient().leave(
        communityDid,
        agent: vta,
        persona: await _personaSigner(vta, community),
      );
      leaveExchange = receipt.exchange;
    } on MeetingPlaceVtcSDKException catch (error) {
      if (!(error.refusalCode?.endsWith(':notMember') ?? false)) rethrow;
    }
    await _repository.saveLeftMembership(
      VtcLeftMembership(
        communityDid: communityDid,
        personaDid: community.personaDid,
        leftAt: DateTime.now(),
        name: community.name,
        card: card,
        leaveExchange: leaveExchange,
      ),
    );
    // Else the VTA backup would offer the membership back on the next scan.
    await cards.archiveMembershipCards(
      communityDid,
      personaDid: community.personaDid,
    );
    await _repository.removeCommunity(communityDid);
    _membershipsChanged.add(null);
  }

  /// The membership card [communityDid] issued to the member's persona
  /// there, as their VTA keeps it, or null when this phone knows no such
  /// membership or the VTA holds no card yet, e.g. while the community has
  /// still to deliver it.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA cannot be reached.
  Future<VtcMembershipCard?> membershipCard(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null || !community.isMember) return null;
    final card = await _sdk
        .communityImport(await _grantedVta())
        .membershipCard(communityDid, personaDid: community.personaDid);
    return card == null ? null : VtcMembershipCard.fromCredential(card);
  }

  /// The member's role in [communityDid], e.g. `member` or `moderator`, as
  /// the role card their VTA keeps says, or null when this phone knows no
  /// such membership or the VTA holds no card yet, e.g. while the community
  /// has still to deliver it.
  ///
  /// Throws as [membershipCard] does.
  Future<String?> communityRole(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null || !community.isMember) return null;
    return _sdk
        .communityImport(await _grantedVta())
        .role(communityDid, personaDid: community.personaDid);
  }

  /// The community [communityDid]'s own check of the member's identity
  /// there, as their VTA keeps it, or null when this phone knows no such
  /// membership or the VTA holds no valid check. The community delivers it
  /// to the VTA once an administrator checked the person.
  ///
  /// Throws as [membershipCard] does.
  Future<VtcIdentityCheck?> identityCheck(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null || !community.isMember) return null;
    final vta = await _grantedVta();
    final held = await vta.findCredentials(
      type: VtcIdentityCheck.statementType,
      issuerDid: communityDid,
      subjectDid: community.personaDid,
    );
    for (final statement in held) {
      final credential = await vta.credential(statement.id);
      if (credential == null) continue;
      final check = VtcIdentityCheck.fromCredential(
        credential,
        communityDid: communityDid,
      );
      if (check?.memberDid == community.personaDid) return check;
    }
    return null;
  }

  /// Every membership card of the member: those a community issued that
  /// their VTA holds, then those of the memberships they left, the latest
  /// first. A card of a membership left is shown once, as left. Test
  /// credentials this phone issued are not memberships of a community.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA cannot be reached.
  Future<List<VtcMembershipEntry>> membershipCredentials() async {
    final held = await _sdk
        .communityImport(await _grantedVta())
        .membershipCards();
    final mockIssuer = await _mockIssuer.did();
    final communities = await _repository.communities();
    final left = [...await _repository.leftMemberships()]
      ..sort((a, b) => b.leftAt.compareTo(a.leftAt));

    final leftEntries = [
      for (final membership in left)
        if (membership.card case final json?)
          if (VtcMembershipCard.fromCredential(json) case final card?)
            VtcMembershipEntry(
              card: card,
              communityName: membership.name,
              left: membership,
            ),
    ];
    final leftKeys = {for (final entry in leftEntries) entry.key};
    final heldEntries = [
      for (final StoredCredential(:record, credential: json) in held)
        if (VtcMembershipCard.fromCredential(json) case final card?)
          if (card.issuer != mockIssuer)
            VtcMembershipEntry(
              card: card,
              stored: record,
              communityName:
                  communities
                      .where((c) => c.communityDid == card.issuer)
                      .firstOrNull
                      ?.name ??
                  switch (json['name']) {
                    final String name => name,
                    _ => null,
                  },
            ),
    ].where((entry) => !leftKeys.contains(entry.key));

    return [...heldEntries, ...leftEntries];
  }

  /// Reads whether [entry]'s community revoked its card, from the
  /// community's signed status list. The list read for a membership left is
  /// kept with it, so what showed the card's state stays when the community
  /// no longer answers.
  ///
  /// Never throws: a list that cannot be read or checked is
  /// [VtcCardState.unknown], with what it said when last read.
  Future<VtcCardStatus> checkMembershipStatus(VtcMembershipEntry entry) async {
    final now = DateTime.now();
    if (entry.card.validUntil case final until? when now.isAfter(until)) {
      return const VtcCardStatus(state: VtcCardState.expired);
    }
    final CredentialStatusCheck check;
    try {
      check = await _sdk.statusListClient().check(entry.card.credential);
    } on MeetingPlaceVtcSDKException catch (error) {
      return VtcCardStatus(
        state: VtcCardState.unknown,
        lastKnown: await _lastKnown(entry),
        failure: error.code,
      );
    }
    if (check.state == CredentialStatusState.noStatus) {
      return const VtcCardStatus(state: VtcCardState.notRevocable);
    }
    final revoked = check.state == CredentialStatusState.revoked;
    if (entry.left case final left?) {
      await _repository.saveLeftMembership(
        left.withStatus(
          VtcStatusRecord(
            revoked: revoked,
            checkedAt: check.checkedAt,
            statusList: check.statusListCredential!,
          ),
        ),
      );
    }
    return VtcCardStatus(
      state: revoked ? VtcCardState.revoked : VtcCardState.valid,
      checkedAt: check.checkedAt,
      statusListUrl: check.statusList,
      index: check.index,
      statusList: check.statusListCredential,
    );
  }

  /// The last status stored for [entry]'s membership left, as stored now.
  Future<VtcStatusRecord?> _lastKnown(VtcMembershipEntry entry) async {
    final left = entry.left;
    if (left == null) return null;
    final stored = (await _repository.leftMemberships())
        .where((membership) => membership.key == left.key)
        .firstOrNull;
    return (stored ?? left).lastStatus;
  }

  /// Looks up the member's membership of [communityDid] in the cards backed
  /// up to their VTA, without recording it.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked.
  Future<CommunityMembership?> importMembership(String communityDid) async {
    final vta = await _grantedVta();
    return _sdk.communityImport(vta).find(communityDid);
  }

  /// Records [membership], so its community is known to this phone.
  Future<void> rememberMembership(CommunityMembership membership) {
    return _repository.saveCommunity(
      VtcCommunity(
        communityDid: membership.communityDid,
        personaDid: membership.persona.did,
        contextId: membership.persona.contextId,
        name: membership.name,
      ),
    );
  }

  /// The identities the member's VTA holds, to choose one to join with.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked.
  Future<List<VtaPersona>> vtaPersonas() async {
    final vta = await _grantedVta();
    return vta.listPersonas();
  }

  /// The member's VTA as the agent that signs as their persona.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked.
  Future<VtaClient> agent() => _grantedVta();

  /// Readies [membership]'s persona to sign in: enrols the approval key and
  /// ensures the persona's vault entry on the VTA.
  Future<SignInPersona> preparePersona(CommunityMembership membership) async {
    return _sdk.prepareSignIn(
      vta: await _grantedVta(),
      membership: membership,
      userVerificationDid: await _userVerificationKey.ensureKey(),
      deviceName: _deviceName,
      platform: _platform,
    );
  }

  /// The biometric approval key, as the signer of an approval.
  Future<TrustTaskSigner> approvalSigner() => _userVerificationKey.signer();

  Future<SignInPersona> _personaSigner(VtaClient vta, VtcCommunity community) {
    return _sdk.personaSigner(
      vta: vta,
      communityDid: community.communityDid,
      persona: _persona(community),
    );
  }

  /// Keeps [cards] on the VTA. A card that is not kept is skipped: the
  /// community holds the membership either way, and only another app of the
  /// member cannot import it.
  static Future<void> _keepCards(
    VtaClient vta,
    List<Map<String, dynamic>> cards,
    String contextId,
  ) async {
    for (final card in cards) {
      try {
        await vta.keepCredential(card, contextId: contextId);
      } on MeetingPlaceVtcSDKException {
        continue;
      }
    }
  }

  static VtaPersona _persona(VtcCommunity community) => VtaPersona(
    did: community.personaDid,
    contextId: community.contextId,
    signingKeyId: community.signingKeyId,
  );

  static bool _isDid(String text) =>
      text.startsWith('did:') && !text.contains(RegExp(r'\s'));

  /// A community's DID: a `did:webvh` or `did:web`, the methods a community
  /// publishes under, in DID syntax.
  static final _communityDid = RegExp(
    r'^did:(webvh|web):[A-Za-z0-9._%-]+(:[A-Za-z0-9._%-]+)*$',
  );

  /// Longest community DID read: a scanned or pasted text is untrusted.
  static const _maxDidLength = 2048;

  static bool _isCommunityDid(String text) =>
      text.length <= _maxDidLength && _communityDid.hasMatch(text);

  Future<VtaClient> _grantedVta() async {
    final linkedVta = await _repository.getLinkedVta();
    if (linkedVta == null || !linkedVta.isGranted) {
      throw const VtaNotLinkedException();
    }
    return _vtaClient(linkedVta);
  }

  /// One client per link, so its REST session is reused.
  /// Zero-fills and drops every lent connection key. Best effort: Dart
  /// cannot wipe copies already handed out; dropping them lets them go.
  Future<void> _forgetConnectionKeys() async {
    final lent = [..._lentConnectionKeys.values];
    _lentConnectionKeys.clear();
    for (final lending in lent) {
      try {
        final key = await lending;
        key.fillRange(0, key.length, 0);
      } on Object {
        // Never lent: nothing to forget.
      }
    }
  }

  VtaClient _vtaClient(LinkedVta linkedVta) {
    final client = _client;
    if (client != null && client.vtaDid == linkedVta.vtaDid) return client;
    return _client = _sdk.vtaClient(
      vtaDid: linkedVta.vtaDid,
      manager: Ed25519DidKeySigner.fromSeed(linkedVta.managerSeed),
    );
  }
}

/// Reports a card's collection as it goes, to whoever asked.
class _DeliveryReport {
  _DeliveryReport(String personaDid, this._onDelivery)
    : _delivery = VtcCardDelivery(personaDid: personaDid);

  final void Function(VtcCardDelivery delivery)? _onDelivery;
  VtcCardDelivery _delivery;
  bool _isCollecting = false;

  /// Whether a collection from the identity's inbox ran.
  bool get isCollecting => _isCollecting;

  void step(
    VtcDeliveryStep step,
    VtcDeliveryStatus status, {
    String? signingKeyId,
    String? keyAgreementKeyId,
    String? mediatorDid,
    int? waiting,
    TrustTaskDocument? issue,
    bool? isKeptAsValid,
  }) {
    _isCollecting = true;
    _delivery = _delivery.at(
      step,
      status,
      signingKeyId: signingKeyId,
      keyAgreementKeyId: keyAgreementKeyId,
      mediatorDid: mediatorDid,
      waiting: waiting,
      issue: issue,
      isKeptAsValid: isKeptAsValid,
    );
    _onDelivery?.call(_delivery);
  }
}

/// Keys an identity's VTA lent and the identity's inbox, held in memory
/// while its membership card is collected.
class _CardCollection {
  _CardCollection(this.keys, this.inbox, {required this._idle});

  final PersonaDidManager keys;
  final PersonaInbox inbox;
  final Duration _idle;
  Timer? _idleTimer;

  /// Marks the collection used, to end with [onIdle] once unused for a while.
  void touch(void Function() onIdle) {
    _idleTimer?.cancel();
    _idleTimer = Timer(_idle, onIdle);
  }

  Future<void> end() async {
    _idleTimer?.cancel();
    await inbox.close();
    keys.forget();
  }
}

/// Provides the [VtcService].
final vtcServiceProvider = Provider<VtcService>(
  (ref) => VtcService(
    sdk: ref.read(vtcSdkProvider),
    repository: SecureStorageVtcRepository(),
    userVerificationKey: UserVerificationKey(
      SecureUserVerificationKeyStorage(promptTitle: 'Approve signing in'),
    ),
  ),
  name: 'vtcServiceProvider',
);

/// Whether [criterion] is met by presenting one held credential: a way in
/// this app can apply under once an identity holds it.
bool isMetByOneCredential(JoinCriterion criterion) =>
    criterion.asksOnlyForCredentials &&
    criterion.credentials!.typeAlternatives.length == 1;

/// A presentation of [credential] by [holderDid], the identity applying, to
/// send with an application to a community.
///
/// Built here rather than by the VTA's `vault/credentials/present`: the VTA
/// records each presentation in a consent receipt whose subject must be a
/// `did:key`, so it refuses to present a credential made out to an MPX
/// identity, a `did:webvh` persona. The community checks the credential's
/// own proof and that its subject is the applicant, and the application
/// carrying this is signed by that identity, so nothing is lost on the
/// community's side; the VTA keeps no record of the disclosure.
Map<String, dynamic> joinPresentation(
  Map<String, dynamic> credential, {
  required String holderDid,
}) => {
  '@context': ['https://www.w3.org/ns/credentials/v2'],
  'type': ['VerifiablePresentation'],
  'holder': holderDid,
  'verifiableCredential': [credential],
};
