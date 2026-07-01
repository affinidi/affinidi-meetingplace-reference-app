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
    this.isSpeakerEnabled,
    this.attachedSession,
    this.clearIncomingCall = false,
    this.endOutcome,
    this.reportHangUpFailure = false,
  });

  /// New call status, if the transition changes it.
  final AudioVideoCallStatus? status;

  /// New speakerphone state, set when a call starts.
  final bool? isSpeakerEnabled;

  /// A freshly started session the controller should attach.
  final AudioVideoCallSession? attachedSession;

  /// Whether the kept-alive incoming-call state should be cleared.
  final bool clearIncomingCall;

  /// When set, the controller writes the terminal call chat item.
  final CallEndOutcome? endOutcome;

  /// Whether a non-fatal hang-up failure should be surfaced to the UI.
  final bool reportHangUpFailure;
}
