import 'package:meeting_place_vtc/meeting_place_vtc.dart';

/// A step of bringing a new member's membership card from their
/// identity's inbox to their VTA, in order.
enum VtcDeliveryStep {
  /// The VTA lent the identity's keys to this phone.
  keysLent,

  /// The phone signed in to the identity's inbox on its mediator.
  signedIn,

  /// The community's card was found there.
  pickedUp,

  /// The VTA checked the card and keeps it.
  kept,

  /// The community took the card back as confirmation of the membership.
  confirmed,
}

/// How far a [VtcDeliveryStep] got.
enum VtcDeliveryStatus {
  /// Not reached yet.
  next,

  /// Being worked on.
  working,

  /// Reached, and waiting on someone else, such as the community to deliver.
  waiting,

  /// Done.
  done,

  /// Failed this time; the next check tries again.
  failed,
}

/// The progress of one collection of a membership card, with what each step
/// can show of itself. Never holds key material: only the keys' ids.
class VtcCardDelivery {
  /// Creates a [VtcCardDelivery] with every step still to come.
  const VtcCardDelivery({required this.personaDid})
    : _statuses = const {},
      signingKeyId = null,
      keyAgreementKeyId = null,
      mediatorDid = null,
      waiting = null,
      issue = null,
      isKeptAsValid = null;

  const VtcCardDelivery._({
    required this.personaDid,
    required this._statuses,
    required this.signingKeyId,
    required this.keyAgreementKeyId,
    required this.mediatorDid,
    required this.waiting,
    required this.issue,
    required this.isKeptAsValid,
  });

  /// The identity the card is for.
  final String personaDid;

  final Map<VtcDeliveryStep, VtcDeliveryStatus> _statuses;

  /// Id of the identity's signing key the VTA lent.
  final String? signingKeyId;

  /// Id of the identity's key agreement key the VTA lent.
  final String? keyAgreementKeyId;

  /// DID of the mediator holding the identity's inbox.
  final String? mediatorDid;

  /// How many messages waited in the inbox, of any kind.
  final int? waiting;

  /// The community's signed `credential-exchange/issue` document for the
  /// card.
  final TrustTaskDocument? issue;

  /// Whether the VTA keeps the card as valid, rather than revoked or
  /// expired.
  final bool? isKeptAsValid;

  /// How far [step] got.
  VtcDeliveryStatus status(VtcDeliveryStep step) =>
      _statuses[step] ?? VtcDeliveryStatus.next;

  /// Whether every step is done.
  bool get isDone => VtcDeliveryStep.values.every(
    (step) => status(step) == VtcDeliveryStatus.done,
  );

  /// A copy with [step] at [status], and with the facts given.
  VtcCardDelivery at(
    VtcDeliveryStep step,
    VtcDeliveryStatus status, {
    String? signingKeyId,
    String? keyAgreementKeyId,
    String? mediatorDid,
    int? waiting,
    TrustTaskDocument? issue,
    bool? isKeptAsValid,
  }) => VtcCardDelivery._(
    personaDid: personaDid,
    statuses: {..._statuses, step: status},
    signingKeyId: signingKeyId ?? this.signingKeyId,
    keyAgreementKeyId: keyAgreementKeyId ?? this.keyAgreementKeyId,
    mediatorDid: mediatorDid ?? this.mediatorDid,
    waiting: waiting ?? this.waiting,
    issue: issue ?? this.issue,
    isKeptAsValid: isKeptAsValid ?? this.isKeptAsValid,
  );
}
