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

/// Name the phone registers with on the member's VTA.
const _deviceName = 'Meeting Place';

/// Thrown when a VTC feature needs a linked, granted VTA and there is none.
class VtaNotLinkedException implements Exception {
  /// Creates a [VtaNotLinkedException].
  const VtaNotLinkedException();
}

/// Links Meeting Place to the member's VTA, and signs the member in to their
/// Verifiable Trust Communities' portals.
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
    if (!did.startsWith('did:') || did.contains(RegExp(r'\s'))) {
      throw const InvalidVtaDidException();
    }
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
        await _repository.findCommunity(vtcDid) != null,
  );

  /// The member's recorded membership of [communityDid], or null.
  Future<CommunityMembership?> recordedMembership(String communityDid) async {
    final community = await _repository.findCommunity(communityDid);
    if (community == null) return null;
    return CommunityMembership(
      communityDid: community.communityDid,
      persona: VtaPersona(
        did: community.personaDid,
        contextId: community.contextId,
      ),
      name: community.name,
    );
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
