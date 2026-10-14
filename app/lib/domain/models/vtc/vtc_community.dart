/// A Verifiable Trust Community the member belongs to, and the persona they
/// are known by there.
class VtcCommunity {
  /// Creates a [VtcCommunity].
  const VtcCommunity({
    required this.communityDid,
    required this.personaDid,
    required this.contextId,
    this.name,
  });

  /// Restores a [VtcCommunity] stored with [toJson].
  factory VtcCommunity.fromJson(Map<String, dynamic> json) {
    return VtcCommunity(
      communityDid: json['communityDid'] as String,
      personaDid: json['personaDid'] as String,
      contextId: json['contextId'] as String,
      name: json['name'] as String?,
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

  /// Serialises for storage.
  Map<String, dynamic> toJson() => {
    'communityDid': communityDid,
    'personaDid': personaDid,
    'contextId': contextId,
    'name': ?name,
  };
}
