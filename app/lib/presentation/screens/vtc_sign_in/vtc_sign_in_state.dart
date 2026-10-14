import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

part 'vtc_sign_in_state.freezed.dart';

/// Where a community sign-in stands.
enum VtcSignInStep {
  /// Waiting for a sign-in code to be scanned.
  scanning,

  /// A membership was found on the VTA; the member confirms using it.
  confirmMembership,

  /// Sending a request; nothing to do but wait.
  working,

  /// The member types the number the browser shows.
  number,

  /// The member reviews who asks to sign in and approves or declines.
  review,

  /// The browser is signed in.
  approved,

  /// The member declined.
  declined,

  /// The sign-in could not go ahead.
  failed,
}

@Freezed(fromJson: false, toJson: false)
abstract class VtcSignInState with _$VtcSignInState {
  factory VtcSignInState({
    @Default(VtcSignInStep.scanning) VtcSignInStep step,
    String? communityName,
    String? website,
    @Default(SignInAudience.member) SignInAudience audience,
    String? personaDid,
    SignInRequester? requester,
    int? decisionDeadline,
    SignInFailure? failure,
    TriggerLinkUi? linkProblem,
    @Default(false) bool isVtaMissing,
  }) = _VtcSignInState;
}
