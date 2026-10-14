import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/linked_vta.dart';
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

/// Links Meeting Place to the member's VTA, so the phone can act for the
/// member in Verifiable Trust Communities.
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
    await _repository.clear();
    await _userVerificationKey.reset();
  }

  VtaClient _vtaClient(LinkedVta linkedVta) => _sdk.vtaClient(
    vtaDid: linkedVta.vtaDid,
    manager: Ed25519DidKeySigner.fromSeed(linkedVta.managerSeed),
  );
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
