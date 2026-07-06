import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import 'audio_video_call_screen_state.dart';

/// Carries the subset of session-state that changed in one stream emission.
///
/// Produced by CallSessionHandler and consumed by the controller via
/// `state.copyWith(...)`. All fields are nullable — only the ones that
/// actually changed are set. The [tick] flag signals a one-second duration
/// increment; no other fields are relevant when it is true.
class AudioVideoCallStateUpdate {
  const AudioVideoCallStateUpdate({
    this.status,
    this.participants,
    this.errorCode,
    this.isMicEnabled,
    this.isCameraEnabled,
    this.participantEvent,
    this.ownRole,
    this.hasHadPeer = false,
    this.peerJustJoined = false,
    this.tick = false,
    this.callStartedAt,
  });

  final AudioVideoCallStatus? status;
  final List<AudioVideoCallParticipant>? participants;
  final AudioVideoCallErrorCode? errorCode;
  final bool? isMicEnabled;
  final bool? isCameraEnabled;
  final CallParticipantChangeEvent? participantEvent;

  /// The device's authoritative call role as reported by the SDK, or null
  /// before the room's active-call membership has been resolved. The controller
  /// mirrors this into initiator-dependent logic (end-status, chat item).
  final CallRole? ownRole;

  /// The latched "a peer participant has joined at least once" value,
  /// computed by the call UI rules. Controller mirrors this into screen state.
  final bool hasHadPeer;

  /// True on the emission where the first peer participant joined.
  /// Controller starts the duration timer on this signal.
  final bool peerJustJoined;

  /// True for timer tick emissions — only callDurationSeconds should change.
  final bool tick;

  /// Shared call-start instant from the SDK, derived from the callId. The
  /// duration timer anchors to this so both parties display the same elapsed
  /// time. Null until the callId is resolved.
  final DateTime? callStartedAt;
}
