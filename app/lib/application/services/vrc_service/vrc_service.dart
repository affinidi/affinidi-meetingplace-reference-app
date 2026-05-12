import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/vrc/vrc_credential.dart';
import '../../../infrastructure/providers/relationship_sdk_provider.dart';
import '../../../infrastructure/providers/vrc_repository_provider.dart';
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
    final repository = await ref.read(vrcRepositoryProvider.future);
    state = await repository.listVrcs();
  }

  Future<void> saveVrc(String rawVc, String channelId) async {
    final relationshipSdk = await ref.read(relationshipSdkProvider.future);
    final repository = await ref.read(vrcRepositoryProvider.future);

    final parsed = await relationshipSdk.parseVrc(vcBlob: rawVc);

    if (parsed == null) return;

    final credential = parsed.toVrcCredential(channelId: channelId);

    await repository.saveVrc(credential);
    state = await repository.listVrcs();

    _eventController.add(VrcReceived(credential: credential));
  }

  Future<void> deleteVrc(String id) async {
    final repository = await ref.read(vrcRepositoryProvider.future);
    await repository.deleteVrc(id);
    state = await repository.listVrcs();
  }

  Future<List<VrcCredential>> listVrcsByDid(String did) async {
    final repository = await ref.read(vrcRepositoryProvider.future);
    return repository.listVrcsByDid(did);
  }

  Future<int> countVrcsByDid(String did) async {
    final repository = await ref.read(vrcRepositoryProvider.future);
    return repository.countVrcsByDid(did);
  }

  Future<bool> hasVrcInChannel(String? channelId) async {
    if (channelId == null) return false;
    final repository = await ref.read(vrcRepositoryProvider.future);
    final vrcs = await repository.listVrcs();
    return vrcs.any((v) => v.channelId == channelId);
  }
}
