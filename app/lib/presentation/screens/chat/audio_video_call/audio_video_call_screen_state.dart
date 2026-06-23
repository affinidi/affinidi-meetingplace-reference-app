import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show
        AudioVideoCallErrorCode,
        AudioVideoCallParticipant,
        AudioVideoCallSession,
        AudioVideoCallStatus;

import '../../../../domain/models/contact_card/contact_card.dart';

part 'audio_video_call_screen_state.freezed.dart';

/// Whether a participant change event represents people joining or leaving.
enum CallParticipantChangeType { joined, left }

/// A one-shot signal that remote participants joined or left the call.
///
/// A fresh instance is emitted for every change so the UI can react even to
/// consecutive identical changes; intentionally has no value equality.
class CallParticipantChangeEvent {
  CallParticipantChangeEvent({required this.type, required this.count});

  final CallParticipantChangeType type;
  final int count;
}

/// Identifies which non-fatal in-call action failed, so the UI can map it to a
/// targeted message. Mirrors the `AudioVideoCallErrorCode` enum pattern used
/// for fatal call-setup failures.
enum CallActionFailure { microphone, camera, speaker, memberNames, hangUp }

/// A one-shot signal that a non-fatal in-call action failed.
///
/// A fresh instance is emitted for every failure so the UI can surface a
/// snackbar even for consecutive identical failures; intentionally has no
/// value equality.
class CallActionFailureEvent {
  CallActionFailureEvent(this.action);

  final CallActionFailure action;
}

@Freezed(fromJson: false, toJson: false)
abstract class AudioVideoCallScreenState with _$AudioVideoCallScreenState {
  AudioVideoCallScreenState._();

  factory AudioVideoCallScreenState({
    @Default(AudioVideoCallStatus.idle) AudioVideoCallStatus status,
    @Default(false) bool isGroupContact,
    @Default('') String peerName,
    @Default({}) Map<String, ContactCard> memberContactCards,
    @Default(false) bool isAudioOnly,
    @Default(true) bool isMicEnabled,
    @Default(true) bool isCameraEnabled,
    @Default(false) bool isSpeakerEnabled,
    @Default([]) List<AudioVideoCallParticipant> participants,
    @Default(0) int callDurationSeconds,
    @Default(false) bool hasHadPeer,
    AudioVideoCallSession? session,
    AudioVideoCallErrorCode? errorCode,
    @Default(false) bool micPermissionError,
    @Default(false) bool cameraPermissionError,
    CallParticipantChangeEvent? participantEvent,
    CallActionFailureEvent? actionFailure,
    @Default(true) bool showControlsBar,
    int? focusedParticipantIndex,
    @Default(false) bool miniGridExpanded,
  }) = _AudioVideoCallScreenState;

  bool get isVisible =>
      status != AudioVideoCallStatus.idle &&
      status != AudioVideoCallStatus.ended &&
      status != AudioVideoCallStatus.disconnected &&
      status != AudioVideoCallStatus.error &&
      status != AudioVideoCallStatus.missed &&
      status != AudioVideoCallStatus.declined;
}
