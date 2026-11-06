import '../models/vtc/linked_vta.dart';
import '../models/vtc/vtc_community.dart';
import '../models/vtc/vtc_group_chat.dart';
import '../models/vtc/vtc_left_membership.dart';
import '../models/vtc/vtc_vetter_desk.dart';
import '../models/vtc/vtc_vetting.dart';

/// Stores the linked VTA, the communities the member signs in to, the
/// memberships they left, their vetting for communities they apply to, and
/// their vetting desks for communities where they vet.
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

  /// The member's vetting for [communityDid], or null when none is recorded.
  Future<VtcVetting?> findVetting(String communityDid);

  /// Records [vetting], replacing a record for the same community.
  Future<void> saveVetting(VtcVetting vetting);

  /// Forgets the member's vetting for [communityDid], if recorded.
  Future<void> removeVetting(String communityDid);

  /// The member's vetting desk for [communityDid], or null when none is
  /// recorded.
  Future<VtcVetterDesk?> findVetterDesk(String communityDid);

  /// Records [desk], replacing a desk for the same community.
  Future<void> saveVetterDesk(VtcVetterDesk desk);

  /// Forgets the member's vetting desk for [communityDid], if recorded.
  Future<void> removeVetterDesk(String communityDid);

  /// Every chat this phone owns or joined that follows a community group.
  Future<List<VtcGroupChat>> groupChats();

  /// Records [chat], replacing a record of the same
  /// [VtcGroupChat.chatGroupId].
  Future<void> saveGroupChat(VtcGroupChat chat);

  /// Forgets the chat with [chatGroupId], if recorded.
  Future<void> removeGroupChat(String chatGroupId);

  /// Forgets the linked VTA, every community, every left membership, all
  /// vetting and every vetting desk.
  ///
  /// Keeps the group chats: a chat this phone owns lets in only a group's
  /// members, and must keep refusing everyone else while no VTA is linked.
  Future<void> clear();
}
