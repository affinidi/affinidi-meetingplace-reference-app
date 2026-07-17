import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'group_audio_call_state.dart';

part 'group_audio_call_controller.g.dart';

/// Controller for group audio call state.
@riverpod
class GroupAudioCallController extends _$GroupAudioCallController {
  bool _isDisposed = false;
  DateTime? _firstRemoteJoinedAt;

  @override
  GroupAudioCallState build(String groupContactId) {
    ref.onDispose(_dispose);
    return const GroupAudioCallState(
      participants: [],
      isRinging: true,
      firstJoinedAt: null,
      errorMessage: null,
      showControls: false,
    );
  }

  /// Respond to first participant joining.
  void onFirstParticipantJoined() {
    if (_isDisposed || _firstRemoteJoinedAt != null) return;
    _firstRemoteJoinedAt = DateTime.now();
    state = state.copyWith(
      firstJoinedAt: _firstRemoteJoinedAt,
      isRinging: false,
    );
  }

  /// Update the participants list.
  void updateParticipants(List<dynamic> participants) {
    if (_isDisposed) return;
    state = state.copyWith(
      participants: participants.map(_toParticipant).toList(growable: false),
    );
  }

  /// Toggle microphone.
  Future<void> toggleMic() async {
    if (_isDisposed) return;
  }

  /// Leave the call.
  Future<void> leaveCall() async {
    if (_isDisposed) return;
  }

  /// Cleanup.
  void _dispose() {
    _isDisposed = true;
  }

  /// Converts raw SDK participant data to typed UI state model.
  GroupAudioCallParticipant _toParticipant(dynamic participant) {
    if (participant is Map) {
      return GroupAudioCallParticipant(
        displayName: _resolveDisplayName(participant),
        isMuted: participant['isMuteAudio'] as bool? ?? false,
        isSelf: participant['isSelf'] as bool? ?? false,
      );
    }

    return const GroupAudioCallParticipant(
      displayName: '',
      isMuted: false,
      isSelf: false,
    );
  }

  /// Extracts display name from participant data, falling back to DID suffix
  /// if unavailable.
  String _resolveDisplayName(Map<dynamic, dynamic> participant) {
    final displayName = participant['displayName'] as String?;
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final did = participant['did'] as String?;
    if (did != null && did.isNotEmpty) return did.split(':').last;

    return '';
  }
}
