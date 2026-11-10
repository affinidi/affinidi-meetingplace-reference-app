import 'vtc_membership_card.dart';

/// A community group's card for the member, as their VTA keeps it: the
/// membership credential the group issued to their identity in the
/// community, and the community's grant that lets the group issue it.
///
/// The group's credential names no status list, so the group cannot revoke
/// it alone: it holds while the community's grant to the group holds.
class VtcGroupCard {
  /// Creates a [VtcGroupCard].
  const VtcGroupCard({required this.membership, this.authority});

  /// The membership credential the group issued.
  final VtcMembershipCard membership;

  /// The community's grant to the group, exactly as the VTA keeps it, or
  /// null when it keeps none.
  final Map<String, dynamic>? authority;

  /// The group's DID, which issued [membership].
  String get groupDid => membership.issuer;

  /// When the community's grant to the group stops holding, if it says.
  DateTime? get authorityValidUntil => switch (authority?['validUntil']) {
    final String until => DateTime.tryParse(until),
    _ => null,
  };
}
