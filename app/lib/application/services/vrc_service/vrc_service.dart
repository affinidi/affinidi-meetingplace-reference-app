import 'dart:async';

import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/vrc/vrc_credential.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/credentials_sdk_provider.dart';

part 'vrc_service.g.dart';

/// Service that manages Verifiable Relationship Credentials (VRC).
///
/// Responsibilities:
/// - Exposes all stored [VrcCredential]s as live state for the UI.
/// - Provides methods to save, delete, and query VRCs.
@Riverpod(keepAlive: true)
class VrcService extends _$VrcService {
  static const _logKey = 'VRCSVC';

  var _disposed = false;

  late final AppLogger _logger = ref.read(appLoggerProvider);

  @override
  List<VrcCredential> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    unawaited(Future(_init));

    return const [];
  }

  Future<void> _init() async {
    if (_disposed) return;
    await _fetchVrcs();
  }

  Future<void> _fetchVrcs() async {
    if (_disposed) return;
    final credentialsSdk = await ref.read(credentialsSdkProvider.future);
    if (_disposed) return;
    final vrcs = await credentialsSdk.listVrcs();
    if (_disposed) return;
    state = vrcs.map(_toVrcCredential).toList();
  }

  Future<void> saveVrc(String rawVc, String referenceId) async {
    final credentialsSdk = await ref.read(credentialsSdkProvider.future);
    try {
      await credentialsSdk.storeVrc(
        vcBlob: rawVc,
        referenceId: referenceId,
        verifiedAt: DateTime.now(),
      );
      state = (await credentialsSdk.listVrcs()).map(_toVrcCredential).toList();
    } on MeetingPlaceCredentialsSDKException catch (error, stackTrace) {
      _logger.error(
        'Skipping VRC storage: $error',
        name: _logKey,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> deleteVrc(String id) async {
    final credentialsSdk = await ref.read(credentialsSdkProvider.future);
    await credentialsSdk.deleteVrc(id);
    state = (await credentialsSdk.listVrcs()).map(_toVrcCredential).toList();
  }

  Future<List<VrcCredential>> listVrcsByDid(String did) async {
    final credentialsSdk = await ref.read(credentialsSdkProvider.future);
    final vrcs = await credentialsSdk.listVrcsByHolderDid(did);
    return vrcs.map(_toVrcCredential).toList();
  }

  Future<int> countVrcsByDid(String did) async {
    final credentialsSdk = await ref.read(credentialsSdkProvider.future);
    return credentialsSdk.countVrcsByHolderDid(did);
  }

  Future<bool> hasVrcInChannel(String? channelId) async {
    if (channelId == null) return false;
    final credentialsSdk = await ref.read(credentialsSdkProvider.future);
    final vrcs = await credentialsSdk.listVrcs();
    return vrcs.any((v) => v.referenceId == channelId);
  }

  VrcCredential _toVrcCredential(Vrc vrc) => VrcCredential(
    id: vrc.id,
    vc: vrc.vcBlob,
    channelId: vrc.referenceId,
    holderIdentityDid: vrc.holderDid,
    issuerIdentityDid: vrc.issuerDid,
    issuedAt: vrc.issuedAt,
    verifiedAt: vrc.verifiedAt,
  );
}
