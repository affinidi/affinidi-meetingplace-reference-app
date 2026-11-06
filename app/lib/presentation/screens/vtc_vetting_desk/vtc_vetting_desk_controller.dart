import 'dart:async';

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
      state = state.copyWith(
        step: VtcVettingDeskStep.open,
        desk: desk,
        checkingCard: true,
      );
      // Read alongside the card check; the desk shows them once read.
      unawaited(_readRequirements());
      final canVet = await _service.canVet(communityDid);
      state = state.copyWith(
        checkingCard: false,
        step: canVet ? state.step : VtcVettingDeskStep.notVetter,
      );
      if (!canVet) return;
      _check ??= Timer.periodic(checkInterval, (_) => unawaited(check()));
      await check();
      await readIssued();
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
    }
  }

  Future<void> _readRequirements() async {
    try {
      state = state.copyWith(
        requirements: await _service.vettingRequirements(communityDid),
      );
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
    } finally {
      state = state.copyWith(readingRequirements: false);
    }
  }

  /// Picks up what applicants sent, and shows where each session stands.
  Future<void> check() async {
    if (_checking || state.step != VtcVettingDeskStep.open) return;
    _checking = true;
    try {
      final desk = await _service.checkVetterDesk(communityDid);
      state = state.copyWith(desk: desk, cards: _cards(desk));
    } on Exception catch (error, stackTrace) {
      _fail(error, stackTrace);
    } finally {
      _checking = false;
    }
  }

  /// Shows a new ticket, good for one applicant for a short while.
  Future<void> createTicket() => _run(() async {
    await _service.createVettingTicket(communityDid);
    state = state.copyWith(desk: await _service.vetterDesk(communityDid));
  });

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
        state = state.copyWith(desk: desk, cards: _cards(desk));
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
        state = state.copyWith(desk: desk, cards: _cards(desk));
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
      state = state.copyWith(busy: false);
    }
  }

  void _fail(Exception error, StackTrace stackTrace) {
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
