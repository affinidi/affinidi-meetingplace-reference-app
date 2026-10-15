/// A Verifiable Trust Community the member belongs to or applied to, and the
/// persona they are known by there.
class VtcCommunity {
  /// Creates a [VtcCommunity].
  const VtcCommunity({
    required this.communityDid,
    required this.personaDid,
    required this.contextId,
    this.name,
    this.signingKeyId,
    this.isMember = true,
    this.joinRequestId,
  });

  /// Restores a [VtcCommunity] stored with [toJson].
  ///
  /// Records stored before applications were kept are memberships.
  factory VtcCommunity.fromJson(Map<String, dynamic> json) {
    return VtcCommunity(
      communityDid: json['communityDid'] as String,
      personaDid: json['personaDid'] as String,
      contextId: json['contextId'] as String,
      name: json['name'] as String?,
      signingKeyId: json['signingKeyId'] as String?,
      isMember: json['isMember'] as bool? ?? true,
      joinRequestId: json['joinRequestId'] as String?,
    );
  }

  /// DID of the community.
  final String communityDid;

  /// DID of the member's persona in the community, held by their VTA.
  final String personaDid;

  /// VTA context of the persona.
  final String contextId;

  /// Name of the community, if known.
  final String? name;

  /// Id of the persona's signing key on the VTA, when it is not `#key-0`.
  final String? signingKeyId;

  /// Whether the community admitted the persona. False while applying, or
  /// after an application that did not succeed.
  final bool isMember;

  /// The community's id of the open application, if one is open.
  final String? joinRequestId;

  /// Whether an application is waiting for the community's decision.
  bool get isApplying => !isMember && joinRequestId != null;

  /// This record with the application's outcome: a member, or still
  /// applying under [requestId], or neither.
  VtcCommunity withApplication({required bool isMember, String? requestId}) {
    return VtcCommunity(
      communityDid: communityDid,
      personaDid: personaDid,
      contextId: contextId,
      name: name,
      signingKeyId: signingKeyId,
      isMember: isMember,
      joinRequestId: isMember ? null : requestId,
    );
  }

  /// Serialises for storage.
  Map<String, dynamic> toJson() => {
    'communityDid': communityDid,
    'personaDid': personaDid,
    'contextId': contextId,
    'name': ?name,
    'signingKeyId': ?signingKeyId,
    'isMember': isMember,
    'joinRequestId': ?joinRequestId,
  };
}
