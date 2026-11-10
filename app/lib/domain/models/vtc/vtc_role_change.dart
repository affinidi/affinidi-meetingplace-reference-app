/// A new role of the member in a community, as this phone found it once
/// the community's card granting it was kept on their VTA.
class VtcRoleChange {
  /// Creates a [VtcRoleChange].
  const VtcRoleChange({required this.communityDid, required this.role});

  final String communityDid;

  /// The role now in force, e.g. `admin`.
  final String role;
}
