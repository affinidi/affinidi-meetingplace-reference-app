import 'dart:async';

import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/vrc/vrc_credential.dart';
import '../../../infrastructure/providers/relationship_sdk_provider.dart';
import 'vrc_event.dart';

part 'vrc_service.g.dart';

/// Service that manages Verifiable Relationship Credentials (VRC).
///
/// Responsibilities:
/// - Exposes all stored [VrcCredential]s as live state for the UI.
/// - Provides methods to save, delete, and query VRCs.
/// - Emits [VrcEvent]s on a broadcast stream for interested listeners.
@Riverpod(keepAlive: true)
class VrcService extends _$VrcService {
  final _eventController = StreamController<VrcEvent>.broadcast();

  Stream<VrcEvent> get events => _eventController.stream;

  @override
  List<VrcCredential> build() {
    unawaited(Future(_init));

    ref.onDispose(_eventController.close);

    return const [];
  }

  Future<void> _init() async {
    await _fetchVrcs();
  }

  Future<void> _fetchVrcs() async {
    final relationshipSdk = await ref.read(relationshipSdkProvider.future);
    final vrcs = await relationshipSdk.listVrcs();
    state = vrcs.map(_toVrcCredential).toList();
  }

  Future<void> saveVrc(String rawVc, String channelId) async {
    final relationshipSdk = await ref.read(relationshipSdkProvider.future);
    final vrc = await relationshipSdk.storeVrc(
      vcBlob: rawVc,
      channelId: channelId,
      verifiedAt: DateTime.now(),
    );

    if (vrc == null) return;

    final credential = _toVrcCredential(vrc);

    state = (await relationshipSdk.listVrcs()).map(_toVrcCredential).toList();

    _eventController.add(VrcReceived(credential: credential));
  }

  Future<void> deleteVrc(String id) async {
    final relationshipSdk = await ref.read(relationshipSdkProvider.future);
    await relationshipSdk.deleteVrc(id);
    state = (await relationshipSdk.listVrcs()).map(_toVrcCredential).toList();
  }

  Future<List<VrcCredential>> listVrcsByDid(String did) async {
    final relationshipSdk = await ref.read(relationshipSdkProvider.future);
    final vrcs = await relationshipSdk.listVrcsByHolderDid(did);
    return vrcs.map(_toVrcCredential).toList();
  }

  Future<int> countVrcsByDid(String did) async {
    final relationshipSdk = await ref.read(relationshipSdkProvider.future);
    return relationshipSdk.countVrcsByHolderDid(did);
  }

  Future<bool> hasVrcInChannel(String? channelId) async {
    if (channelId == null) return false;
    final relationshipSdk = await ref.read(relationshipSdkProvider.future);
    final vrcs = await relationshipSdk.listVrcs();
    return vrcs.any((v) => v.channelId == channelId);
  }

  VrcCredential _toVrcCredential(Vrc vrc) => VrcCredential(
    id: vrc.id,
    vc: vrc.vcBlob,
    channelId: vrc.channelId,
    holderIdentityDid: vrc.holderDid,
    issuerIdentityDid: vrc.issuerDid,
    issuedAt: vrc.issuedAt,
    verifiedAt: vrc.verifiedAt,
  );
}
