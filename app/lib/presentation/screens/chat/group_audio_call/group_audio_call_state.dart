import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_audio_call_state.freezed.dart';

@freezed
abstract class GroupAudioCallParticipant with _$GroupAudioCallParticipant {
  const factory GroupAudioCallParticipant({
    required String displayName,
    required bool isMuted,
    required bool isSelf,
  }) = _GroupAudioCallParticipant;

  const GroupAudioCallParticipant._();
}

/// State for group audio call screen.
@freezed
// ignore: non_abstract_class_inherits_abstract_member
class GroupAudioCallState with _$GroupAudioCallState {
  const factory GroupAudioCallState({
    /// Participants currently in the call (self + remotes).
    required List<GroupAudioCallParticipant> participants,

    /// Whether the call is in ringing state (waiting for first join).
    required bool isRinging,

    /// Time when the first remote participant joined (null if none yet).
    DateTime? firstJoinedAt,

    /// Error message if something went wrong (null if no error).
    String? errorMessage,

    /// Whether controls (mute button) should be visible.
    required bool showControls,
  }) = _GroupAudioCallState;

  const GroupAudioCallState._();

  /// Returns the number of participants in the call.
  int get participantCount => participants.length;

  /// Returns true if there's more than one participant.
  bool get isMultiParticipant => participantCount > 1;
}
