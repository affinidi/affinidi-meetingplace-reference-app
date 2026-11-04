import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/identity/identity.dart';

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

  /// The member left the community.
  left,

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

  /// The member is the community's last administrator, so cannot leave.
  lastAdministrator,

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
    required this.id,
    required this.automatic,
    this.description,
    this.unsupported,
  });

  /// Reads the way [criterion] describes.
  factory VtcJoinWay.of(JoinCriterion criterion) => VtcJoinWay(
    id: criterion.id,
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

  /// The criterion's id within the community.
  final String id;

  /// Whether meeting it admits at once, rather than after review.
  final bool automatic;

  /// The community's own words for it, if any.
  final String? description;

  /// Why this app cannot apply under it, or null when it can.
  final VtcJoinUnsupported? unsupported;

  /// Whether this app can apply under it.
  bool get canApply => unsupported == null;
}

@Freezed(fromJson: false, toJson: false)
abstract class VtcJoinState with _$VtcJoinState {
  VtcJoinState._();

  factory VtcJoinState({
    @Default(VtcJoinStep.scanning) VtcJoinStep step,

    /// The scanned community's DID, once its code was read.
    String? communityDid,
    String? communityName,

    /// The community's logo, from its manifest or else its profile.
    Uri? logoUrl,

    /// What the community is about, from its profile.
    String? description,

    /// The community's website and contact address, from its profile.
    Uri? website,
    String? contactEmail,

    /// What the community's member directory would disclose about a member,
    /// or null when it offers none.
    DirectoryDisclosure? directoryDisclosure,
    @Default(false) bool canApply,
    @Default(false) bool wasMember,

    /// The ways into the community, in its order.
    @Default(<VtcJoinWay>[]) List<VtcJoinWay> ways,

    /// The id of the way in the member applies under, or null when this app
    /// can apply under none.
    String? chosenWayId,

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

    /// Each identity in [identityChoices], by its DID.
    @Default(<String, Identity>{}) Map<String, Identity> identities,

    /// The profile details the member is asked to approve sharing.
    @Default(<VtcJoinDetail>[]) List<VtcJoinDetail> details,

    /// The community's reason for turning the application down, if given.
    String? denialReason,
    VtcJoinFailure? failure,
  }) = _VtcJoinState;

  /// The way in the member applies under, or null when there is none.
  VtcJoinWay? get chosenWay =>
      ways.where((way) => way.id == chosenWayId).firstOrNull;

  /// Whether applying under [chosenWay] admits at once.
  bool get admitsAtOnce => chosenWay?.automatic ?? false;
}
