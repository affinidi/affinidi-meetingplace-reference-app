import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/linked_vta.dart';
import '../../../domain/models/vtc/mock_credential_template.dart';
import '../../../domain/models/vtc/vta_enrolment_offer.dart';
import '../../../domain/models/vtc/vtc_card_delivery.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/models/vtc/vtc_identity_check.dart';
import '../../../domain/models/vtc/vtc_left_membership.dart';
import '../../../domain/models/vtc/vtc_membership_card.dart';
import '../../../domain/models/vtc/vtc_membership_entry.dart';
import '../../../domain/models/vtc/vtc_vetter_card.dart';
import '../../../domain/models/vtc/vtc_vetter_desk.dart';
import '../../../domain/models/vtc/vtc_vetting.dart';
import '../../../domain/repositories/vtc_repository.dart';
import '../../../infrastructure/providers/vtc_sdk_provider.dart';
import '../../../infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import '../../../infrastructure/vtc/mock_credential_issuer.dart';
import '../../../infrastructure/vtc/user_verification_key.dart';
import '../../../infrastructure/vtc/vta_enrolment_client.dart';

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

/// Thrown when a community action needs a membership this phone does not
/// hold.
class NotACommunityMemberException implements Exception {
  /// Creates a [NotACommunityMemberException].
  const NotACommunityMemberException();
}

/// Thrown when the member asks to vet for a community where they hold no
/// vetter role card that is in date and not revoked.
class NotVetterException implements Exception {
  /// Creates a [NotVetterException].
  const NotVetterException();
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
/// The link is manual or by an enrolment offer. Manually, the phone mints a
/// manager key and shows its DID; the VTA's administrator grants it; the
/// phone then checks for the grant. By an offer the VTA host shows, the
/// phone submits the manager key to the host, and the administrator grants
/// it there after comparing codes. The biometric approval key is enrolled
/// only when a sign-in first needs it.
class VtcService {
  /// Creates a [VtcService].
  ///
  /// Enrolment offers with a plain HTTP host are accepted only when
  /// [allowHttpEnrolment], by default in debug builds only.
  VtcService({
    required this._sdk,
    required this._repository,
    required this._userVerificationKey,
    MockCredentialIssuer? mockCredentialIssuer,
    VtaEnrolmentClient? enrolmentClient,
    bool allowHttpEnrolment = kDebugMode,
    String? platform,
  }) : _allowHttpEnrolment = allowHttpEnrolment,
       _enrolmentClient =
           enrolmentClient ?? VtaEnrolmentClient(allowHttp: allowHttpEnrolment),
       _platform = platform ?? Platform.operatingSystem,
       _mockIssuer = mockCredentialIssuer ?? MockCredentialIssuer();

  final MeetingPlaceVtcSDK _sdk;
  final VtcRepository _repository;
  final UserVerificationKey _userVerificationKey;
  final MockCredentialIssuer _mockIssuer;
  final VtaEnrolmentClient _enrolmentClient;
  final bool _allowHttpEnrolment;
  final String _platform;
  VtaClient? _client;
  final _membershipsChanged = StreamController<void>.broadcast();

  /// Fires each time the member's membership cards change: a card a
  /// community issued is kept on their VTA, e.g. after a role change, or a
  /// membership is left.
  Stream<void> get membershipsChanged => _membershipsChanged.stream;

  /// The identity keys lent and inboxes open, by community, while a
  /// membership card is collected, so a check every few seconds borrows the
  /// keys once: the VTA audits each loan.
  final Map<String, _CardCollection> _collections = {};

  /// Connection DIDComm keys the VTA lent, by key id, for as long as the
  /// link lasts.
  final Map<String, Future<Uint8List>> _lentConnectionKeys = {};

  /// The applicants' vetting cards the member, as a vetter, checked, by
  /// request id, with the id of the inbox message carrying each. Held in
  /// memory only: the card's details are personal, and the message waits in
  /// the identity's inbox until the session ends.
  final Map<String, (String, ReceivedVettingCard)> _vettingCards = {};

  /// How long lent keys are held without a check before they are forgotten.
  static const _collectionIdle = Duration(minutes: 5);

  /// When each settled membership was last refreshed, by community, so
  /// coming back to the foreground asks each community at most once per
  /// [_refreshInterval]: every renewal has the community issue new cards.
  final Map<String, DateTime> _refreshedAt = {};

  /// How long a refreshed membership is not asked again in the background.
  static const _refreshInterval = Duration(hours: 1);

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

  /// Starts linking the VTA the enrolment offer [link] names: submits a new
  /// manager key to the VTA host, with a proof bound to the offer, and
  /// returns the code the app and the host both show.
  ///
  /// The link is stored only once the VTA answers and the host has taken
  /// the key with the same code.
  ///
  /// Throws [InvalidVtaEnrolmentOfferException] when [link] is not an offer
  /// the app accepts, [VtaAlreadyLinkedException] when a VTA is linked or
  /// being linked, [MeetingPlaceVtcSDKException] when the VTA cannot be
  /// reached, and [VtaEnrolmentException] when the host refuses the key.
  Future<String> startEnrolment(String link) async {
    final offer = VtaEnrolmentOffer.parse(
      link,
      now: clock.now(),
      allowHttp: _allowHttpEnrolment,
    );
    if (await _repository.getLinkedVta() != null) {
      throw const VtaAlreadyLinkedException();
    }

    final manager = _sdk.newManagerKey();
    final client = _sdk.vtaClient(vtaDid: offer.vtaDid, manager: manager);
    await client.checkReachable();
    final code = await _enrolmentClient.submit(
      offer,
      manager,
      now: clock.now(),
    );

    await _repository.saveLinkedVta(
      LinkedVta(
        vtaDid: offer.vtaDid,
        managerSeed: manager.seed,
        isGranted: false,
        enrolment: VtaEnrolment(
          url: offer.url,
          code: code,
          expiresAt: offer.expiresAt,
        ),
      ),
    );
    _client = client;
    return code;
  }

  /// Asks the VTA host where the pending enrolment stands.
  ///
  /// Returns null when no enrolment is pending. Throws
  /// [VtaEnrolmentException] when the host cannot be reached.
  Future<VtaEnrolmentStatus?> checkEnrolment() async {
    final enrolment = (await _repository.getLinkedVta())?.enrolment;
    if (enrolment == null) return null;
    return _enrolmentClient.status(enrolment.url);
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

  /// Replaces the details of the profile [profileId] that the identity
  /// [personaDid] in [contextId] wears, which then discloses them. Throws as
  /// [createIdentity] does.
  Future<void> updateIdentity({
    required String contextId,
    required String personaDid,
    required String profileId,
    required VtaProfile profile,
  }) async => (await _grantedVta()).updateProfile(
    contextId: contextId,
    personaDid: personaDid,
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
  /// signs its credentials, whose private key never leaves the VTA, one for
  /// DIDComm, and a P-256 one for DIDComm with the hosted control plane,
  /// which cannot decrypt X25519. The VTA lends the last two through
  /// [lendConnectionKey].
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA refuses or cannot be
  /// reached.
  Future<
    ({
      VtaConnectionKey signing,
      VtaConnectionKey agreement,
      VtaConnectionKey controlPlaneAgreement,
    })
  >
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
  /// credential (see [joinPresentation]), and with the vetters' statements
  /// gathered ([vetting]) when it asks for vetting.
  ///
  /// The first application to a community is made as [persona], one of
  /// [vtaPersonas], or else as a new persona the VTA creates; a later one
  /// applies as the same persona. Once admitted, the issued cards are kept
  /// on the VTA, where other apps of the member find them; an admission
  /// returns its membership card only when the VTA kept it.
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
    final statements = (criterion?.asksForVetting ?? false)
        ? (await _repository.findVetting(manifest.communityDid))?.statements
        : null;
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
      vettingStatements: statements ?? const [],
      attributes: attributes,
    );
    switch (verdict) {
      case JoinAdmitted(:final credentials, :final membershipCard):
        final member = community.withApplication(isMember: true);
        await _repository.saveCommunity(member);
        final kept = await _keepCards(vta, credentials, community.contextId);
        _membershipsChanged.add(null);
        await _settle(vta, member, membershipCard, verdict.requestId);
        if (membershipCard != null && !kept.contains(membershipCard)) {
          // Not the VTA's to show: read from there once it holds one.
          return JoinAdmitted(
            requestId: verdict.requestId,
            roleCard: verdict.roleCard,
            role: verdict.role,
          );
        }
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

  /// The vetters [manifest]'s community lists, asked as the identity
  /// applying, which [joiningIdentity] records first.
  ///
  /// Throws as [join] does.
  Future<List<ListedVetter>> vetters(JoinManifest manifest) async {
    final vta = await _grantedVta();
    final community = (await _repository.findCommunity(manifest.communityDid))!;
    return _sdk.joinClient().listVetters(
      manifest.communityDid,
      agent: vta,
      persona: await _personaSigner(vta, community),
    );
  }

  /// The member's vetting for [communityDid], as recorded, or null.
  Future<VtcVetting?> vetting(String communityDid) =>
      _repository.findVetting(communityDid);

  /// Asks the vetter [ticket] names to vet the identity applying to
  /// [manifest]'s community, under [criterion], which asks for vetting.
  /// Records the request, as the latest to that vetter, and returns the
  /// vetting. [vetterName] is how the community lists the vetter, if known.
  /// Each step is reported to [onStep] as it starts.
  ///
  /// Throws [VettingException] for a ticket of another community, and as
  /// [join] does.
  Future<VtcVetting> startVetting(
    JoinManifest manifest, {
    required JoinCriterion criterion,
    required VettingTicket ticket,
    String? vetterName,
    void Function(VtcVettingWork step)? onStep,
  }) async {
    final requirements = criterion.vetting!;
    final vta = await _grantedVta();
    final member = (await _repository.findCommunity(manifest.communityDid))!;
    final recorded = await _repository.findVetting(manifest.communityDid);
    // A changed way in starts over: its statements count for another.
    final vetting = recorded?.criterionId == criterion.id
        ? recorded!
        : VtcVetting(
            communityDid: manifest.communityDid,
            criterionId: criterion.id,
            vetterRole: requirements.vetterRole,
            salt: newCommitmentSalt(),
          );
    onStep?.call(VtcVettingWork.unlockingIdentity);
    final collection = await _collection(vta, member);
    onStep?.call(VtcVettingWork.sendingRequest);
    final request = await _sdk
        .vettingApplicant(collection.keys)
        .request(
          communityDid: manifest.communityDid,
          ticket: ticket,
          requirementsDigest: criterion.requirementsDigest,
        );
    final updated = vetting.withRequest(
      VtcVettingRequest(
        vetterDid: ticket.vetter,
        vetterName: vetterName,
        request: request.toJson(),
      ),
    );
    await _repository.saveVetting(updated);
    return updated;
  }

  /// Picks up what the vetters asked for [communityDid] sent the applying
  /// identity, checks each, and records how far each vetter got: an
  /// acceptance with their role, a session, a statement, a decline, or a
  /// refusal. What fails a check is dropped. Returns the vetting, or null
  /// when there is none.
  ///
  /// Throws as [join] does.
  Future<VtcVetting?> checkVetting(String communityDid) async {
    final vetting = await _repository.findVetting(communityDid);
    final member = await _repository.findCommunity(communityDid);
    if (vetting == null ||
        member == null ||
        !vetting.requests.any((request) => request.isOpen)) {
      return vetting;
    }
    final vta = await _grantedVta();
    final collection = await _collection(vta, member);
    await collection.inbox.open();
    final applicant = _sdk.vettingApplicant(collection.keys);

    var updated = vetting;
    for (final request in vetting.requests.where((r) => r.isOpen)) {
      final received = await collection.inbox.peerDocuments(
        senderDid: request.vetterDid,
        types: VettingTask.fromVetter,
      );
      var advanced = request;
      for (final peer in received) {
        advanced = await _advance(applicant, advanced, peer.document, vetting);
      }
      updated = updated.withRequest(advanced);
      try {
        await collection.inbox.remove([
          for (final peer in received) peer.messageId,
        ]);
      } on MeetingPlaceVtcSDKException {
        // Read again next time, and recognised as already handled.
      }
    }
    await _repository.saveVetting(updated);
    return updated;
  }

  /// [request] after [document] from its vetter, or as it was when the
  /// document does not move it on or fails a check.
  Future<VtcVettingRequest> _advance(
    VettingApplicant applicant,
    VtcVettingRequest request,
    TrustTaskDocument document,
    VtcVetting vetting,
  ) async {
    final accepted = request.accepted;
    try {
      if (request.status == VtcVettingStatus.requested) {
        if (document.threadId != request.requestDocument.id) return request;
        return request.acceptedBy(
          await applicant.accepted(
            document,
            request: request.requestDocument,
            communityDid: vetting.communityDid,
            vetterRole: vetting.vetterRole,
          ),
        );
      }
      if (accepted == null) return request;
      if (document.type == VettingTask.session) {
        // A new session replaces the one before, and its card.
        applicant.openSession(
          document,
          vetter: accepted,
          communityDid: vetting.communityDid,
        );
        return request.inSession(document);
      }
      if (document.type == VettingTask.decline) {
        return request.declined(applicant.declined(document, vetter: accepted));
      }
      final sent = request.sentCard;
      if (document.type == VettingTask.issue &&
          request.status == VtcVettingStatus.cardSent &&
          sent != null) {
        return request.vouched(
          await applicant.receiveStatement(
            document,
            session: _session(applicant, request, vetting.communityDid),
            sent: sent,
            communityDid: vetting.communityDid,
          ),
        );
      }
      return request;
    } on VettingException catch (error) {
      // Only an answer to the request itself refuses it; anything else
      // that fails a check is dropped.
      return request.status == VtcVettingStatus.requested
          ? request.refused(error.failure)
          : request;
    }
  }

  /// Previews what the VTA would put on the card for the session the vetter
  /// [vetterDid] opened for [communityDid]: the claims the session asks
  /// for. Nothing leaves the VTA.
  ///
  /// Throws [VettingException] when the session has lapsed, and as [join]
  /// does.
  Future<DisclosurePreview> previewVettingCard(
    String communityDid,
    String vetterDid,
  ) async {
    final (member, vetting, request) = await _vettingOf(
      communityDid,
      vetterDid,
    );
    final vta = await _grantedVta();
    final session = _session(
      _sdk.vettingApplicant((await _collection(vta, member)).keys),
      request,
      communityDid,
    );
    return vta.previewDisclosure(
      persona: _persona(member),
      verifierDid: vetterDid,
      requestedClaims: [...session.requiredClaims, ...session.optionalClaims],
      purpose: 'In-person vetting for ${member.name ?? communityDid}',
    );
  }

  /// Sends the vetter [vetterDid] the card for their session, carrying the
  /// claims of [preview] the member approved. Call only once the member
  /// confirmed the match code. The VTA records the disclosure.
  ///
  /// Each step is reported to [onStep] as it starts.
  ///
  /// Throws [VettingException] when the session has lapsed, [ArgumentError]
  /// when a claim the session requires is missing, and as [join] does.
  Future<VtcVetting> sendVettingCard(
    String communityDid,
    String vetterDid, {
    required DisclosurePreview preview,
    void Function(VtcVettingWork step)? onStep,
  }) async {
    final (member, vetting, request) = await _vettingOf(
      communityDid,
      vetterDid,
    );
    final vta = await _grantedVta();
    final applicant = _sdk.vettingApplicant(
      (await _collection(vta, member)).keys,
    );
    final session = _session(applicant, request, communityDid);
    onStep?.call(VtcVettingWork.recordingDisclosure);
    await vta.presentDisclosure(
      persona: _persona(member),
      previewId: preview.previewId,
    );
    onStep?.call(VtcVettingWork.sendingDetails);
    final sent = await applicant.sendCard(
      session,
      claims: [
        for (final claim in preview.claims)
          if (claim.value case final Object value)
            VettingCardClaim(type: claim.type, value: value),
      ],
      salt: vetting.salt,
      parentThreadId: request.requestDocument.id,
    );
    final updated = vetting.withRequest(request.cardSentAs(sent));
    await _repository.saveVetting(updated);
    return updated;
  }

  /// Ends the session with [vetterDid] for [communityDid] without sending a
  /// card, e.g. because the match codes differ, telling the vetter so their
  /// side ends too.
  Future<VtcVetting> abandonVetting(
    String communityDid,
    String vetterDid,
  ) async {
    final (member, vetting, request) = await _vettingOf(
      communityDid,
      vetterDid,
    );
    await _tellVetterEnded(member, request);
    final updated = vetting.withRequest(request.abandoned());
    await _repository.saveVetting(updated);
    return updated;
  }

  /// Forgets the member's vetting for [communityDid] on this phone: the
  /// statements gathered and every request, so applying starts over. A
  /// vetter who accepted a request still open is told it ended.
  ///
  /// Before the member ever applied, the identity recorded for applying is
  /// forgotten too, so they choose it again. A member, or one whose
  /// application is open, keeps theirs.
  Future<void> stopVetting(String communityDid) async {
    final vetting = await _repository.findVetting(communityDid);
    final member = await _repository.findCommunity(communityDid);
    if (vetting != null && member != null) {
      for (final request in vetting.requests.where((r) => r.isOpen)) {
        await _tellVetterEnded(member, request);
      }
    }
    await _repository.removeVetting(communityDid);
    final community = await _repository.findCommunity(communityDid);
    if (community != null && !community.isMember && !community.isApplying) {
      await _repository.removeCommunity(communityDid);
    }
  }

  /// Tells the vetter of [request] the member ended it, so the vetter's
  /// session ends rather than waits. A vetter who has not accepted yet
  /// holds no session to end. Best effort: one who cannot be reached is
  /// left to end it on their side, and the member's choice stands.
  Future<void> _tellVetterEnded(
    VtcCommunity member,
    VtcVettingRequest request,
  ) async {
    final accepted = request.accepted;
    if (accepted == null || !request.isOpen) return;
    try {
      final vta = await _grantedVta();
      await _sdk
          .vettingApplicant((await _collection(vta, member)).keys)
          .decline(
            vetter: accepted,
            parentThreadId: request.requestDocument.id,
          );
    } on MeetingPlaceVtcSDKException {
      // The vetter ends the session on their side.
    }
  }

  Future<(VtcCommunity, VtcVetting, VtcVettingRequest)> _vettingOf(
    String communityDid,
    String vetterDid,
  ) async {
    final member = await _repository.findCommunity(communityDid);
    final vetting = await _repository.findVetting(communityDid);
    final request = vetting?.requestTo(vetterDid);
    if (member == null || vetting == null || request == null) {
      throw StateError('no vetting by this vetter');
    }
    return (member, vetting, request);
  }

  /// The session [request]'s vetter opened, checked again as it was kept.
  static VettingSession _session(
    VettingApplicant applicant,
    VtcVettingRequest request,
    String communityDid,
  ) {
    final session = request.session;
    final accepted = request.accepted;
    if (session == null || accepted == null) {
      throw StateError('no session open');
    }
    return applicant.openSession(
      TrustTaskDocument.fromJson(session),
      vetter: accepted,
      communityDid: communityDid,
    );
  }

  /// Whether the member may vet applicants for [communityDid]: they are a
  /// member there, and their VTA keeps a vetter role card the community
  /// issued them that is in date and not revoked.
  ///
  /// The community sends that card to the identity's inbox when it makes
  /// the member a vetter. While the VTA holds none, the cards waiting there
  /// are kept on the VTA first, as a membership card is.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA or the community's status
  /// list cannot be reached.
  ///
  /// The answer is kept for [couldVet].
  Future<bool> canVet(String communityDid) async =>
      await vetterCard(communityDid) != null;

  /// The member's vetter role card for [communityDid] when [canVet], else
  /// null. Checked, and kept for [couldVet], as [canVet] is.
  Future<VtcVetterCard?> vetterCard(String communityDid) async {
    final held = await _heldVetterCard(communityDid);
    return held == null ? null : VtcVetterCard.fromCredential(held.$3);
  }

  /// The member's vetter role card for [communityDid], as [canVet] finds
  /// it, with the member and their VTA; null when they may not vet there.
  /// The answer is kept for [couldVet].
  Future<(VtcCommunity, VtaClient, Map<String, dynamic>)?> _heldVetterCard(
    String communityDid,
  ) async {
    final member = await _repository.findCommunity(communityDid);
    if (member == null || !member.isMember) return null;
    final vta = await _grantedVta();
    var card = await _vetterCard(vta, member);
    if (card == null && await _keepWaitingCards(vta, member)) {
      card = await _vetterCard(vta, member);
    }
    final canVet = card != null;
    // Read again: the record may have changed while the VTA answered.
    final latest = await _repository.findCommunity(communityDid);
    if (latest != null && latest.isVetter != canVet) {
      await _repository.saveCommunity(latest.withVetter(isVetter: canVet));
    }
    return card == null ? null : (member, vta, card);
  }

  /// Whether the member could vet for [communityDid] when [canVet] last
  /// answered; only what this phone recorded, so it answers at once.
  Future<bool> couldVet(String communityDid) async {
    final member = await _repository.findCommunity(communityDid);
    return member != null && member.isMember && member.isVetter;
  }

  /// Publishes [profile] as the member's vetter profile with
  /// [communityDid], replacing what the community held, and records it on
  /// the desk.
  ///
  /// Throws [NotVetterException] when the member may not vet there, or the
  /// community says so; [MeetingPlaceVtcSDKException] with an
  /// `invalidDocument` code for a profile the community would refuse, and
  /// as [canVet] does.
  Future<VtcVetterDesk> publishVetterProfile(
    String communityDid,
    VetterProfile profile,
  ) async {
    final held = await _heldVetterCard(communityDid);
    if (held == null) throw const NotVetterException();
    final (member, vta, roleCard) = held;
    final PublishedVetterProfile published;
    try {
      published = await _sdk.joinClient().publishVetterProfile(
        communityDid,
        profile,
        agent: vta,
        persona: await _personaSigner(vta, member),
      );
    } on MeetingPlaceVtcSDKException catch (e) {
      if (e.refusalCode == VettingCommunityTask.profileNotEligible) {
        throw const NotVetterException();
      }
      rethrow;
    }
    final desk =
        (await _repository.findVetterDesk(communityDid) ??
                VtcVetterDesk(communityDid: communityDid))
            .withProfile(
              VtcVetterProfileRecord(
                profile: profile,
                listed: published.listed,
                updatedAt: published.updatedAt,
                roleCardId: roleCard['id'] as String?,
              ),
            );
    await _repository.saveVetterDesk(desk);
    return desk;
  }

  /// Whether the member may vet for [communityDid] but the community holds
  /// no profile of theirs that this phone sent: none was, or it was sent
  /// under a vetter role card since replaced, whose revocation deleted it.
  /// Until they publish one, applicants cannot find them.
  ///
  /// Throws as [canVet] does.
  Future<bool> vetterProfileNeeded(String communityDid) async {
    final held = await _heldVetterCard(communityDid);
    if (held == null) return false;
    final (_, _, roleCard) = held;
    final recorded = (await _repository.findVetterDesk(communityDid))?.profile;
    return recorded == null || recorded.roleCardId != roleCard['id'];
  }

  /// Keeps on [vta] the cards [member]'s community sent the identity's
  /// inbox, then removes them from it. Returns whether there were any.
  Future<bool> _keepWaitingCards(VtaClient vta, VtcCommunity member) async {
    final collection = await _collection(vta, member);
    await collection.inbox.open();
    final pickup = await collection.inbox.issuedCredentials(
      issuerDid: member.communityDid,
    );
    if (pickup.credentials.isEmpty) return false;
    await _keepCards(vta, [
      for (final issued in pickup.credentials) issued.credential,
    ], member.contextId);
    await _removeFromInbox(collection, [
      for (final issued in pickup.credentials) issued.messageId,
    ]);
    _membershipsChanged.add(null);
    return true;
  }

  /// The member's vetting desk for [communityDid], as recorded, or null.
  Future<VtcVetterDesk?> vetterDesk(String communityDid) =>
      _repository.findVetterDesk(communityDid);

  /// How long a vetting ticket this app mints lasts: long enough to show
  /// it to the applicant in front of the vetter, no longer.
  static const vettingTicketValidity = Duration(minutes: 15);

  /// Mints a ticket for an applicant to ask the member to vet them for
  /// [communityDid], good for one request within [vettingTicketValidity],
  /// and records it on the desk. Each step is reported to [onStep] as it
  /// starts.
  ///
  /// Throws [NotVetterException] when the member may not vet there, and as
  /// [canVet] does.
  Future<VetterTicket> createVettingTicket(
    String communityDid, {
    void Function(VtcTicketStep step)? onStep,
  }) async {
    onStep?.call(VtcTicketStep.checkingCard);
    final member = await _repository.findCommunity(communityDid);
    if (member == null || !await canVet(communityDid)) {
      throw const NotVetterException();
    }
    onStep?.call(VtcTicketStep.creating);
    final now = clock.now();
    final ticket = VetterTicket.mint(
      community: communityDid,
      vetter: member.personaDid,
      validity: vettingTicketValidity,
      now: now,
    );
    final desk =
        await _repository.findVetterDesk(communityDid) ??
        VtcVetterDesk(communityDid: communityDid);
    await _repository.saveVetterDesk(desk.withTicket(ticket, now));
    return ticket;
  }

  /// Cancels every ticket the member showed for [communityDid], so none
  /// admits an applicant any more; sessions already open stay open.
  /// Returns the desk, or null when there is none.
  Future<VtcVetterDesk?> cancelVettingTickets(String communityDid) async {
    final desk = await _repository.findVetterDesk(communityDid);
    if (desk == null || desk.tickets.isEmpty) return desk;
    final cancelled = desk.withoutTickets();
    await _repository.saveVetterDesk(cancelled);
    return cancelled;
  }

  /// Picks up what applicants sent the member, as a vetter for
  /// [communityDid], and moves each session on: accepts a request for a
  /// live ticket and opens its session at once, asking for the details the
  /// community requires; checks a card; and ends a session the applicant
  /// declined. Returns the desk, or null when there is none.
  ///
  /// A card is kept in memory, and its message in the inbox, until the
  /// session ends; one that fails a check, and anything that belongs to no
  /// open session, is dropped.
  ///
  /// The details asked for are [requiredClaims] when given, as
  /// [vettingClaimsOf] reads them from requirements already known; else
  /// they are read from the community. Each step of taking a request is
  /// reported to [onRequestStep] as it starts.
  ///
  /// Throws as [canVet] does.
  Future<VtcVetterDesk?> checkVetterDesk(
    String communityDid, {
    List<String>? requiredClaims,
    void Function(VtcRequestStep step)? onRequestStep,
  }) async {
    var desk = await _repository.findVetterDesk(communityDid);
    final member = await _repository.findCommunity(communityDid);
    if (desk == null || member == null) return desk;
    final (vta, collection, vetter) = await _vetter(member);
    await collection.inbox.open();
    final received = await collection.inbox.peerDocuments(
      types: VettingTask.toVetter,
    );

    final handled = <String>[];
    for (final peer in received) {
      final document = peer.document;
      if (document.type == VettingTask.request) {
        // A request already taken, whose message could not be removed, is
        // not taken again.
        final taken = desk!.sessions.any(
          (session) => session.request.requestDocumentId == document.id,
        );
        if (!taken) {
          desk = await _takeRequest(
            vta,
            member,
            vetter,
            desk,
            document,
            requiredClaims:
                requiredClaims ?? await _vettingClaims(member.communityDid),
            onStep: onRequestStep,
          );
        }
        handled.add(peer.messageId);
        continue;
      }
      final open = desk!.sessions.where((session) => session.isOpen);
      if (open
              .where(
                (session) => vetter.isDeclinedBy(document, session.request),
              )
              .firstOrNull
          case final session?) {
        desk = desk.withSession(session.ended());
        _forgetCard(session.request.requestId);
        handled.add(peer.messageId);
        continue;
      }
      final session = open
          .map((session) => session.session)
          .where((session) => session?.document.id == document.threadId)
          .firstOrNull;
      final held = session == null
          ? null
          : _vettingCards[session.request.requestId];
      if (held != null && held.$1 == peer.messageId) continue;
      if (session == null || held != null) {
        handled.add(peer.messageId);
        continue;
      }
      try {
        if (await vetter.receiveCard(document, session: session)
            case final card?) {
          _vettingCards[session.request.requestId] = (peer.messageId, card);
          continue;
        }
      } on VettingCardException {
        // Dropped: the applicant may send another.
      }
      handled.add(peer.messageId);
    }
    await _repository.saveVetterDesk(desk!);
    await _removeFromInbox(collection, handled);
    return desk;
  }

  /// The card the applicant of [requestId] sent, as checked, or null while
  /// none has arrived. Its details are shown for the session only.
  ReceivedVettingCard? vettingCard(String requestId) =>
      _vettingCards[requestId]?.$2;

  /// Records that the member, as a vetter for [communityDid], confirmed with
  /// the applicant present that the match codes of [requestId] match.
  Future<VtcVetterDesk> confirmVettingMatch(
    String communityDid,
    String requestId,
  ) async {
    final (desk, session) = await _vetterSessionOf(communityDid, requestId);
    final updated = desk.withSession(session.confirmed());
    await _repository.saveVetterDesk(updated);
    return updated;
  }

  /// Issues the applicant of [requestId] a vetting statement signed by the
  /// member's VTA as their identity in [communityDid]: the vetter checked
  /// the card's details in person against [documentClasses]. The VTA keeps
  /// a record of it.
  ///
  /// Throws [StateError] before the card arrived or the match codes were
  /// confirmed, and [MeetingPlaceVtcSDKException] when the VTA will not sign
  /// or keep it, or the applicant cannot be reached.
  Future<VtcVetterDesk> issueVettingStatement(
    String communityDid,
    String requestId, {
    required List<String> documentClasses,
  }) async {
    final (desk, session) = await _vetterSessionOf(communityDid, requestId);
    final card = _vettingCards[requestId];
    final opened = session.session;
    if (card == null || opened == null) throw StateError('no card received');
    final member = (await _repository.findCommunity(communityDid))!;
    final (_, collection, vetter) = await _vetter(member);
    final issued = await vetter.issue(
      opened,
      card: card.$2,
      matchConfirmed: session.matchConfirmed,
      documentClasses: documentClasses,
    );
    final updated = desk.withSession(session.issued(issued.statementId));
    await _repository.saveVetterDesk(updated);
    _forgetCard(requestId);
    await _removeFromInbox(collection, [card.$1]);
    return updated;
  }

  /// Tells the applicant of [requestId] the member, as a vetter for
  /// [communityDid], will not vouch for them, with a [code] such as
  /// `couldNotVerify` or `notComfortable`.
  ///
  /// Throws [MeetingPlaceVtcSDKException] when the applicant cannot be
  /// reached.
  Future<VtcVetterDesk> declineVetting(
    String communityDid,
    String requestId, {
    String? code,
    String? message,
  }) async {
    final (desk, session) = await _vetterSessionOf(communityDid, requestId);
    final member = (await _repository.findCommunity(communityDid))!;
    final (_, collection, vetter) = await _vetter(member);
    await vetter.decline(session.request, code: code, message: message);
    final updated = desk.withSession(session.declined());
    await _repository.saveVetterDesk(updated);
    final card = _vettingCards[requestId];
    _forgetCard(requestId);
    await _removeFromInbox(collection, [?card?.$1]);
    return updated;
  }

  /// The statements the member issued as a vetter for [communityDid], as
  /// their VTA records them, newest first, also those issued from another
  /// phone.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA cannot be reached.
  Future<List<IssuedVettingStatement>> issuedVettingStatements(
    String communityDid,
  ) async {
    final member = await _repository.findCommunity(communityDid);
    if (member == null || !member.isMember) return const [];
    final (_, _, vetter) = await _vetter(member);
    return vetter.issuedStatements();
  }

  /// [desk] after the applicant's [request]: accepted for a live ticket,
  /// its session opened, or as it was when refused or left unanswered.
  Future<VtcVetterDesk> _takeRequest(
    VtaClient vta,
    VtcCommunity member,
    VettingVetter vetter,
    VtcVetterDesk desk,
    TrustTaskDocument request, {
    required List<String> requiredClaims,
    void Function(VtcRequestStep step)? onStep,
  }) async {
    final now = clock.now();
    onStep?.call(VtcRequestStep.checkingCard);
    final taken = await vetter.takeRequest(
      request,
      tickets: desk.liveTickets(now),
      roleCard: await _vetterCard(vta, member),
    );
    final accepted = taken?.accepted;
    final ticket = taken?.ticket;
    if (accepted == null || ticket == null) return desk;
    onStep?.call(VtcRequestStep.openingSession);
    final session = await vetter.openSession(
      accepted,
      requiredClaims: requiredClaims,
    );
    return desk
        .withTicket(ticket, now)
        .withSession(VtcVetterSession(request: accepted).opened(session));
  }

  /// What [communityDid]'s join manifest asks of vetting: that of its first
  /// way in by vetting, or null when none asks for vetting.
  ///
  /// Throws [MeetingPlaceVtcSDKException] when the community cannot be
  /// reached.
  Future<VettingRequirements?> vettingRequirements(String communityDid) async {
    final manifest = await _sdk.joinClient().readManifest(communityDid);
    return manifest.criteria
        .map((criterion) => criterion.vetting)
        .whereType<VettingRequirements>()
        .firstOrNull;
  }

  /// The details [communityDid] asks vetters to check, as
  /// [vettingClaimsOf] reads them.
  Future<List<String>> _vettingClaims(String communityDid) async =>
      vettingClaimsOf(await vettingRequirements(communityDid));

  /// The details [requirements] ask vetters to check, or the legal name.
  static List<String> vettingClaimsOf(VettingRequirements? requirements) {
    final claims = requirements?.requiredClaims;
    return claims == null || claims.isEmpty ? const [_legalName] : claims;
  }

  static const _legalName = 'name.legal';

  /// The member's vetter role card for [member]'s community, in date and
  /// not revoked, or null.
  Future<Map<String, dynamic>?> _vetterCard(
    VtaClient vta,
    VtcCommunity member,
  ) => _sdk
      .communityImport(vta)
      .vetterCard(
        member.communityDid,
        personaDid: member.personaDid,
        statusList: _sdk.statusListClient(),
        now: clock.now(),
      );

  /// The VTA, the identity's lent keys and inbox, and the vetter's side of
  /// vetting as that identity, for [member]'s community.
  Future<(VtaClient, _CardCollection, VettingVetter)> _vetter(
    VtcCommunity member,
  ) async {
    final vta = await _grantedVta();
    final collection = await _collection(vta, member);
    return (
      vta,
      collection,
      _sdk.vettingVetter(
        communityDid: member.communityDid,
        persona: _persona(member),
        personaKeys: collection.keys,
        vta: vta,
      ),
    );
  }

  Future<(VtcVetterDesk, VtcVetterSession)> _vetterSessionOf(
    String communityDid,
    String requestId,
  ) async {
    final desk = await _repository.findVetterDesk(communityDid);
    final session = desk?.sessionFor(requestId);
    if (desk == null || session == null || !session.isOpen) {
      throw StateError('no open vetting session');
    }
    return (desk, session);
  }

  void _forgetCard(String requestId) => _vettingCards.remove(requestId);

  static Future<void> _removeFromInbox(
    _CardCollection collection,
    List<String> messageIds,
  ) async {
    try {
      await collection.inbox.remove(messageIds);
    } on MeetingPlaceVtcSDKException {
      // Read again next time, and recognised as already handled.
    }
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
  /// Looking for the card on the VTA first is reported to [onCardStep].
  ///
  /// Returns null when no application is open. Throws as [join] does.
  Future<JoinStatus?> checkApplication(
    String communityDid, {
    void Function(VtcCardDelivery delivery)? onCardDelivery,
    void Function(MembershipCardStep step)? onCardStep,
  }) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null) return null;
    if (community.isMember && !community.isSettled) {
      await _settleFromVta(
        await _grantedVta(),
        community,
        requestId: null,
        onCardDelivery: onCardDelivery,
        onCardStep: onCardStep,
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
          onCardStep: onCardStep,
        );
      case JoinRequestStatus.rejected || JoinRequestStatus.withdrawn:
        await _repository.saveCommunity(community.rejected(status.reason));
      case JoinRequestStatus.pending || JoinRequestStatus.deferred:
        break;
    }
    return status;
  }

  /// Checks every open application, completes every admission still to
  /// settle and refreshes every settled membership not refreshed for a
  /// while, e.g. when the app comes to the foreground: a community decides
  /// on its own time, and may change the member's role. A community that
  /// cannot be reached is left for the next check. Does nothing while no
  /// VTA is linked.
  Future<void> checkApplications() async {
    final linkedVta = await _repository.getLinkedVta();
    if (linkedVta == null || !linkedVta.isGranted) return;
    for (final community in await _repository.communities()) {
      if (community.isMember && community.isSettled) {
        await _refreshWhenDue(community.communityDid);
        continue;
      }
      if (!community.isApplying && !community.isMember) continue;
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
  /// and kept on the VTA, each step reported to [onCardDelivery], and
  /// looking for it on the VTA to [onCardStep]. When
  /// neither holds it yet, asks the community to deliver it again and
  /// leaves the admission to settle at the next check.
  Future<void> _settleFromVta(
    VtaClient vta,
    VtcCommunity member, {
    required String? requestId,
    void Function(VtcCardDelivery delivery)? onCardDelivery,
    void Function(MembershipCardStep step)? onCardStep,
  }) async {
    final report = _DeliveryReport(member.personaDid, onCardDelivery);
    final card =
        await _sdk
            .communityImport(vta)
            .membershipCard(
              member.communityDid,
              personaDid: member.personaDid,
              onStep: onCardStep,
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
      card: membership.credential,
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

  /// The groups of the community [communityDid] the member belongs to, as
  /// the community shows them to the member's identity there.
  ///
  /// Throws [NotACommunityMemberException] when the phone holds no
  /// membership of [communityDid], [VtaNotLinkedException] when no VTA is
  /// linked, and [MeetingPlaceVtcSDKException] when the VTA or the community
  /// refuses or cannot be reached.
  Future<List<VtcGroupListing>> memberGroups(String communityDid) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.groupsClient().list(
      communityDid,
      agent: vta,
      persona: signer,
      mine: true,
    );
  }

  /// The group [groupId] of the community [communityDid], with its managers
  /// when the member is one. Throws as [memberGroups] does.
  Future<VtcGroupListing> communityGroup(
    String communityDid, {
    required String groupId,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.groupsClient().show(
      communityDid,
      groupId: groupId,
      agent: vta,
      persona: signer,
    );
  }

  /// The members of the group [groupId] that the community shows the
  /// member, with their credentials' ids when the member manages it.
  /// Throws as [memberGroups] does.
  Future<List<VtcGroupMember>> groupMembers(
    String communityDid, {
    required String groupId,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.groupsClient().members(
      communityDid,
      groupId: groupId,
      agent: vta,
      persona: signer,
    );
  }

  /// The members of [communityDid] whose directory entries match [query],
  /// as the community shows them to the member. Throws as [memberGroups]
  /// does.
  Future<List<DirectoryEntry>> searchMembers(
    String communityDid, {
    required String query,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.directoryClient().search(
      communityDid,
      agent: vta,
      persona: signer,
      query: query,
    );
  }

  /// The directory entry [entryId] of [communityDid] as the community shows
  /// it to the member, or null when it shows none. Throws as [memberGroups]
  /// does.
  Future<DirectoryEntry?> memberEntry(
    String communityDid, {
    required String entryId,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.directoryClient().show(
      communityDid,
      agent: vta,
      persona: signer,
      entryId: entryId,
    );
  }

  /// The member's own directory card in [communityDid]: whether other
  /// members can find them to vouch for them. Throws as [memberGroups]
  /// does.
  Future<MyDirectoryCard> myDirectoryCard(String communityDid) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.directoryClient().myCard(
      communityDid,
      agent: vta,
      persona: signer,
    );
  }

  /// Lets every member of [communityDid] find the member's identity there
  /// when [findable], to vouch for them, or keeps it to the community's
  /// administrators otherwise. Throws as [memberGroups] does.
  Future<void> setFindableByMembers(
    String communityDid, {
    required bool findable,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    await _sdk.directoryClient().setDidVisibleToMembers(
      communityDid,
      agent: vta,
      persona: signer,
      visible: findable,
    );
  }

  /// Sets the name other members of [communityDid] see for the member to
  /// [name], or clears it when [name] is blank. Throws as [memberGroups]
  /// does.
  Future<void> setDirectoryName(
    String communityDid, {
    required String name,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    await _sdk.directoryClient().setDisplayName(
      communityDid,
      agent: vta,
      persona: signer,
      name: name,
    );
  }

  /// Shows [jpeg] to every member of [communityDid] as the member's picture
  /// there, or takes the picture off when null. Throws as [memberGroups]
  /// does.
  Future<void> setDirectoryPicture(
    String communityDid, {
    required Uint8List? jpeg,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    final client = _sdk.directoryClient();
    final image = jpeg == null
        ? null
        : await client.uploadImage(
            communityDid,
            agent: vta,
            persona: signer,
            bytes: jpeg,
            mediaType: 'image/jpeg',
          );
    await client.setAvatar(
      communityDid,
      agent: vta,
      persona: signer,
      image: image,
    );
  }

  /// The picture the member of entry [entryId] of [communityDid] shows the
  /// member, the one [sha256] names, or null when they show none. Throws as
  /// [memberGroups] does.
  Future<Uint8List?> memberPicture(
    String communityDid, {
    required String entryId,
    required String sha256,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.directoryClient().avatar(
      communityDid,
      agent: vta,
      persona: signer,
      entryId: entryId,
      sha256: sha256,
    );
  }

  /// Has the member's VTA vouch, as their identity in [communityDid], for
  /// the member [subjectDid], and the community keep it in its trust graph.
  /// Throws as [memberGroups] does.
  Future<PublishedRelationship> publishRelationship(
    String communityDid, {
    required String subjectDid,
  }) async {
    final community = await _memberCommunity(communityDid);
    final vta = await _grantedVta();
    return _sdk.relationshipsClient().publish(
      communityDid,
      agent: vta,
      persona: _persona(community),
      signer: await _personaSigner(vta, community),
      subjectDid: subjectDid,
    );
  }

  /// Every vouch in [communityDid]'s trust graph the member's identity
  /// there is a party to, either way round. Throws as [memberGroups] does.
  Future<List<PublishedRelationship>> relationshipsOf(
    String communityDid,
  ) async {
    final community = await _memberCommunity(communityDid);
    final vta = await _grantedVta();
    return _sdk.relationshipsClient().list(
      communityDid,
      agent: vta,
      persona: await _personaSigner(vta, community),
      did: community.personaDid,
    );
  }

  /// Every vouch in [communityDid]'s trust graph naming the member [did],
  /// either way round, as the community shows it to the member. Throws as
  /// [memberGroups] does.
  Future<List<PublishedRelationship>> relationshipsNaming(
    String communityDid, {
    required String did,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.relationshipsClient().list(
      communityDid,
      agent: vta,
      persona: signer,
      did: did,
    );
  }

  /// The external card the member of directory entry [entryId] published
  /// in [communityDid], as they signed it, or null when they published
  /// none. Throws as [memberGroups] does.
  Future<Map<String, dynamic>?> memberPublicCard(
    String communityDid, {
    required String entryId,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.directoryClient().publicCard(
      communityDid,
      agent: vta,
      persona: signer,
      entryId: entryId,
    );
  }

  /// The membership pair [communityDid] holds for the member [did], or null
  /// when [did] is no member. Only an administrator who manages members may
  /// read it; anyone else is refused. Throws as [memberGroups] does.
  Future<MemberCredentials?> memberCredentials(
    String communityDid, {
    required String did,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    return _sdk.joinClient().memberCredentials(
      communityDid,
      agent: vta,
      persona: signer,
      did: did,
    );
  }

  /// Withdraws the member's vouch [id] from [communityDid]'s trust graph.
  /// One that is gone already counts as withdrawn. Throws as
  /// [memberGroups] does.
  Future<void> withdrawRelationship(
    String communityDid, {
    required String id,
  }) async {
    final (vta, signer) = await _asMember(communityDid);
    await _sdk.relationshipsClient().revoke(
      communityDid,
      agent: vta,
      persona: signer,
      id: id,
    );
  }

  /// Picks up the credentials the groups [groupDids] of [communityDid]
  /// issued to the member's identity from its inbox, keeps them on the VTA,
  /// and only then removes them from the inbox. Returns how many it kept.
  ///
  /// The community delivers a group's credentials once, when it admits the
  /// member or renews them. Throws as [memberGroups] does.
  Future<int> collectGroupCredentials(
    String communityDid, {
    required Set<String> groupDids,
  }) async {
    if (groupDids.isEmpty) return 0;
    final community = await _memberCommunity(communityDid);
    final vta = await _grantedVta();
    final collection = await _collection(vta, community);
    await collection.inbox.open();
    final pickup = await collection.inbox.groupCredentials(
      communityDid: communityDid,
      groupDids: groupDids,
    );
    await _keepCards(vta, [
      for (final issued in pickup.credentials) issued.credential,
    ], community.contextId);
    try {
      await collection.inbox.remove([
        for (final issued in pickup.credentials) issued.messageId,
      ]);
    } on MeetingPlaceVtcSDKException {
      // Kept all the same; a copy left behind is kept again by its id.
    }
    return pickup.credentials.length;
  }

  /// Whether the member's VTA keeps a valid credential of the group
  /// [groupDid] of [communityDid] for the member's identity there. Throws
  /// as [memberGroups] does.
  Future<bool> holdsGroupCredential(
    String communityDid, {
    required String groupDid,
  }) async {
    final community = await _memberCommunity(communityDid);
    final held = await (await _grantedVta()).findCredentials(
      type: GroupAdmissionVerifier.membershipType,
      issuerDid: groupDid,
      subjectDid: community.personaDid,
    );
    return held.isNotEmpty;
  }

  /// Has the member's VTA prove to the chat of the group [groupDid] of
  /// [communityDid] that the member belongs to the group, bound to
  /// [memberDid], the DID the member joins the chat as. Null when the VTA
  /// keeps no valid credential of the group for the member's identity.
  /// Throws as [memberGroups] does.
  Future<GroupJoinProof?> proveGroupMembership(
    String communityDid, {
    required String groupDid,
    required String memberDid,
  }) async {
    final community = await _memberCommunity(communityDid);
    return GroupJoinProof.prove(
      await _grantedVta(),
      groupDid: groupDid,
      communityDid: communityDid,
      personaDid: community.personaDid,
      memberDid: memberDid,
    );
  }

  /// The chat the community linked to its group [groupDid], or null when
  /// it linked none. Throws when the group's DID cannot be resolved.
  Future<GroupChatLink?> groupChatLink(String groupDid) =>
      _sdk.groupChatLink(groupDid);

  /// Checks that [proof] admits [memberDid] to the chat of the group
  /// [groupDid] of [communityDid], offline but for the community's status
  /// list. Throws [GroupAdmissionException] when it does not.
  Future<GroupAdmission> verifyGroupJoin(
    GroupJoinProof proof, {
    required String communityDid,
    required String groupDid,
    required String memberDid,
  }) => _sdk.groupAdmissionVerifier().verify(
    presentation: proof.presentation,
    authority: proof.authority,
    groupDid: groupDid,
    communityDid: communityDid,
    memberDid: memberDid,
  );

  /// The member's VTA, and their identity's signer in [communityDid].
  Future<(VtaClient, SignInPersona)> _asMember(String communityDid) async {
    final community = await _memberCommunity(communityDid);
    final vta = await _grantedVta();
    return (vta, await _personaSigner(vta, community));
  }

  /// The community [communityDid], which the phone holds a membership of.
  Future<VtcCommunity> _memberCommunity(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null || !community.isMember) {
      throw const NotACommunityMemberException();
    }
    return community;
  }

  /// Signs out of the identity's inbox for [communityDid] and forgets the
  /// keys the VTA lent for it, e.g. when the screen collecting the card
  /// closes. Does nothing when none are held.
  Future<void> endCardCollection(String communityDid) async {
    await _collections.remove(communityDid)?.end();
  }

  /// Asks [communityDid] for the member's current cards, and keeps them on
  /// their VTA when the role there changed, e.g. after an administrator
  /// promoted them: the card the community pushes on a role change may
  /// never reach the VTA. A kept change fires [membershipsChanged]. The
  /// renewed membership card is confirmed back to the community, as on
  /// admission, best effort.
  ///
  /// Does nothing for a community this phone knows no membership of, or
  /// when the community no longer counts the persona as a member.
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA or the community refuses or
  /// cannot be reached.
  Future<void> refreshMembership(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null || !community.isMember) return;
    final vta = await _grantedVta();
    final signer = await _personaSigner(vta, community);
    final client = _sdk.joinClient();
    final cards = await client.renew(communityDid, agent: vta, persona: signer);
    _refreshedAt[communityDid] = DateTime.now();
    if (cards == null) return;

    // A renewed card is a new one: the member's confirmation names the card
    // by its digest, so the earlier one no longer completes the membership.
    try {
      await client.confirmMembership(
        communityDid,
        agent: vta,
        persona: _persona(community),
        signer: signer,
        communityCard: cards.membership,
      );
    } on MeetingPlaceVtcSDKException {
      // The community holds the membership either way; the next renewal
      // confirms it again.
    }

    final personaDid = community.personaDid;
    final heldRole = await _sdk
        .communityImport(vta)
        .role(communityDid, personaDid: personaDid);
    // Unchanged: keeping the new cards would only fill the VTA's vault.
    if (CommunityImport.roleOf(cards.role, communityDid, personaDid) ==
        heldRole) {
      return;
    }
    await _keepCards(vta, cards.credentials, community.contextId);
    _membershipsChanged.add(null);
  }

  /// Refreshes [communityDid]'s membership unless it was refreshed within
  /// [_refreshInterval]. A community that cannot be reached is left for the
  /// next check.
  Future<void> _refreshWhenDue(String communityDid) async {
    final refreshedAt = _refreshedAt[communityDid];
    if (refreshedAt != null &&
        DateTime.now().difference(refreshedAt) < _refreshInterval) {
      return;
    }
    try {
      await refreshMembership(communityDid);
    } on MeetingPlaceVtcSDKException {
      return;
    }
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
    // A vouch there now names nobody the member can act as.
    await _repository.removeMemberLinks(communityDid);
    await _repository.removeCommunity(communityDid);
    _membershipsChanged.add(null);
  }

  /// The membership card [communityDid] issued to the member's persona
  /// there, as their VTA keeps it, or null when this phone knows no such
  /// membership or the VTA holds no card yet, e.g. while the community has
  /// still to deliver it. Each step of finding it on the VTA is reported to
  /// [onStep] as it starts.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA cannot be reached.
  Future<VtcMembershipCard?> membershipCard(
    String communityDid, {
    void Function(MembershipCardStep step)? onStep,
  }) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null || !community.isMember) return null;
    final card = await _sdk
        .communityImport(await _grantedVta())
        .membershipCard(
          communityDid,
          personaDid: community.personaDid,
          onStep: onStep,
        );
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

  /// Keeps [cards] on the VTA, and returns those it kept. A card that is
  /// not kept is skipped: the community holds the membership either way,
  /// and only another app of the member cannot import it.
  static Future<List<Map<String, dynamic>>> _keepCards(
    VtaClient vta,
    List<Map<String, dynamic>> cards,
    String contextId,
  ) async {
    final kept = <Map<String, dynamic>>[];
    for (final card in cards) {
      try {
        await vta.keepCredential(card, contextId: contextId);
        kept.add(card);
      } on MeetingPlaceVtcSDKException {
        continue;
      }
    }
    return kept;
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
    Map<String, dynamic>? card,
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
      card: card,
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
