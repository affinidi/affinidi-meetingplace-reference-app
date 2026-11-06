import 'dart:async';

import 'package:clock/clock.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/vtc_vetter_desk.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'vtc_vetting_desk_state.dart';

part 'vtc_vetting_desk_controller.g.dart';

/// Drives the member's vetting desk for one community: shows a ticket, and
/// vets each applicant who comes with it. Only a failure's type is logged;
/// never a DID, a detail from a card or a document.
@riverpod
class VtcVettingDeskController extends _$VtcVettingDeskController {
  late final VtcService _service = ref.read(vtcServiceProvider);

  /// How often applicants' messages are picked up while the desk is open.
  static const checkInterval = Duration(seconds: 5);

  /// How often they are picked up while the vetter waits on the applicant,
  /// so the next step shows as soon as they act.
  static const waitingCheckInterval = Duration(seconds: 1);

  /// When applicants' messages were last picked up.
  DateTime? _checkedAt;

  /// What the vetter says when the match codes differ.
  static const mismatchMessage = 'match code differs';

  Timer? _check;

  /// Whether applicants' messages are being picked up; checks do not
  /// overlap.
  bool _checking = false;

  @override
  VtcVettingDeskState build(String communityDid) {
    ref.onDispose(() {
      _check?.cancel();
      // Forget the identity's keys the VTA lent for the desk.
      unawaited(_service.endCardCollection(communityDid));
    });
    unawaited(_load());
    return VtcVettingDeskState();
  }

  /// Opens the desk as recorded at once, then checks the vetter card: the
  /// community page just offered the desk for a card that held, and a
  /// ticket is minted only once the card is checked again.
  Future<void> _load() async {
    try {
      final desk = await _service.vetterDesk(communityDid);
      // The desk may have closed while it was read.
      if (!ref.mounted) return;
      state = state.copyWith(
        step: VtcVettingDeskStep.open,
        desk: desk,
        checkingCard: true,
      );
      // Read alongside the card check; the desk shows them once read.
      unawaited(_readRequirements());
      final vetterCard = await _service.vetterCard(communityDid);
      if (!ref.mounted) return;
      state = state.copyWith(
        checkingCard: false,
        vetterCard: vetterCard,
        step: vetterCard != null ? state.step : VtcVettingDeskStep.notVetter,
      );
      if (vetterCard == null) return;
      _check ??= Timer.periodic(
        waitingCheckInterval,
        (_) => unawaited(_checkWhenDue()),
      );
      await check();
      await readIssued();
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
    }
  }

  Future<void> _readRequirements() async {
    try {
      final requirements = await _service.vettingRequirements(communityDid);
      if (ref.mounted) state = state.copyWith(requirements: requirements);
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
    } finally {
      if (ref.mounted) state = state.copyWith(readingRequirements: false);
    }
  }

  /// Picks up what applicants sent once [checkInterval] passed since the
  /// last time, or [waitingCheckInterval] while the vetter waits on them.
  Future<void> _checkWhenDue() async {
    final now = clock.now();
    final interval = state.waitingOnApplicant(now)
        ? waitingCheckInterval
        : checkInterval;
    final checkedAt = _checkedAt;
    if (checkedAt != null && now.difference(checkedAt) < interval) return;
    await check();
  }

  /// Picks up what applicants sent, and shows where each session stands.
  Future<void> check() async {
    if (_checking || state.step != VtcVettingDeskStep.open) return;
    _checking = true;
    _checkedAt = clock.now();
    try {
      final desk = await _service.checkVetterDesk(
        communityDid,
        onRequestStep: (step) {
          if (ref.mounted) state = state.copyWith(requestStep: step);
        },
        // Read once for the desk, rather than for each applicant.
        requiredClaims: state.readingRequirements
            ? null
            : VtcService.vettingClaimsOf(state.requirements),
      );
      _showDesk(desk);
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
    } finally {
      _checking = false;
      if (ref.mounted) state = state.copyWith(requestStep: null);
    }
  }

  /// Shows a new ticket, good for one applicant for a short while, saying
  /// how far creating it got.
  Future<void> createTicket() => _run(() async {
    try {
      await _service.createVettingTicket(
        communityDid,
        onStep: (step) {
          if (ref.mounted) state = state.copyWith(ticketStep: step);
        },
      );
      final desk = await _service.vetterDesk(communityDid);
      if (ref.mounted) state = state.copyWith(desk: desk, ended: null);
    } finally {
      if (ref.mounted) state = state.copyWith(ticketStep: null);
    }
  });

  /// Starts vetting an applicant: creates a ticket unless one is on show,
  /// an applicant is being vetted, or a ticket is being created already.
  Future<void> startVetting() async {
    if (state.flowStep(clock.now()) != null ||
        state.ticketStep != null ||
        state.busy) {
      return;
    }
    await createTicket();
  }

  /// Records that the codes match, with the applicant present.
  Future<void> confirmMatch(String requestId) => _run(() async {
    state = state.copyWith(
      desk: await _service.confirmVettingMatch(communityDid, requestId),
    );
  });

  /// Ends the session because the codes differ.
  Future<void> mismatch(String requestId) =>
      decline(requestId, message: mismatchMessage);

  /// Issues the applicant a statement: the member checked their details in
  /// person against [documentClasses].
  Future<void> issue(String requestId, List<String> documentClasses) =>
      _run(() async {
        final desk = await _service.issueVettingStatement(
          communityDid,
          requestId,
          documentClasses: documentClasses,
        );
        _showDesk(desk);
        await readIssued();
      });

  /// Tells the applicant the member will not vouch for them.
  Future<void> decline(String requestId, {String? code, String? message}) =>
      _run(() async {
        final desk = await _service.declineVetting(
          communityDid,
          requestId,
          code: code,
          message: message,
        );
        _showDesk(desk);
      });

  /// Reads the statements the member issued, as their VTA records them.
  Future<void> readIssued() async {
    try {
      state = state.copyWith(
        issued: await _service.issuedVettingStatements(communityDid),
      );
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
    }
  }

  /// Goes back to the desk from a session that ended.
  void backToDesk() => state = state.copyWith(ended: null);

  /// Shows [desk], and the session that just ended on it, if one did.
  void _showDesk(VtcVetterDesk? desk) {
    final wasOpen = {
      for (final session in state.desk?.sessions ?? const <VtcVetterSession>[])
        if (session.isOpen) session.request.requestId,
    };
    final ended = desk?.sessions
        .where(
          (session) =>
              !session.isOpen && wasOpen.contains(session.request.requestId),
        )
        .lastOrNull;
    state = state.copyWith(
      desk: desk,
      cards: _cards(desk),
      ended: ended ?? state.ended,
    );
  }

  /// The checked cards of [desk]'s open sessions, by request id.
  Map<String, List<VettingCardClaim>> _cards(VtcVetterDesk? desk) => {
    for (final session in desk?.sessions ?? const <VtcVetterSession>[])
      if (session.isOpen)
        if (_service.vettingCard(session.request.requestId) case final card?)
          session.request.requestId: card.claims,
  };

  Future<void> _run(Future<void> Function() step) async {
    state = state.copyWith(busy: true, failure: null);
    try {
      await step();
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  void _fail(Exception error, StackTrace stackTrace) {
    // The desk may have closed while the step ran.
    if (!ref.mounted) return;
    ref
        .read(appLoggerProvider)
        .error(
          'A vetting desk step failed: ${switch (error) {
            MeetingPlaceVtcSDKException(:final code) => code.name,
            _ => error.runtimeType,
          }}',
          stackTrace: stackTrace,
          name: 'VtcVettingDeskController',
        );
    final failure = error is NotVetterException
        ? VtcVettingDeskFailure.notVetter
        : VtcVettingDeskFailure.unreachable;
    state = state.copyWith(
      failure: failure,
      checkingCard: false,
      step: failure == VtcVettingDeskFailure.notVetter
          ? VtcVettingDeskStep.notVetter
          : state.step,
    );
  }
}
