import '../models/vtc/linked_vta.dart';
import '../models/vtc/vtc_community.dart';

/// Stores the linked VTA and the communities the member signs in to.
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

  /// Forgets the linked VTA and every community.
  Future<void> clear();
}
