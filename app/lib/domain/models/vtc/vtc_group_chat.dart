import 'package:meeting_place_vtc/meeting_place_vtc.dart';

/// A Meeting Place group chat that follows a community group: it is known
/// by the group's DID, and only the group's members are let in.
///
/// On the owner's phone it also records who was let in as which member of
/// the group, to remove them when they leave the group, and who moderates
/// as one of its managers. Personal data: never log it.
class VtcGroupChat {
  /// Creates a [VtcGroupChat].
  const VtcGroupChat({
    required this.chatGroupId,
    required this.communityDid,
    required this.groupId,
    required this.groupDid,
    required this.name,
    required this.isOwner,
    this.posting = GroupChatPosting.everyone,
    this.members = const {},
    this.moderators = const {},
    this.authority,
  });

  /// Restores a [VtcGroupChat] stored with [toJson].
  factory VtcGroupChat.fromJson(Map<String, dynamic> json) => VtcGroupChat(
    chatGroupId: json['chatGroupId'] as String,
    communityDid: json['communityDid'] as String,
    groupId: json['groupId'] as String,
    groupDid: json['groupDid'] as String,
    name: json['name'] as String,
    isOwner: json['isOwner'] as bool,
    posting: GroupChatPosting.fromLink(json['posting']),
    members: {
      for (final MapEntry(:key, :value)
          in (json['members'] as Map<String, dynamic>? ?? const {}).entries)
        key: value as String,
    },
    moderators: {
      ...(json['moderators'] as List<dynamic>? ?? const []).whereType<String>(),
    },
    authority: json['authority'] as Map<String, dynamic>?,
  );

  /// The Meeting Place group's id.
  final String chatGroupId;

  /// DID of the community the group belongs to.
  final String communityDid;

  /// The community's id of the group.
  final String groupId;

  /// The group's DID, which the chat is known by.
  final String groupDid;

  /// The group's name.
  final String name;

  /// Whether this phone owns the chat and lets members in.
  final bool isOwner;

  /// Who may post in the chat, as the community's link to it says.
  final GroupChatPosting posting;

  /// The chat members let in, by their DID in the chat, each with their
  /// entry id in the community's directory. The owner's record only.
  final Map<String, String> members;

  /// The chat members who moderate it, as managers of the group. The
  /// owner's record only.
  final Set<String> moderators;

  /// The community's authority credential to the group, as the last join
  /// let in carried it: its revocation is how the owner's phone tells a
  /// deleted group from one it may no longer see. The owner's record only.
  final Map<String, dynamic>? authority;

  /// A copy with [posting], [members], [moderators] and [authority]
  /// replaced where given.
  VtcGroupChat copyWith({
    GroupChatPosting? posting,
    Map<String, String>? members,
    Set<String>? moderators,
    Map<String, dynamic>? authority,
  }) => VtcGroupChat(
    chatGroupId: chatGroupId,
    communityDid: communityDid,
    groupId: groupId,
    groupDid: groupDid,
    name: name,
    isOwner: isOwner,
    posting: posting ?? this.posting,
    members: members ?? this.members,
    moderators: moderators ?? this.moderators,
    authority: authority ?? this.authority,
  );

  /// This record as JSON, for [VtcGroupChat.fromJson].
  Map<String, dynamic> toJson() => {
    'chatGroupId': chatGroupId,
    'communityDid': communityDid,
    'groupId': groupId,
    'groupDid': groupDid,
    'name': name,
    'isOwner': isOwner,
    'posting': posting.name,
    'members': members,
    'moderators': moderators.toList(),
    'authority': ?authority,
  };
}
