import 'audio_video_call_screen_state.dart';

/// Carries the subset of media-device state that changed after one toggle or
/// permission check.
///
/// Produced by `CallMediaToggleHandler` and consumed by the controller via
/// `state.copyWith(...)`. All fields are nullable — only the ones that
/// actually changed are set.
class CallMediaUpdate {
  const CallMediaUpdate({
    this.isMicEnabled,
    this.micPermissionError,
    this.isCameraEnabled,
    this.cameraPermissionError,
    this.isSpeakerEnabled,
    this.failure,
  });

  final bool? isMicEnabled;
  final bool? micPermissionError;
  final bool? isCameraEnabled;
  final bool? cameraPermissionError;
  final bool? isSpeakerEnabled;
  final CallActionFailure? failure;
}
