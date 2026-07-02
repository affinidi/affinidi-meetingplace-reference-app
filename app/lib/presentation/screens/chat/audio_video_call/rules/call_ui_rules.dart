import 'package:meeting_place_matrix/meeting_place_matrix.dart';

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

  /// Outgoing call, the peer's device is ringing. Label: "Ringing...".
  ringing,

  /// At least one peer has joined. Label: call duration timer.
  inCall,

  /// Call finished. Label: ended / declined / missed message.
  ended,
}

/// The specific end-state reason, derived purely from call status.
enum CallEndState {
  /// Peer did not answer the call.
  missedCall,

  /// Peer declined the incoming call.
  declinedCall,

  /// Call ended normally after both parties were connected.
  callEnded,
}

/// Converts the isAudioOnly flag to the SDK's CallMediaType enum.
CallMediaType getMediaTypeFromFlag(bool isAudioOnly) =>
    isAudioOnly ? CallMediaType.audio : CallMediaType.video;

/// Statuses in which a peer participant can legitimately be present.
///
/// A peer appearing in any earlier status (idle / connecting /
/// outgoingRinging) is a phantom and must NOT start the timer.
bool isLiveCallStatus(AudioVideoCallStatus status) =>
    status == AudioVideoCallStatus.waitingForKeys ||
    status == AudioVideoCallStatus.connected ||
    status == AudioVideoCallStatus.active;

/// Statuses in which a call is already underway and cannot be restarted.
bool isCallInProgress(AudioVideoCallStatus status) =>
    status == AudioVideoCallStatus.outgoingRinging ||
    status == AudioVideoCallStatus.connecting ||
    status == AudioVideoCallStatus.waitingForKeys ||
    status == AudioVideoCallStatus.active;

/// Statuses where the call is over and the UI shows an end-state.
bool isEndedCallStatus(AudioVideoCallStatus status) =>
    status == AudioVideoCallStatus.ended ||
    status == AudioVideoCallStatus.disconnected ||
    status == AudioVideoCallStatus.error ||
    status == AudioVideoCallStatus.missed ||
    status == AudioVideoCallStatus.declined;

/// Statuses where self has fully joined the call media session.
bool isConnectedCallStatus(AudioVideoCallStatus status) =>
    status == AudioVideoCallStatus.connected ||
    status == AudioVideoCallStatus.active;

/// Whether the participant list contains a peer (non-self) participant.
bool hasRemoteParticipant(List<AudioVideoCallParticipant> participants) =>
    participants.any((p) => !p.isSelf);

/// Latching rule: once a real peer participant has appeared during a live
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
/// Order matters: ended wins, then in-call (timer) once a peer has ever
/// joined, then ringing, then calling.
CallUiPhase resolveCallUiPhase({
  required AudioVideoCallStatus status,
  required bool hasHadPeer,
}) {
  if (isEndedCallStatus(status)) return CallUiPhase.ended;
  if (hasHadPeer) return CallUiPhase.inCall;
  if (status == AudioVideoCallStatus.outgoingRinging) {
    return CallUiPhase.ringing;
  }
  return CallUiPhase.calling;
}

/// Maps a terminal call status to the specific end-state scaffold to render,
/// or null if the call should be silently dismissed.
///
/// Returns [CallEndState.callEnded] for normal ends after a peer was connected,
/// [CallEndState.missedCall] / [CallEndState.declinedCall] for unanswered calls,
/// and null for errors and pre-connection endings. Only call this during
/// [CallUiPhase.ended].
CallEndState? resolveCallEndState(
  AudioVideoCallStatus status, {
  bool hasHadPeer = false,
}) {
  if (status == AudioVideoCallStatus.missed) return CallEndState.missedCall;
  if (status == AudioVideoCallStatus.declined) return CallEndState.declinedCall;
  if (hasHadPeer &&
      (status == AudioVideoCallStatus.ended ||
          status == AudioVideoCallStatus.disconnected)) {
    return CallEndState.callEnded;
  }
  return null;
}

/// Whether a 1-on-1 call should auto-end because the only peer has left.
///
/// True when all three conditions hold:
/// - This is not a group call ([isGroupContact] is false)
/// - A peer was connected at some point ([hasHadPeer] is true)
/// - No peer is currently present and the call is still live
///
/// Group calls stay open when participants leave; only individual calls
/// end automatically when the peer disconnects.
bool shouldAutoEndCallForPeer({
  required bool isGroupContact,
  required bool hasHadPeer,
  required List<AudioVideoCallParticipant> participants,
  required AudioVideoCallStatus status,
}) =>
    !isGroupContact &&
    hasHadPeer &&
    !hasRemoteParticipant(participants) &&
    isLiveCallStatus(status);
