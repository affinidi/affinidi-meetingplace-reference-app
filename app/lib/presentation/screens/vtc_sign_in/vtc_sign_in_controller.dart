import 'dart:async';

import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import 'vtc_sign_in_state.dart';

part 'vtc_sign_in_controller.g.dart';

/// Drives one sign-in to a community's portal or console, from the scanned
/// code to the member's approval.
///
/// A claimed sign-in that is left before it is approved is cancelled, unless
/// the grant may already have been sent. Nothing is logged.
@riverpod
class VtcSignInController extends _$VtcSignInController {
  late final VtcService _service = ref.read(vtcServiceProvider);
  late final OobSignInClient _signIn = _service.signInClient();

  TriggerLinkAccepted? _trigger;
  CommunityMembership? _membership;
  ClaimedSignIn? _claimed;
  ProvedSignIn? _proved;

  @override
  VtcSignInState build() {
    ref.onDispose(_cancelIfOpen);
    return VtcSignInState();
  }

  /// Reads a scanned code and, for a sign-in code, claims it.
  Future<void> onScanned(String code) async {
    if (state.step != VtcSignInStep.scanning) return;
    state = state.copyWith(step: VtcSignInStep.working);

    final result = _service.readLink(code);
    final problem = result.uiFor(TriggerLinkConfig.meetingPlace);
    if (result is! TriggerLinkAccepted || problem != null) {
      state = state.copyWith(
        step: VtcSignInStep.failed,
        linkProblem: problem == TriggerLinkUi.passOn
            ? TriggerLinkUi.invalid
            : problem ?? TriggerLinkUi.invalid,
      );
      return;
    }
    _trigger = result;

    await _run(() async {
      final recorded = await _service.recordedMembership(result.from);
      if (recorded != null) {
        _membership = recorded;
        await _claim();
        return;
      }

      final imported = await _service.importMembership(result.from);
      if (imported == null) {
        throw const SignInException(SignInFailure.notAMember);
      }
      _membership = imported;
      state = state.copyWith(
        step: VtcSignInStep.confirmMembership,
        communityName: imported.name ?? imported.communityDid,
        personaDid: imported.persona.did,
      );
    });
  }

  /// Uses the membership found on the VTA and claims the sign-in.
  Future<void> confirmMembership() async {
    final membership = _membership;
    if (state.step != VtcSignInStep.confirmMembership || membership == null) {
      return;
    }
    state = state.copyWith(step: VtcSignInStep.working);
    await _run(() async {
      await _service.rememberMembership(membership);
      await _claim();
    });
  }

  /// Tells the community who signs in, with the number the member typed.
  Future<void> submitNumber(String number) async {
    final claimed = _claimed;
    final membership = _membership;
    if (state.step != VtcSignInStep.number ||
        claimed == null ||
        membership == null) {
      return;
    }
    state = state.copyWith(step: VtcSignInStep.working, failure: null);

    await _run(() async {
      try {
        final proved = await _signIn.prove(
          claimed,
          enteredNumber: number,
          persona: await _service.preparePersona(membership),
          agent: await _service.agent(),
        );
        _proved = proved;
        state = state.copyWith(
          step: VtcSignInStep.review,
          personaDid: proved.persona.did,
          requester: proved.requester,
        );
      } on SignInException catch (error) {
        if (error.failure != SignInFailure.badNumber) rethrow;
        state = state.copyWith(
          step: VtcSignInStep.number,
          failure: SignInFailure.badNumber,
        );
      }
    });
  }

  /// Approves the sign-in with the biometric approval key.
  Future<void> approve() async {
    final proved = _proved;
    if (state.step != VtcSignInStep.review || proved == null) return;
    state = state.copyWith(step: VtcSignInStep.working);

    await _run(() async {
      await _signIn.approve(
        proved,
        agent: await _service.agent(),
        userVerification: await _service.approvalSigner(),
      );
      state = state.copyWith(step: VtcSignInStep.approved);
    });
  }

  /// Declines the sign-in. A declined request is cancelled, never granted.
  Future<void> decline() async {
    await _cancelIfOpen();
    state = state.copyWith(step: VtcSignInStep.declined);
  }

  /// Ends the sign-in when its decision deadline passes.
  void expire() {
    if (!_isOpen) return;
    _claimed = null;
    state = state.copyWith(
      step: VtcSignInStep.failed,
      failure: SignInFailure.expired,
    );
  }

  Future<void> _claim() async {
    final claimed = await _signIn.claim(_trigger!);
    _claimed = claimed;
    state = state.copyWith(
      step: VtcSignInStep.number,
      communityName:
          _membership?.name ?? state.communityName ?? claimed.vtc.did,
      website: claimed.origin,
      audience: claimed.audience,
      decisionDeadline: claimed.decisionDeadline,
    );
  }

  Future<void> _run(Future<void> Function() step) async {
    try {
      await step();
    } on SignInException catch (error) {
      if (error.responded) _claimed = null;
      await _cancelIfOpen();
      state = state.copyWith(
        step: VtcSignInStep.failed,
        failure: error.failure,
      );
    } on VtaNotLinkedException {
      state = state.copyWith(step: VtcSignInStep.failed, isVtaMissing: true);
    } on MeetingPlaceVtcSDKException {
      await _cancelIfOpen();
      state = state.copyWith(
        step: VtcSignInStep.failed,
        failure: SignInFailure.agentUnreachable,
      );
    }
  }

  bool get _isOpen => _claimed != null && !_claimed!.responded;

  /// Cancels a claimed sign-in that has not been responded to. Best effort:
  /// an unanswered cancel lets the request expire on its own.
  Future<void> _cancelIfOpen() async {
    final claimed = _claimed;
    _claimed = null;
    if (claimed == null || claimed.responded) return;
    try {
      await _signIn.cancel(claimed);
    } on Exception {
      // The request expires on its own within two minutes.
    }
  }
}
