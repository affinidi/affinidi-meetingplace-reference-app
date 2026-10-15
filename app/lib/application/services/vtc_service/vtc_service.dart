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
/// VTA's administrator grants it; the phone then confirms the grant and
/// enrols its biometric approval key as a device.
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
  /// Throws [InvalidVtaDidException] when [vtaDid] is not a DID.
  Future<String> startLink(String vtaDid) async {
    final did = vtaDid.trim();
    if (!_isDid(did)) throw const InvalidVtaDidException();
    final manager = _sdk.newManagerKey();
    _client = null;
    await _repository.clear();
    await _repository.saveLinkedVta(
      LinkedVta(vtaDid: did, managerSeed: manager.seed, isGranted: false),
    );
    return manager.did;
  }

  /// The manager DID of the pending or completed link, or null.
  Future<String?> managerDid() async {
    final linkedVta = await _repository.getLinkedVta();
    if (linkedVta == null) return null;
    return Ed25519DidKeySigner.fromSeed(linkedVta.managerSeed).did;
  }

  /// Checks whether the VTA granted the manager key and, once it has,
  /// enrols the biometric approval key with the VTA.
  ///
  /// Returns false while the grant is missing. Throws
  /// [MeetingPlaceVtcSDKException] when the VTA cannot be reached.
  Future<bool> confirmLink() async {
    final linkedVta = await _repository.getLinkedVta();
    if (linkedVta == null) return false;

    final vta = _vtaClient(linkedVta);
    if (!await VtaLink.isGranted(vta)) return false;

    await vta.enrolUserVerificationKey(
      uvDid: await _userVerificationKey.ensureKey(),
      displayName: _deviceName,
      platform: _platform,
    );
    await _repository.saveLinkedVta(linkedVta.granted());
    return true;
  }

  /// Forgets the VTA link, the communities and the approval key.
  Future<void> unlink() async {
    _client = null;
    await _repository.clear();
    await _userVerificationKey.reset();
  }

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
    if (!_isDid(did)) throw const InvalidCommunityCodeException();
    return _sdk.joinClient().readManifest(did);
  }

  /// Applies to join [manifest]'s community as a persona of the member's
  /// VTA, and records the outcome.
  ///
  /// The VTA creates the persona on the first application to a community;
  /// a later one applies as the same persona. Once admitted, the issued
  /// cards are kept on the VTA, where other apps of the member find them.
  ///
  /// Throws [VtaNotLinkedException] when no VTA is linked, and
  /// [MeetingPlaceVtcSDKException] when the VTA or the community refuses or
  /// cannot be reached.
  Future<JoinVerdict> join(JoinManifest manifest) async {
    final vta = await _grantedVta();
    var community = await _repository.findCommunity(manifest.communityDid);
    if (community == null) {
      final persona = await vta.createPersona(
        label: manifest.name ?? manifest.communityDid,
      );
      community = VtcCommunity(
        communityDid: manifest.communityDid,
        personaDid: persona.did,
        contextId: persona.contextId,
        name: manifest.name,
        signingKeyId: persona.signingKeyId,
        isMember: false,
      );
      // Kept before applying, so that a retry applies as the same persona.
      await _repository.saveCommunity(community);
    }

    final verdict = await _sdk.joinClient().apply(
      manifest,
      agent: vta,
      persona: await _personaSigner(vta, community),
    );
    switch (verdict) {
      case JoinAdmitted(:final credentials):
        await _repository.saveCommunity(
          community.withApplication(isMember: true),
        );
        await _keepCards(vta, credentials, community.contextId);
      case JoinPending(:final requestId):
        await _repository.saveCommunity(
          community.withApplication(isMember: false, requestId: requestId),
        );
      case JoinDenied() || JoinNeedsMore():
        await _repository.saveCommunity(
          community.withApplication(isMember: false),
        );
    }
    return verdict;
  }

  /// Asks where the open application to [communityDid] stands, and records
  /// the community's decision once it has made one.
  ///
  /// Returns null when no application is open. Throws as [join] does.
  Future<JoinRequestStatus?> checkApplication(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    final requestId = community?.joinRequestId;
    if (community == null || !community.isApplying || requestId == null) {
      return null;
    }

    final vta = await _grantedVta();
    final status = await _sdk.joinClient().status(
      communityDid,
      requestId: requestId,
      agent: vta,
      persona: await _personaSigner(vta, community),
    );
    if (!status.isOpen) {
      await _repository.saveCommunity(
        community.withApplication(
          isMember: status == JoinRequestStatus.approved,
        ),
      );
    }
    return status;
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
