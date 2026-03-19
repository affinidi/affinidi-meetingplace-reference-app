import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../../infrastructure/services/livekit_service/livekit_service.dart';
import '../../../widgets/async_loaders/async_loading_controller.dart';
import 'video_call_screen_state.dart';

part 'video_call_screen_controller.g.dart';

@riverpod
class VideoCallScreenController extends _$VideoCallScreenController {
  static const _logKey = 'VideoCallScreen';

  late final _logger = ref.read(appLoggerProvider);
  late final participantEventLoadingController =
      AsyncLoadingController.provider('participantEventLoadingController');
  late final _livekitService = LiveKitService(
    serverUrl: ref.read(environmentProvider).livekitUrl,
    apiKey: ref.read(environmentProvider).livekitApiKey,
    apiSecret: ref.read(environmentProvider).livekitApiSecret,
    logger: ref.read(appLoggerProvider),
  );

  StreamSubscription<matrix.MatrixRTCCallEvent>? _matrixRtcSubscription;

  @override
  VideoCallScreenState build(String roomId, String contactId) {
    Future(() async {
      if (state.status == VideoCallStatus.idle) {
        await joinCall();
      }
    });

    ref.onDispose(_cleanup);
    return const VideoCallScreenState();
  }

  Future<void> joinCall() async {
    if (state.status == VideoCallStatus.connected ||
        state.status == VideoCallStatus.connecting)
      return;
    state = state.copyWith(status: VideoCallStatus.connecting);

    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);

      // 1. Signal call membership via MatrixRTC (publishes m.call.member).
      await sdk.startVideoCall(
        roomId: roomId,
        livekitServiceUrl: _livekitService.serverUrl,
        livekitAlias: roomId,
        callId: roomId,
      );

      // 2. Subscribe to MatrixRTC membership events — useful for showing
      // join/leave toasts before LiveKit participant events arrive.
      final matrixRtcStream = sdk.watchVideoCall(
        roomId: roomId,
        callId: roomId,
      );
      if (matrixRtcStream != null) {
        _matrixRtcSubscription = matrixRtcStream.listen(_onMatrixRTCEvent);
      }

      // 3. Connect to LiveKit SFU for actual audio/video.
      await _livekitService.connect(
        roomId: roomId,
        participantId: contactId,
        onParticipantsChanged: () => state = state.copyWith(
          participants: _livekitService.getParticipants(),
        ),
        onDisconnected: () {
          // Only reset to idle on an intentional disconnect, not on a
          // failed connect attempt — otherwise the screen re-triggers joinCall.
          if (state.status == VideoCallStatus.connected) {
            state = const VideoCallScreenState();
          }
        },
      );
      await _livekitService.setMicrophoneEnabled(true);

      state = state.copyWith(
        status: VideoCallStatus.connected,
        participants: _livekitService.getParticipants(),
        isMicEnabled: true,
      );

      _logger.info('Joined video call for room $roomId', name: _logKey);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to join video call',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      state = state.copyWith(status: VideoCallStatus.error, error: error);
    }
  }

  Future<void> leaveCall() async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    await sdk.leaveVideoCall(roomId: roomId, callId: roomId);
    await _cleanup();
    state = const VideoCallScreenState();
  }

  Future<void> toggleMic() async {
    final next = !state.isMicEnabled;
    await _livekitService.setMicrophoneEnabled(next);
    state = state.copyWith(isMicEnabled: next);
  }

  Future<void> toggleCamera() async {
    final next = !state.isCameraEnabled;
    await _livekitService.setCameraEnabled(next);
    state = state.copyWith(isCameraEnabled: next);
  }

  void _onMatrixRTCEvent(matrix.MatrixRTCCallEvent event) {
    _logger.info('MatrixRTC event: $event', name: _logKey);

    if (event is! matrix.ParticipantsChangeEvent) return;

    ref.read(participantEventLoadingController.notifier).start(() async {
      switch (event) {
        case matrix.ParticipantsJoinEvent(:final participants):
          final names = participants.map((p) => p.userId).join(', ');
          state = state.copyWith(matrixEventMessage: '$names joined');
        case matrix.ParticipantsLeftEvent(:final participants):
          final names = participants.map((p) => p.userId).join(', ');
          state = state.copyWith(matrixEventMessage: '$names left');
      }
    });
  }

  Future<void> _cleanup() async {
    await _matrixRtcSubscription?.cancel();
    _matrixRtcSubscription = null;
    await _livekitService.disconnect();
  }
}
