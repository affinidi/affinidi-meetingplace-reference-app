/// A community removing the member, as this phone found its notice.
class VtcRemoval {
  /// Creates a [VtcRemoval].
  const VtcRemoval({required this.communityDid, this.name, this.reason});

  final String communityDid;

  /// Name of the community, if known.
  final String? name;

  /// Why, as the community gave it; null when it gave no reason.
  final String? reason;
}
