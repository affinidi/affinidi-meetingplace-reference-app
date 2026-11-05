import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../domain/models/vtc/vtc_card_delivery.dart';
import '../../../domain/models/vtc/vtc_identity_check.dart';
import '../../../domain/models/vtc/vtc_membership_card.dart';

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

  /// The member approves presenting the credential the chosen way in asks
  /// for, as their VTA holds it.
  approveCredential,

  /// The member is a member, newly or already.
  joined,

  /// The member left the community.
  left,

  /// An application waits for the community's decision.
  pending,

  /// The member withdrew their application.
  withdrawn,

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

  /// No community goes by the join phrase entered.
  phraseNotFound,

  /// The join phrase entered expired.
  phraseExpired,

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

  /// The identity holds no credential the chosen way in accepts, or none
  /// it can present.
  credentialMissing,

  /// The member is the community's last administrator, so cannot leave.
  lastAdministrator,

  /// The community or the VTA refused.
  refused,
}

/// Why this app cannot apply under a way into a community yet.
enum VtcJoinUnsupported {
  /// Only invited applicants meet it.
  invitation,

  /// It asks for credentials in a way this app cannot present.
  credentials,

  /// It asks for a credential none of the member's identities holds.
  credentialMissing,

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

/// A credential the member approves presenting, as the VTA holds it. Kept
/// in memory only.
class VtcJoinCredential {
  /// Creates a [VtcJoinCredential].
  const VtcJoinCredential({
    required this.types,
    required this.claims,
    this.issuerDid,
  });

  /// Its VC types, the most specific last.
  final List<String> types;

  /// The DID that issued it, when it says.
  final String? issuerDid;

  /// Every subject claim presenting it discloses: the whole credential is
  /// sent.
  final List<VtcJoinDetail> claims;
}

/// One way into a community, as the review shows it.
class VtcJoinWay {
  /// Creates a [VtcJoinWay].
  const VtcJoinWay({
    required this.id,
    required this.automatic,
    this.description,
    this.unsupported,
    this.credentialType,
    this.heldBy = const {},
  });

  /// Reads the way [criterion] describes. [heldBy] are the member's
  /// identities holding the credential it asks for, if it asks for one.
  factory VtcJoinWay.of(
    JoinCriterion criterion, {
    Set<String> heldBy = const {},
  }) {
    final presentable = isMetByOneCredential(criterion);
    return VtcJoinWay(
      id: criterion.id,
      automatic: criterion.admission == JoinAdmission.automatic,
      description: criterion.description,
      unsupported: criterion.invitationRequired
          ? VtcJoinUnsupported.invitation
          : criterion.asksForCredentials && !presentable
          ? VtcJoinUnsupported.credentials
          : presentable && heldBy.isEmpty
          ? VtcJoinUnsupported.credentialMissing
          : criterion.asksForVetting
          ? VtcJoinUnsupported.vetting
          : null,
      credentialType: presentable
          ? criterion.credentials!.typeAlternatives.single.first.last
          : null,
      heldBy: heldBy,
    );
  }

  /// The criterion's id within the community.
  final String id;

  /// Whether meeting it admits at once, rather than after review.
  final bool automatic;

  /// The community's own words for it, if any.
  final String? description;

  /// Why this app cannot apply under it, or null when it can.
  final VtcJoinUnsupported? unsupported;

  /// The most specific VC type of the credential it asks for, when this app
  /// can present one for it.
  final String? credentialType;

  /// The member's identities holding the credential it asks for, by DID.
  final Set<String> heldBy;

  /// Whether this app can apply under it.
  bool get canApply => unsupported == null;
}

@Freezed(fromJson: false, toJson: false)
abstract class VtcJoinState with _$VtcJoinState {
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

    /// The join manifest exactly as the community sent it, for the member
    /// to read.
    @Default(<String, dynamic>{}) Map<String, dynamic> manifest,

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

    /// The identities holding the credential the chosen way in asks for,
    /// or null when it asks for none: only they can join under it.
    Set<String>? credentialHolders,

    /// The credential the member is asked to approve presenting.
    VtcJoinCredential? sharedCredential,

    /// The profile details the member is asked to approve sharing.
    @Default(<VtcJoinDetail>[]) List<VtcJoinDetail> details,

    /// The open application as the VTA signed it and the community answered
    /// it, both documents as they were on the wire, or null when this phone
    /// did not send it.
    TrustTaskExchange? submitExchange,

    /// What shows the open application was signed and answered: from
    /// [submitExchange], or recorded without the documents.
    TrustTaskReceipt? submitReceipt,

    /// The community's id of the open application, if known.
    String? requestId,

    /// Whether the community's administrators put the open application off.
    @Default(false) bool deferred,

    /// Whether this phone is asking the community about the open
    /// application right now.
    @Default(false) bool checking,

    /// The membership card the community issued, once the member's VTA
    /// holds it.
    VtcMembershipCard? membershipCard,

    /// The community's own check of the member's identity, once their VTA
    /// holds one.
    VtcIdentityCheck? identityCheck,

    /// How the card is being brought from the identity's inbox to the VTA,
    /// once this screen started collecting it.
    VtcCardDelivery? cardDelivery,

    /// When this phone last asked the community about the open application.
    DateTime? lastCheckedAt,

    /// The last signed status request and the community's verified answer,
    /// as they were on the wire.
    TrustTaskExchange? lastCheckExchange,

    /// The community's reason for turning the application down, if given.
    String? denialReason,
    VtcJoinFailure? failure,
  }) = _VtcJoinState;
}
