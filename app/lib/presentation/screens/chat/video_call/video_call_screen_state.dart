import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:livekit_client/livekit_client.dart';

part 'video_call_screen_state.freezed.dart';

enum VideoCallStatus { idle, connecting, connected, error }

@Freezed(fromJson: false, toJson: false)
abstract class VideoCallScreenState with _$VideoCallScreenState {
  const VideoCallScreenState._();

  const factory VideoCallScreenState({
    @Default(VideoCallStatus.idle) VideoCallStatus status,
    @Default([]) List<Participant> participants,
    @Default(false) bool isMicEnabled,
    @Default(false) bool isCameraEnabled,
    @Default({}) Map<String, String> memberNames,
    Object? error,
    String? matrixEventMessage,
  }) = _VideoCallScreenState;

  bool get isConnecting => status == VideoCallStatus.connecting;
  bool get isConnected => status == VideoCallStatus.connected;
  bool get hasError => status == VideoCallStatus.error;
}
