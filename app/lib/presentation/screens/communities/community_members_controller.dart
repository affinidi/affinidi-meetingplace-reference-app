import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';

part 'community_members_controller.g.dart';

/// The members of a community the member sees without searching, with the
/// vouches between them and the member by that member's DID.
typedef CommunityMembers = (
  List<DirectoryEntry> members,
  Map<String, VtcEdges> edges,
);

/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens.
@Riverpod(keepAlive: true)
class CommunityMembersController extends _$CommunityMembersController {
  var _isSyncing = false;

  @override
  Future<CommunityMembers> build(String communityDid) => _read();

  /// Reads the members again, keeping those shown until the community
  /// answers. A failure keeps them too: they are only out of date. Nothing
  /// happens while they are being read already.
  Future<void> sync() async {
    if (state.isLoading || _isSyncing) return;
    _isSyncing = true;
    try {
      final members = await _read();
      if (ref.mounted) state = AsyncData(members);
    } on VtcTrustException catch (error, stackTrace) {
      if (ref.mounted && !state.hasValue) {
        state = AsyncError(error, stackTrace);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<CommunityMembers> _read() async {
    final service = ref.read(vtcTrustServiceProvider);
    return (
      await service.communityMembers(communityDid),
      await service.edgesByMember(communityDid),
    );
  }
}
