import 'package:meeting_place_chat/meeting_place_chat.dart'
    show
        AudioVideoCallErrorCode,
        AudioVideoCallParticipant,
        AudioVideoCallStatus,
        CallRole;

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

  /// The latched "a remote participant has joined at least once" value,
  /// computed by the call UI rules. Controller mirrors this into screen state.
  final bool hasHadPeer;

  /// True on the emission where the first remote participant joined.
  /// Controller starts the duration timer on this signal.
  final bool peerJustJoined;

  /// True for timer tick emissions — only callDurationSeconds should change.
  final bool tick;
}
