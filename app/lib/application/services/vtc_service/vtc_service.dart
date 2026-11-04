import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/linked_vta.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/repositories/vtc_repository.dart';
import '../../../infrastructure/providers/vtc_sdk_provider.dart';
import '../../../infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
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
    String? platform,
  }) : _platform = platform ?? Platform.operatingSystem;

  final MeetingPlaceVtcSDK _sdk;
  final VtcRepository _repository;
  final UserVerificationKey _userVerificationKey;
  final String _platform;
  VtaClient? _client;

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
      attributes: attributes,
    );
    switch (verdict) {
      case JoinAdmitted(:final credentials, :final membershipCard):
        final member = community.withApplication(isMember: true);
        await _repository.saveCommunity(member);
        await _keepCards(vta, credentials, community.contextId);
        await _settle(vta, member, membershipCard, verdict.requestId);
      case JoinPending(:final requestId):
        await _repository.saveCommunity(
          community.withApplication(isMember: false, requestId: requestId),
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
  Future<void> _settle(
    VtaClient vta,
    VtcCommunity member,
    Map<String, dynamic>? membershipCard,
    String? requestId,
  ) async {
    var settled = membershipCard != null;
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
        settled = false;
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
  /// Returns null when no application is open. Throws as [join] does.
  Future<JoinStatus?> checkApplication(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null) return null;
    if (community.isMember && !community.isSettled) {
      await _settleFromVta(await _grantedVta(), community, requestId: null);
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
        await _settleFromVta(vta, member, requestId: requestId);
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
      }
    }
  }

  /// Completes [member]'s admission with the membership card the community
  /// delivered to their VTA. When the VTA holds none yet, asks the
  /// community to deliver it again and leaves the admission to settle at
  /// the next check.
  Future<void> _settleFromVta(
    VtaClient vta,
    VtcCommunity member, {
    required String? requestId,
  }) async {
    final card = await _sdk
        .communityImport(vta)
        .membershipCard(member.communityDid, personaDid: member.personaDid);
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
    await _settle(vta, member, card, requestId);
  }

  /// Leaves [communityDid] as the persona the member joined it with: the
  /// community ends the membership, the VTA archives its membership cards,
  /// and this phone forgets the community. Does nothing for a community
  /// this phone does not know.
  ///
  /// A community that already counts the persona as no member is forgotten
  /// all the same. Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA or the community refuses or
  /// cannot be reached, e.g. with HTTP status 409 when the persona is the
  /// community's last administrator; the community is then kept.
  Future<void> leave(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null) return;

    final vta = await _grantedVta();
    try {
      await _sdk.joinClient().leave(
        communityDid,
        agent: vta,
        persona: await _personaSigner(vta, community),
      );
    } on MeetingPlaceVtcSDKException catch (error) {
      if (!(error.refusalCode?.endsWith(':notMember') ?? false)) rethrow;
    }
    // Else the VTA backup would offer the membership back on the next scan.
    await _sdk
        .communityImport(vta)
        .archiveMembershipCards(communityDid, personaDid: community.personaDid);
    await _repository.removeCommunity(communityDid);
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
  VtaClient _vtaClient(LinkedVta linkedVta) {
    final client = _client;
    if (client != null && client.vtaDid == linkedVta.vtaDid) return client;
    return _client = _sdk.vtaClient(
      vtaDid: linkedVta.vtaDid,
      manager: Ed25519DidKeySigner.fromSeed(linkedVta.managerSeed),
    );
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
