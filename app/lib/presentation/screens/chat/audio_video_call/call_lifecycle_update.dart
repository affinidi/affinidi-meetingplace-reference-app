import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import 'rules/call_chat_item_rules.dart';

/// Carries the call-lifecycle side effects produced by one join/cancel/leave
/// transition.
///
/// Produced by `CallLifecycleHandler` and applied by the controller. Only the
/// fields relevant to a given transition are set; the rest stay null/false.
class CallLifecycleUpdate {
  const CallLifecycleUpdate({
    this.status,
    this.errorCode,
    this.isSpeakerEnabled,
    this.attachedSession,
    this.clearIncomingCall = false,
    this.endOutcome,
    this.reportHangUpFailure = false,
  });

  /// New call status, if the transition changes it.
  final AudioVideoCallStatus? status;

  /// Localized by the app when a join attempt fails before a session attaches.
  final AudioVideoCallErrorCode? errorCode;

  /// New speakerphone state, set when a call starts.
  final bool? isSpeakerEnabled;

  /// A freshly started session the controller should attach.
  final AudioVideoCallSession? attachedSession;

  /// Whether the kept-alive incoming-call state should be cleared.
  final bool clearIncomingCall;

  /// When set, the controller writes the ended call chat item.
  final CallEndOutcome? endOutcome;

  /// Whether a non-fatal hang-up failure should be surfaced to the UI.
  final bool reportHangUpFailure;
}
