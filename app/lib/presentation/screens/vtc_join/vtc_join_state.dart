import 'package:freezed_annotation/freezed_annotation.dart';

part 'vtc_join_state.freezed.dart';

/// Where joining a community stands.
enum VtcJoinStep {
  /// Waiting for a community's code to be scanned.
  scanning,

  /// Sending a request; nothing to do but wait.
  working,

  /// The member reads what the community asks and decides to join.
  review,

  /// The member is a member, newly or already.
  joined,

  /// An application waits for the community's decision.
  pending,

  /// The community turned the application down.
  denied,

  /// The community needs more than this app can send.
  needsMore,

  /// Joining could not go ahead.
  failed,
}

/// Why joining could not go ahead.
enum VtcJoinFailure {
  /// The scanned code is not a community's DID.
  invalidCode,

  /// No VTA is linked.
  vtaMissing,

  /// The community or the VTA cannot be reached.
  unreachable,

  /// The VTA cannot publish a persona.
  noDidHosting,

  /// The community takes no applications.
  notAccepting,

  /// An answer did not check out.
  badAnswer,

  /// The community or the VTA refused.
  refused,
}

@Freezed(fromJson: false, toJson: false)
abstract class VtcJoinState with _$VtcJoinState {
  factory VtcJoinState({
    @Default(VtcJoinStep.scanning) VtcJoinStep step,
    String? communityName,
    @Default(false) bool canApply,
    @Default(false) bool admitsAtOnce,
    @Default(false) bool wasMember,
    VtcJoinFailure? failure,
  }) = _VtcJoinState;
}
