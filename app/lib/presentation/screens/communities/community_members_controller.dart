import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';

part 'community_members_controller.g.dart';

/// The members of a community the member sees on its Members tab, with the
/// vouches between them and the member by that member's DID.
typedef CommunityMembers = (
  List<DirectoryEntry> members,
  Map<String, VtcEdges> edges,
);

/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens, and they sync when the
/// member's role there changes, which the directory shows.
@Riverpod(keepAlive: true)
class CommunityMembersController extends _$CommunityMembersController {
  var _isSyncing = false;

  @override
  Future<CommunityMembers> build(String communityDid) {
    final roleChanges = ref
        .read(vtcServiceProvider)
        .roleChanged
        .where((change) => change.communityDid == communityDid)
        .listen((_) => sync());
    ref.onDispose(roleChanges.cancel);
    return _read();
  }

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

  /// Shows [edge], the member's vouch for [personaDid], at once, without
  /// reading the vouches again.
  void vouched(String personaDid, PublishedRelationship edge) =>
      _showEdges(personaDid, (edges) => edges.vouched(edge));

  /// Shows [edges], the vouches with [personaDid] as read just now, such as
  /// when the member opened them.
  void refreshed(String personaDid, VtcEdges edges) =>
      _showEdges(personaDid, (_) => edges);

  void _showEdges(String personaDid, VtcEdges Function(VtcEdges) update) {
    // Nothing shown yet: the vouches come with the members once read.
    final value = state.value;
    if (value == null) return;
    final (members, edges) = value;
    state = AsyncData((
      members,
      {...edges, personaDid: update(edges[personaDid] ?? const VtcEdges())},
    ));
  }

  Future<CommunityMembers> _read() async {
    final service = ref.read(vtcTrustServiceProvider);
    // Read together; a failure of the vouches still reaches the caller,
    // once the members are read.
    final edges = service.edgesByMember(communityDid)..ignore();
    return (await service.communityMembers(communityDid), await edges);
  }
}
