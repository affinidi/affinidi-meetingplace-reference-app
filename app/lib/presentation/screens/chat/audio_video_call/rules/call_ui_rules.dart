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
bool hasPeerParticipant(List<AudioVideoCallParticipant> participants) =>
    participants.any((p) => !p.isSelf);

/// The peer participant owns the main canvas in the minimized 1:1 video UI.
///
/// The self participant stays in a smaller lower-right inset so restoring the
/// call preserves the same mental model as the full-screen video layout:
/// peer is primary once available, self is secondary.
AudioVideoCallParticipant? primaryParticipantForMinimizedVideoCall(
  List<AudioVideoCallParticipant> participants,
) {
  for (final participant in participants) {
    if (!participant.isSelf) return participant;
  }
  return null;
}

/// Latching rule: once connected to a live peer, stays `true` for the call.
///
/// Connection proven by connected status (peer established E2EE) AND peer
/// presence. Prevents false-connect/false-end from stale ghosts or
/// phantom participants. Never flips back. This is the only place the
/// latch is computed.
bool computeHasHadPeer({
  required bool previous,
  required AudioVideoCallStatus status,
  required List<AudioVideoCallParticipant> participants,
}) {
  if (previous) return true;
  return isConnectedCallStatus(status) && hasPeerParticipant(participants);
}

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

/// Maps an ended call status to the specific end-state scaffold to render,
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

/// Whether to show the no-answer scaffold when the call ends without a
/// connection.
///
/// Returns false when the peer is calling back — in that case the screen stays
/// neutral so the user can answer from the incoming-call banner without seeing
/// a misleading "no answer" message.
bool shouldShowNoAnswerScreen({
  required CallEndState? endState,
  required bool peerIsCallingBack,
}) =>
    endState != null &&
    endState != CallEndState.callEnded &&
    !peerIsCallingBack;

/// A call cancelled before the peer ever joined (ended, no end-state, no
/// calling-back screen, not a join failure) renders nothing — the screen
/// must pop on its own in that case, otherwise the caller's manual end of a
/// still-ringing call has no reactive path back to the chat.
bool isEndedWithNoScreen({
  required CallUiPhase phase,
  required CallEndState? endState,
  required bool peerIsCallingBack,
  required bool isJoinFailure,
}) =>
    phase == CallUiPhase.ended &&
    endState == null &&
    !peerIsCallingBack &&
    !isJoinFailure;
