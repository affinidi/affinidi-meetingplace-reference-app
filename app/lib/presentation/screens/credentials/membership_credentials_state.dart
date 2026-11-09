import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/vtc/vtc_membership_entry.dart';

part 'membership_credentials_state.freezed.dart';

/// Why the membership cards cannot be shown.
enum MembershipCredentialsFailure {
  /// No VTA is linked.
  vtaMissing,

  /// The VTA cannot be reached, or refused.
  unreachable,
}

@Freezed(fromJson: false, toJson: false)
abstract class MembershipCredentialsState with _$MembershipCredentialsState {
  factory MembershipCredentialsState({
    /// Whether there is nothing to show yet: no cards kept on this phone,
    /// and the VTA not read.
    @Default(true) bool isLoading,

    /// Whether the cards are being read from the VTA again.
    @Default(false) bool isSyncing,

    /// The member's membership cards: held on their VTA, then left.
    @Default(<VtcMembershipEntry>[]) List<VtcMembershipEntry> entries,

    /// When the cards were read from the VTA.
    DateTime? readAt,

    /// What each card's community said of it, by [VtcMembershipEntry.key];
    /// none while it is being checked.
    @Default(<String, VtcCardStatus>{}) Map<String, VtcCardStatus> statuses,

    /// The cards being checked with their community right now.
    @Default(<String>{}) Set<String> checking,
    MembershipCredentialsFailure? failure,
  }) = _MembershipCredentialsState;
}
