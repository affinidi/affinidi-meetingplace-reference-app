import 'vtc_membership_card.dart';

/// A community group's card for the member, as their VTA keeps it: the
/// membership credential the group issued to their identity in the
/// community, and the community's grant that lets the group issue it.
///
/// The group's credential names no status list, so the group cannot revoke
/// it alone: it holds while the community's grant to the group holds.
class VtcGroupCard {
  /// Creates a [VtcGroupCard].
  const VtcGroupCard({
    required this.membership,
    required this.communityDid,
    this.communityName,
    this.groupName,
    this.authority,
  });

  /// The membership credential the group issued.
  final VtcMembershipCard membership;

  /// The DID of the community the group belongs to.
  final String communityDid;

  /// The community's name, if known.
  final String? communityName;

  /// The group's name, if known.
  final String? groupName;

  /// The community's grant to the group, exactly as the VTA keeps it, or
  /// null when it keeps none.
  final Map<String, dynamic>? authority;

  /// The group's DID, which issued [membership].
  String get groupDid => membership.issuer;

  /// What names this card among the others: its credential's id, else its
  /// group and member.
  String get key => switch (membership.credential['id']) {
    final String id => id,
    _ => '$groupDid ${membership.memberDid}',
  };

  /// When the community's grant to the group stops holding, if it says.
  DateTime? get authorityValidUntil => switch (authority?['validUntil']) {
    final String until => DateTime.tryParse(until),
    _ => null,
  };
}
