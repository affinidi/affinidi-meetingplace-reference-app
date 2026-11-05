import '../models/vtc/linked_vta.dart';
import '../models/vtc/vtc_community.dart';
import '../models/vtc/vtc_left_membership.dart';

/// Stores the linked VTA, the communities the member signs in to, and the
/// memberships they left.
abstract interface class VtcRepository {
  /// The linked VTA, or null when the phone is not linked.
  Future<LinkedVta?> getLinkedVta();

  /// Stores [linkedVta], replacing any previous link.
  Future<void> saveLinkedVta(LinkedVta linkedVta);

  /// The community with [communityDid], or null when not recorded.
  Future<VtcCommunity?> findCommunity(String communityDid);

  /// Every recorded community.
  Future<List<VtcCommunity>> communities();

  /// Records [community], replacing a record of the same community.
  Future<void> saveCommunity(VtcCommunity community);

  /// Forgets the community with [communityDid], if recorded.
  Future<void> removeCommunity(String communityDid);

  /// Every membership the member left, as recorded.
  Future<List<VtcLeftMembership>> leftMemberships();

  /// Records [left], replacing a record of the same [VtcLeftMembership.key].
  Future<void> saveLeftMembership(VtcLeftMembership left);

  /// Forgets the linked VTA, every community and every left membership.
  Future<void> clear();
}
