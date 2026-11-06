import 'package:meeting_place_vtc/meeting_place_vtc.dart';

/// What the phone does in the background while the member is vetted, in
/// the order it comes.
enum VtcVettingWork {
  /// Reading the vetters the community lists, to pick the one at hand.
  listingVetters,

  /// Borrowing the applying identity's keys from the VTA.
  unlockingIdentity,

  /// Signing the request and sending it to the vetter.
  sendingRequest,

  /// Reading the details the vetting card would carry from the VTA.
  preparingDetails,

  /// The VTA recording what the member shares with the vetter.
  recordingDisclosure,

  /// Sending the vetter the card with the member's details.
  sendingDetails,
}

/// Where vetting by one vetter stands.
enum VtcVettingStatus {
  /// The request is on its way to the vetter.
  requested,

  /// The vetter accepted and showed their role; a session is to come.
  accepted,

  /// The vetter opened a session; the member compares the match code.
  inSession,

  /// The member's card went to the vetter; their statement is to come.
  cardSent,

  /// The vetter vouched: their statement is kept.
  vouched,

  /// The vetter declined to vouch.
  declined,

  /// The vetter refused the request, or could not show their role.
  refused,

  /// The member ended the session, e.g. because the codes did not match.
  abandoned,
}

/// The member's vetting by one vetter, as this phone recorded it. Holds the
/// signed documents exchanged, never the details the member's card carried.
class VtcVettingRequest {
  /// Creates a [VtcVettingRequest].
  const VtcVettingRequest({
    required this.vetterDid,
    required this.request,
    this.status = VtcVettingStatus.requested,
    this.vetterName,
    this.requestId,
    this.roleValidUntil,
    this.session,
    this.cardDigest,
    this.identityCommitment,
    this.statement,
    this.declineCode,
    this.declineMessage,
    this.failure,
  });

  /// Restores a [VtcVettingRequest] stored with [toJson].
  factory VtcVettingRequest.fromJson(Map<String, dynamic> json) =>
      VtcVettingRequest(
        vetterDid: json['vetterDid'] as String,
        request: json['request'] as Map<String, dynamic>,
        status: VtcVettingStatus.values.byName(json['status'] as String),
        vetterName: json['vetterName'] as String?,
        requestId: json['requestId'] as String?,
        roleValidUntil: switch (json['roleValidUntil']) {
          final String at => DateTime.parse(at),
          _ => null,
        },
        session: json['session'] as Map<String, dynamic>?,
        cardDigest: json['cardDigest'] as String?,
        identityCommitment: json['identityCommitment'] as String?,
        statement: json['statement'] as Map<String, dynamic>?,
        declineCode: json['declineCode'] as String?,
        declineMessage: json['declineMessage'] as String?,
        failure: VettingFailure.values.asNameMap()[json['failure']],
      );

  /// The vetter's DID.
  final String vetterDid;

  /// The vetter's name, as the community lists them, if known.
  final String? vetterName;

  /// The signed request, as sent.
  final Map<String, dynamic> request;

  /// Where it stands.
  final VtcVettingStatus status;

  /// The vetter's id of the request, once accepted.
  final String? requestId;

  /// Until when the community grants the vetter their role, once checked.
  final DateTime? roleValidUntil;

  /// The vetter's signed session document, as received.
  final Map<String, dynamic>? session;

  /// What the card sent named, for the statement to match.
  final String? cardDigest;
  final String? identityCommitment;

  /// The vetter's statement, once checked.
  final Map<String, dynamic>? statement;

  /// Why the vetter declined, in their code and words, if they say.
  final String? declineCode;
  final String? declineMessage;

  /// Why the request was refused.
  final VettingFailure? failure;

  /// The request as a document.
  TrustTaskDocument get requestDocument => TrustTaskDocument.fromJson(request);

  /// The vetter as they accepted, once they did.
  AcceptedVetter? get accepted => switch ((requestId, roleValidUntil)) {
    (final String id, final DateTime until) => AcceptedVetter(
      vetterDid: vetterDid,
      requestId: id,
      roleValidUntil: until,
    ),
    _ => null,
  };

  /// What the card sent named, once sent.
  SentCard? get sentCard => switch ((cardDigest, identityCommitment)) {
    (final String digest, final String commitment) => SentCard(
      cardDigest: digest,
      identityCommitment: commitment,
    ),
    _ => null,
  };

  /// Whether the vetter is still to answer or vouch.
  bool get isOpen => switch (status) {
    VtcVettingStatus.requested ||
    VtcVettingStatus.accepted ||
    VtcVettingStatus.inSession ||
    VtcVettingStatus.cardSent => true,
    _ => false,
  };

  /// How long a vetter has to answer a request: as long as their ticket
  /// lasts. A typed code no ticket holds is left unanswered, so guessing
  /// codes learns nothing; past this, no answer is coming.
  static const answerWindow = Duration(minutes: 15);

  /// Whether the vetter left the request unanswered past [answerWindow],
  /// at [now].
  bool isUnansweredAt(DateTime now) {
    if (status != VtcVettingStatus.requested) return false;
    final sentAt = DateTime.tryParse('${request['issuedAt']}');
    return sentAt != null && now.isAfter(sentAt.add(answerWindow));
  }

  /// Accepted by [vetter], who showed their role.
  VtcVettingRequest acceptedBy(AcceptedVetter vetter) => _copy(
    status: VtcVettingStatus.accepted,
    requestId: vetter.requestId,
    roleValidUntil: vetter.roleValidUntil,
  );

  /// In the session [document].
  VtcVettingRequest inSession(TrustTaskDocument document) =>
      _copy(status: VtcVettingStatus.inSession, session: document.toJson());

  /// With [card] sent in the session.
  VtcVettingRequest cardSentAs(SentCard card) => _copy(
    status: VtcVettingStatus.cardSent,
    cardDigest: card.cardDigest,
    identityCommitment: card.identityCommitment,
  );

  /// Vouched for with [statement].
  VtcVettingRequest vouched(VettingStatement statement) =>
      _copy(status: VtcVettingStatus.vouched, statement: statement.credential);

  /// Declined by the vetter, for [decline]'s reason.
  VtcVettingRequest declined(VettingDecline decline) => _copy(
    status: VtcVettingStatus.declined,
    declineCode: decline.code,
    declineMessage: decline.message,
  );

  /// Refused, for [reason].
  VtcVettingRequest refused(VettingFailure reason) =>
      _copy(status: VtcVettingStatus.refused, failure: reason);

  /// Ended by the member.
  VtcVettingRequest abandoned() => _copy(status: VtcVettingStatus.abandoned);

  VtcVettingRequest _copy({
    required VtcVettingStatus status,
    String? requestId,
    DateTime? roleValidUntil,
    Map<String, dynamic>? session,
    String? cardDigest,
    String? identityCommitment,
    Map<String, dynamic>? statement,
    String? declineCode,
    String? declineMessage,
    VettingFailure? failure,
  }) => VtcVettingRequest(
    vetterDid: vetterDid,
    vetterName: vetterName,
    request: request,
    status: status,
    requestId: requestId ?? this.requestId,
    roleValidUntil: roleValidUntil ?? this.roleValidUntil,
    session: session ?? this.session,
    cardDigest: cardDigest ?? this.cardDigest,
    identityCommitment: identityCommitment ?? this.identityCommitment,
    statement: statement ?? this.statement,
    declineCode: declineCode,
    declineMessage: declineMessage,
    failure: failure,
  );

  /// Serialises for storage.
  Map<String, dynamic> toJson() => {
    'vetterDid': vetterDid,
    'request': request,
    'status': status.name,
    'vetterName': ?vetterName,
    'requestId': ?requestId,
    'roleValidUntil': ?roleValidUntil?.toUtc().toIso8601String(),
    'session': ?session,
    'cardDigest': ?cardDigest,
    'identityCommitment': ?identityCommitment,
    'statement': ?statement,
    'declineCode': ?declineCode,
    'declineMessage': ?declineMessage,
    'failure': ?failure?.name,
  };
}

/// The member's vetting for one community: the way in it is for, the role
/// its vetters hold, the salt every card commits with, and each vetter
/// asked.
class VtcVetting {
  /// Creates a [VtcVetting].
  const VtcVetting({
    required this.communityDid,
    required this.criterionId,
    required this.vetterRole,
    required this.salt,
    this.requests = const [],
  });

  /// Restores a [VtcVetting] stored with [toJson].
  factory VtcVetting.fromJson(Map<String, dynamic> json) => VtcVetting(
    communityDid: json['communityDid'] as String,
    criterionId: json['criterionId'] as String,
    vetterRole: json['vetterRole'] as String,
    salt: json['salt'] as String,
    requests: [
      for (final request in json['requests'] as List<dynamic>)
        VtcVettingRequest.fromJson(request as Map<String, dynamic>),
    ],
  );

  /// The community's DID.
  final String communityDid;

  /// The id of the way in the statements are gathered for.
  final String criterionId;

  /// The role the community's vetters hold, e.g. `vetter`.
  final String vetterRole;

  /// The salt of the identity commitment, one per application.
  final String salt;

  /// Each vetter asked, the latest request per vetter.
  final List<VtcVettingRequest> requests;

  /// The vetters' statements kept so far.
  List<VettingStatement> get statements => [
    for (final request in requests)
      if (request.statement case final Map<String, dynamic> credential)
        ?VettingStatement.read(credential),
  ];

  /// The request to [vetterDid], if any.
  VtcVettingRequest? requestTo(String vetterDid) =>
      requests.where((request) => request.vetterDid == vetterDid).firstOrNull;

  /// With [request] in place of any earlier one to the same vetter.
  VtcVetting withRequest(VtcVettingRequest request) => VtcVetting(
    communityDid: communityDid,
    criterionId: criterionId,
    vetterRole: vetterRole,
    salt: salt,
    requests: [
      for (final other in requests)
        if (other.vetterDid != request.vetterDid) other,
      request,
    ],
  );

  /// Serialises for storage.
  Map<String, dynamic> toJson() => {
    'communityDid': communityDid,
    'criterionId': criterionId,
    'vetterRole': vetterRole,
    'salt': salt,
    'requests': [for (final request in requests) request.toJson()],
  };
}
