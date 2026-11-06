import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/vtc/vtc_vetter_card.dart';
import '../../../domain/models/vtc/vtc_vetter_desk.dart';

part 'vtc_vetting_desk_state.freezed.dart';

/// Where the member's vetting desk for a community stands.
enum VtcVettingDeskStep {
  /// Reading the desk as this phone recorded it.
  loading,

  /// The member holds no vetter role card for the community that is in
  /// date and not revoked.
  notVetter,

  /// The desk is open: a ticket to show, and applicants to vet.
  open,
}

/// A step of vetting one applicant, from showing them a ticket, in order.
enum VtcVettingFlowStep {
  /// The ticket is on show, waiting for the applicant to scan or type it.
  ticket,

  /// The vetter and the applicant compare their match codes.
  match,

  /// The vetter checks the applicant's details in person, then vouches for
  /// them or declines.
  details,

  /// The session ended: vouched for, declined, or ended by the applicant.
  done,
}

/// Why the last step on the vetting desk could not go ahead.
enum VtcVettingDeskFailure {
  /// The member's VTA, mediator or the community could not be reached.
  unreachable,

  /// The member's vetter role card no longer holds.
  notVetter,
}

/// The member's vetting desk for one community, as the screen shows it.
@freezed
abstract class VtcVettingDeskState with _$VtcVettingDeskState {
  factory VtcVettingDeskState({
    @Default(VtcVettingDeskStep.loading) VtcVettingDeskStep step,

    /// The desk as recorded: tickets and sessions.
    VtcVetterDesk? desk,

    /// Whether the member's vetter card is being checked, with the desk
    /// already open: it closes again if the card no longer holds.
    @Default(false) bool checkingCard,

    /// The member's vetter card for the community, once checked.
    VtcVetterCard? vetterCard,

    /// What the community asks of vetting, once read.
    VettingRequirements? requirements,

    /// Whether the community's join manifest, which says what it asks of
    /// vetting, is being read.
    @Default(true) bool readingRequirements,

    /// The details the applicant of each session sent on their card, by
    /// request id, once checked. Held in memory only.
    @Default(<String, List<VettingCardClaim>>{})
    Map<String, List<VettingCardClaim>> cards,

    /// The statements the member issued for the community, as their VTA
    /// records them, newest first.
    @Default(<IssuedVettingStatement>[]) List<IssuedVettingStatement> issued,

    /// The session that ended while the desk was open, until the member
    /// goes back to the desk or shows a new ticket.
    VtcVetterSession? ended,

    /// How far creating a ticket got, while one is being created.
    VtcTicketStep? ticketStep,

    /// Whether a step the member asked for is running.
    @Default(false) bool busy,

    VtcVettingDeskFailure? failure,
  }) = _VtcVettingDeskState;

  VtcVettingDeskState._();

  /// The ticket to show: the newest still live at [now], or null.
  VetterTicket? liveTicket(DateTime now) => desk?.liveTickets(now).lastOrNull;

  /// The applicant being vetted: the newest open session, or null.
  VtcVetterSession? get current =>
      desk?.sessions.where((session) => session.isOpen).lastOrNull;

  /// The step of vetting an applicant the desk is at, at [now]: null while
  /// no ticket is on show and no applicant is being vetted.
  VtcVettingFlowStep? flowStep(DateTime now) => switch (current) {
    final session? when session.matchConfirmed => VtcVettingFlowStep.details,
    _? => VtcVettingFlowStep.match,
    null when ended != null => VtcVettingFlowStep.done,
    null when liveTicket(now) != null => VtcVettingFlowStep.ticket,
    null => null,
  };
}
