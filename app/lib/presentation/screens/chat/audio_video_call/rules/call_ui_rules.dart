import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallParticipant, AudioVideoCallStatus, CallMediaType;

/// Single source of truth for what the call UI shows at every stage.
///
/// Every Calling / Ringing / timer decision in the call screen and the active
/// call banner is derived from the pure functions in this file. Widgets and
/// controllers must NEVER re-derive these rules with ad-hoc `if` chains — add
/// or change a rule here and the whole UI follows.

/// The phase the UI renders, derived purely from call state.
enum CallUiPhase {
  /// Outgoing call, contacting the other party. Label: "Calling...".
  calling,

  /// Outgoing call, the other party's device is ringing. Label: "Ringing...".
  ringing,

  /// At least one remote participant has joined. Label: call duration timer.
  inCall,

  /// Call finished. Label: ended / declined / missed message.
  ended,
}

/// The specific end-state reason, derived purely from call status.
enum CallEndState {
  /// Remote did not answer the call.
  missedCall,

  /// Remote declined the incoming call.
  declinedCall,
}

/// Converts the isAudioOnly flag to the SDK's CallMediaType enum.
CallMediaType getMediaTypeFromFlag(bool isAudioOnly) =>
    isAudioOnly ? CallMediaType.audio : CallMediaType.video;

/// Statuses in which a remote participant can legitimately be present.
///
/// A remote appearing in any earlier status (idle / connecting /
/// outgoingRinging) is a phantom and must NOT start the timer.
bool isLiveCallStatus(AudioVideoCallStatus status) =>
    status == AudioVideoCallStatus.waitingForKeys ||
    status == AudioVideoCallStatus.connected ||
    status == AudioVideoCallStatus.active;

/// Statuses where the call is over and the UI shows an end-state.
bool isTerminalCallStatus(AudioVideoCallStatus status) =>
    status == AudioVideoCallStatus.ended ||
    status == AudioVideoCallStatus.disconnected ||
    status == AudioVideoCallStatus.error ||
    status == AudioVideoCallStatus.missed ||
    status == AudioVideoCallStatus.declined;

/// Whether the participant list contains a remote (non-local) participant.
bool hasRemoteParticipant(List<AudioVideoCallParticipant> participants) =>
    participants.any((p) => !p.isSelf);

/// Latching rule: once a real remote participant has appeared during a live
/// status, the result stays `true` for the rest of the call.
///
/// Leave / rejoin and minimize / maximize never flip it back. This is the only
/// place the latch is computed.
bool computeHasHadPeer({
  required bool previous,
  required List<AudioVideoCallParticipant> participants,
  required AudioVideoCallStatus status,
}) =>
    previous ||
    (isLiveCallStatus(status) && hasRemoteParticipant(participants));

/// The single rule that maps call state to the displayed [CallUiPhase].
///
/// Order matters: terminal wins, then in-call (timer) once a remote has ever
/// joined, then ringing, then calling.
CallUiPhase resolveCallUiPhase({
  required AudioVideoCallStatus status,
  required bool hasHadPeer,
}) {
  if (isTerminalCallStatus(status)) return CallUiPhase.ended;
  if (hasHadPeer) return CallUiPhase.inCall;
  if (status == AudioVideoCallStatus.outgoingRinging) {
    return CallUiPhase.ringing;
  }
  return CallUiPhase.calling;
}

/// Maps a terminal call status to the specific end-state scaffold to render,
/// or null if the call ended normally.
///
/// Returns [CallEndState] for special endings (missed/declined) or null for
/// normal ends, errors, etc. Only call this during [CallUiPhase.ended].
CallEndState? resolveCallEndState(AudioVideoCallStatus status) {
  if (status == AudioVideoCallStatus.missed) return CallEndState.missedCall;
  if (status == AudioVideoCallStatus.declined) return CallEndState.declinedCall;
  return null;
}
