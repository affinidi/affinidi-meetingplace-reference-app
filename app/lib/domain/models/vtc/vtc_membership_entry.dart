import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import 'vtc_left_membership.dart';
import 'vtc_membership_card.dart';

/// A membership card to show the member: one their VTA holds, or one of a
/// membership they left, kept on this phone.
class VtcMembershipEntry {
  /// Creates a [VtcMembershipEntry].
  const VtcMembershipEntry({
    required this.card,
    this.communityName,
    this.left,
    this.stored,
  });

  /// The card the community issued.
  final VtcMembershipCard card;

  /// What the member's VTA records of the card, while it holds it.
  final HeldCredential? stored;

  /// The community's name, if known.
  final String? communityName;

  /// The membership's end, if the member left.
  final VtcLeftMembership? left;

  /// What names this entry among the others: its card's id, else its
  /// community and member.
  String get key => switch (card.credential['id']) {
    final String id => id,
    _ => '${card.issuer} ${card.memberDid}',
  };
}

/// Whether a membership card still holds.
enum VtcCardState {
  /// Its community has not revoked it.
  valid,

  /// Its community revoked it.
  revoked,

  /// Its community gave it no status list, so cannot revoke it.
  notRevocable,

  /// Its validity ended.
  expired,

  /// Its community's status list could not be read or checked.
  unknown,
}

/// What this phone found of a card's state, and what shows it.
class VtcCardStatus {
  /// Creates a [VtcCardStatus].
  const VtcCardStatus({
    required this.state,
    this.checkedAt,
    this.statusListUrl,
    this.index,
    this.statusList,
    this.lastKnown,
    this.failure,
  });

  final VtcCardState state;

  /// When the community's list was read, for [VtcCardState.valid] and
  /// [VtcCardState.revoked].
  final DateTime? checkedAt;

  /// Where the community publishes the list.
  final Uri? statusListUrl;

  /// The card's place in the list.
  final int? index;

  /// The list as the community signed it.
  final Map<String, dynamic>? statusList;

  /// For [VtcCardState.unknown]: what the list said when last read, for a
  /// membership left.
  final VtcStatusRecord? lastKnown;

  /// For [VtcCardState.unknown]: why the list could not be read.
  final MeetingPlaceVtcSDKErrorCode? failure;
}
