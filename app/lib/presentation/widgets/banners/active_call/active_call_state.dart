import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallStatus;

part 'active_call_state.freezed.dart';

/// State snapshot of the current outgoing or active call.
///
/// Written by the audio-video call screen controller whenever its state
/// changes. Cleared when the call reaches a terminal state (ended,
/// disconnected, or error). Read by the active call banner to show the
/// persistent in-app call row.
@freezed
abstract class ActiveCallState with _$ActiveCallState {
  /// State snapshot of the current outgoing or active call.
  ///
  /// Written by the audio-video call screen controller whenever its state
  /// changes. Cleared when the call reaches a terminal state (ended,
  /// disconnected, or error). Read by the active call banner to show the
  /// persistent in-app call row.
  const factory ActiveCallState({
    required String contactId,
    required String peerName,
    required AudioVideoCallStatus status,
    required int callDurationSeconds,
    required bool isMicEnabled,
    required bool isAudioOnly,
    @Default(false) bool hasHadPeer,
    @Default(false) bool isMinimized,
    @Default(true) bool isCameraEnabled,
  }) = _ActiveCallState;
}
