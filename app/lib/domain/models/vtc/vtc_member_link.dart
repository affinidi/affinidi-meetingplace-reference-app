/// Which member of a community a Meeting Place contact is: the entry the
/// member picked for them in the community's directory, to vouch for them
/// there.
///
/// Personal data: never log it.
class VtcMemberLink {
  /// Creates a [VtcMemberLink].
  const VtcMemberLink({
    required this.communityDid,
    required this.channelDid,
    required this.entryId,
    required this.personaDid,
    required this.name,
    required this.linkedAt,
  });

  /// Restores a [VtcMemberLink] stored with [toJson].
  factory VtcMemberLink.fromJson(Map<String, dynamic> json) => VtcMemberLink(
    communityDid: json['communityDid'] as String,
    channelDid: json['channelDid'] as String,
    entryId: json['entryId'] as String,
    personaDid: json['personaDid'] as String,
    name: json['name'] as String,
    linkedAt: DateTime.parse(json['linkedAt'] as String),
  );

  /// DID of the community.
  final String communityDid;

  /// The contact's channel DID: the contact this link is about.
  final String channelDid;

  /// The contact's entry id in the community's directory.
  final String entryId;

  /// The DID the contact joined the community with, which a vouch names.
  final String personaDid;

  /// The contact's name as the directory showed it.
  final String name;

  /// When the member picked the entry.
  final DateTime linkedAt;

  /// This link as JSON, for [VtcMemberLink.fromJson].
  Map<String, dynamic> toJson() => {
    'communityDid': communityDid,
    'channelDid': channelDid,
    'entryId': entryId,
    'personaDid': personaDid,
    'name': name,
    'linkedAt': linkedAt.toUtc().toIso8601String(),
  };
}
