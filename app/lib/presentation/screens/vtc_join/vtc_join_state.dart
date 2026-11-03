import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

part 'vtc_join_state.freezed.dart';

/// Where joining a community stands.
enum VtcJoinStep {
  /// Waiting for a community's code to be scanned.
  scanning,

  /// Sending a request; nothing to do but wait.
  working,

  /// The member reads what the community asks and decides to join.
  review,

  /// The member chooses which identity on their VTA joins.
  chooseIdentity,

  /// The member approves sharing the profile details the community asks
  /// for, as their VTA holds them.
  approveDetails,

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

  /// The identity has no profile on the VTA to take the details from.
  profileMissing,

  /// The VTA holds no value for a detail the community requires.
  detailsMissing,

  /// The community or the VTA refused.
  refused,
}

/// Why this app cannot apply under a way into a community yet.
enum VtcJoinUnsupported {
  /// Only invited applicants meet it.
  invitation,

  /// It asks for credentials.
  credentials,

  /// It asks for an in-person check.
  vetting,
}

/// A profile detail the member approves sharing, as the VTA would disclose
/// it. Kept in memory only.
class VtcJoinDetail {
  /// Creates a [VtcJoinDetail].
  const VtcJoinDetail({required this.type, required this.value});

  /// The claim type, e.g. `name`.
  final String type;

  /// The value, as shown to the member.
  final String value;
}

/// One way into a community, as the review shows it.
class VtcJoinWay {
  /// Creates a [VtcJoinWay].
  const VtcJoinWay({
    required this.automatic,
    this.description,
    this.unsupported,
  });

  /// Reads the way [criterion] describes.
  factory VtcJoinWay.of(JoinCriterion criterion) => VtcJoinWay(
    automatic: criterion.admission == JoinAdmission.automatic,
    description: criterion.description,
    unsupported: criterion.invitationRequired
        ? VtcJoinUnsupported.invitation
        : criterion.asksForCredentials
        ? VtcJoinUnsupported.credentials
        : criterion.asksForVetting
        ? VtcJoinUnsupported.vetting
        : null,
  );

  /// Whether meeting it admits at once, rather than after review.
  final bool automatic;

  /// The community's own words for it, if any.
  final String? description;

  /// Why this app cannot apply under it, or null when it can.
  final VtcJoinUnsupported? unsupported;
}

@Freezed(fromJson: false, toJson: false)
abstract class VtcJoinState with _$VtcJoinState {
  factory VtcJoinState({
    @Default(VtcJoinStep.scanning) VtcJoinStep step,
    String? communityName,
    @Default(false) bool canApply,
    @Default(false) bool admitsAtOnce,
    @Default(false) bool wasMember,

    /// The ways into the community, in its order.
    @Default(<VtcJoinWay>[]) List<VtcJoinWay> ways,

    /// The profile details the community asks for.
    @Default(<JoinAttributeRequest>[])
    List<JoinAttributeRequest> requestedDetails,

    /// Whether the community lists new members in its directory, or null
    /// when it does not say.
    bool? listsNewMembers,

    /// Whether the member opted in to the member directory. Off by default.
    @Default(false) bool listInDirectory,

    /// The identities on the member's VTA to join with, as DIDs.
    @Default(<String>[]) List<String> identityChoices,

    /// The profile details the member is asked to approve sharing.
    @Default(<VtcJoinDetail>[]) List<VtcJoinDetail> details,

    /// The community's reason for turning the application down, if given.
    String? denialReason,
    VtcJoinFailure? failure,
  }) = _VtcJoinState;
}
