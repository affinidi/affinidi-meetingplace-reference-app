import 'package:meeting_place_vtc/meeting_place_vtc.dart';

/// Where a session the member runs as a vetter stands.
enum VtcVetterSessionStatus {
  /// The vetter accepted the applicant's request; a session is to open.
  accepted,

  /// The session is open: the vetter compares the match code and waits for
  /// the applicant's card.
  inSession,

  /// The vetter issued a statement.
  issued,

  /// The vetter declined to vouch.
  declined,

  /// The applicant ended it.
  ended,
}

/// One applicant the member vets, as this phone recorded it. Holds the
/// signed documents the vetter sent, never the details the applicant's
/// card carries: those stay in the persona's inbox until the session ends.
class VtcVetterSession {
  /// Creates a [VtcVetterSession].
  const VtcVetterSession({
    required this.request,
    this.status = VtcVetterSessionStatus.accepted,
    this.session,
    this.matchConfirmed = false,
    this.statementId,
  });

  /// Restores a [VtcVetterSession] stored with [toJson].
  factory VtcVetterSession.fromJson(Map<String, dynamic> json) =>
      VtcVetterSession(
        request: VetterRequest.fromJson(
          json['request'] as Map<String, dynamic>,
        ),
        status: VtcVetterSessionStatus.values.byName(json['status'] as String),
        session: switch (json['session']) {
          final Map<String, dynamic> session => VetterSession.fromJson(session),
          _ => null,
        },
        matchConfirmed: json['matchConfirmed'] as bool? ?? false,
        statementId: json['statementId'] as String?,
      );

  /// The applicant's request, as accepted.
  final VetterRequest request;

  /// Where it stands.
  final VtcVetterSessionStatus status;

  /// The session opened for it, once open.
  final VetterSession? session;

  /// Whether the vetter confirmed, with the applicant present, that the
  /// match codes match.
  final bool matchConfirmed;

  /// The id of the statement issued, once issued.
  final String? statementId;

  /// Whether the vetter is still to vouch or decline.
  bool get isOpen =>
      status == VtcVetterSessionStatus.accepted ||
      status == VtcVetterSessionStatus.inSession;

  /// In [session].
  VtcVetterSession opened(VetterSession session) =>
      _copy(status: VtcVetterSessionStatus.inSession, session: session);

  /// With the match codes confirmed.
  VtcVetterSession confirmed() => _copy(status: status, matchConfirmed: true);

  /// Vouched for with the statement [statementId].
  VtcVetterSession issued(String statementId) =>
      _copy(status: VtcVetterSessionStatus.issued, statementId: statementId);

  /// Declined by the vetter.
  VtcVetterSession declined() => _copy(status: VtcVetterSessionStatus.declined);

  /// Ended by the applicant.
  VtcVetterSession ended() => _copy(status: VtcVetterSessionStatus.ended);

  VtcVetterSession _copy({
    required VtcVetterSessionStatus status,
    VetterSession? session,
    bool? matchConfirmed,
    String? statementId,
  }) => VtcVetterSession(
    request: request,
    status: status,
    session: session ?? this.session,
    matchConfirmed: matchConfirmed ?? this.matchConfirmed,
    statementId: statementId ?? this.statementId,
  );

  /// Serialises for storage.
  Map<String, dynamic> toJson() => {
    'request': request.toJson(),
    'status': status.name,
    'session': ?session?.toJson(),
    'matchConfirmed': matchConfirmed,
    'statementId': ?statementId,
  };
}

/// A step of creating a vetting ticket, in order.
enum VtcTicketStep {
  /// Checking the member's vetter card still holds.
  checkingCard,

  /// Creating the ticket and recording it on the desk.
  creating,
}

/// A step of taking an applicant's request, once their scan arrived, in
/// order.
enum VtcRequestStep {
  /// Checking the member's vetter card still holds, to send it with the
  /// answer.
  checkingCard,

  /// Accepting the request and opening a session with the applicant.
  openingSession,
}

/// The member's vetting desk for one community where they are a vetter: the
/// tickets they showed, and the applicants they vet.
class VtcVetterDesk {
  /// Creates a [VtcVetterDesk].
  const VtcVetterDesk({
    required this.communityDid,
    this.tickets = const [],
    this.sessions = const [],
  });

  /// Restores a [VtcVetterDesk] stored with [toJson].
  factory VtcVetterDesk.fromJson(Map<String, dynamic> json) => VtcVetterDesk(
    communityDid: json['communityDid'] as String,
    tickets: [
      for (final ticket in json['tickets'] as List<dynamic>)
        VetterTicket.fromJson(ticket as Map<String, dynamic>),
    ],
    sessions: [
      for (final session in json['sessions'] as List<dynamic>)
        VtcVetterSession.fromJson(session as Map<String, dynamic>),
    ],
  );

  /// The community's DID.
  final String communityDid;

  /// The tickets minted, live or not.
  final List<VetterTicket> tickets;

  /// The applicants vetted, oldest first.
  final List<VtcVetterSession> sessions;

  /// The tickets still live at [now].
  List<VetterTicket> liveTickets(DateTime now) => [
    for (final ticket in tickets)
      if (ticket.isLive(now)) ticket,
  ];

  /// The session for the request [requestId], if any.
  VtcVetterSession? sessionFor(String requestId) => sessions
      .where((session) => session.request.requestId == requestId)
      .firstOrNull;

  /// With [ticket] in place of any of the same id, and the tickets no
  /// longer live at [now] dropped.
  VtcVetterDesk withTicket(VetterTicket ticket, DateTime now) => VtcVetterDesk(
    communityDid: communityDid,
    tickets: [
      for (final other in tickets)
        if (other.id != ticket.id && other.isLive(now)) other,
      ticket,
    ],
    sessions: sessions,
  );

  /// With [session] in place of any for the same request.
  VtcVetterDesk withSession(VtcVetterSession session) => VtcVetterDesk(
    communityDid: communityDid,
    tickets: tickets,
    sessions: [
      for (final other in sessions)
        if (other.request.requestId != session.request.requestId) other,
      session,
    ],
  );

  /// Serialises for storage.
  Map<String, dynamic> toJson() => {
    'communityDid': communityDid,
    'tickets': [for (final ticket in tickets) ticket.toJson()],
    'sessions': [for (final session in sessions) session.toJson()],
  };
}
