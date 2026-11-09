/// Who may post in a community group chat where only the group's managers
/// post, such as announcements: its moderators, read from the chat itself.
///
/// Every member's app applies it on its own: the chat is end-to-end
/// encrypted, so its server cannot tell a post from a reaction or a read
/// receipt to refuse one. Personal data: never log it.
class VtcChatPosting {
  /// Creates a [VtcChatPosting].
  const VtcChatPosting({required this.posters, required this.memberDid});

  /// The DIDs, in the chat, of those who may post: its owner and the
  /// group's managers.
  final Set<String> posters;

  /// The DID, in the chat, of the member on this phone.
  final String memberDid;

  /// Whether the member on this phone may post.
  bool get canPost => posters.contains(memberDid);

  /// Whether a post by [senderDid] is one to show.
  bool allows(String senderDid) => posters.contains(senderDid);
}
