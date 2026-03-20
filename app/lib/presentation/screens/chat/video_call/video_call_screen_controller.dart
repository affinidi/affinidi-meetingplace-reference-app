import 'dart:async';

import 'package:matrix/matrix.dart' as matrix;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../infrastructure/providers/matrix_rtc_delegate_provider.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../../infrastructure/services/livekit_service/livekit_service.dart';
import '../../../../infrastructure/services/livekit_service/livekit_token_service.dart';
import '../../../../infrastructure/services/livekit_service/matrix_livekit_key_provider.dart';
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
        state.status == VideoCallStatus.connecting) {
      return;
    }
    state = state.copyWith(status: VideoCallStatus.connecting);

    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);

      // 1. Set up E2EE key provider BEFORE starting the Matrix call.
      //    session.enter() inside startVideoCall immediately generates the
      //    local sender key and calls onSetEncryptionKey — the delegate must
      //    already have a key provider installed or that key is silently
      //    dropped, causing FrameCryptorStateMissingKey on the LiveKit side.
      final env = ref.read(environmentProvider);
      final tokenServerUrl = env.livekitTokenServerUrl;
      final MatrixLiveKitKeyProvider keyProvider;
      final String? livekitToken;
      if (tokenServerUrl != null) {
        final tokenService = LiveKitTokenService(serverUrl: tokenServerUrl);
        final tokenResponse = await tokenService.fetchToken(
          roomId: roomId,
          participantId: contactId,
        );
        keyProvider = await MatrixLiveKitKeyProvider.fromKey(
          e2eeKey: tokenResponse.e2eeKey,
          logger: _logger,
        );
        livekitToken = tokenResponse.token;
      } else {
        keyProvider = await MatrixLiveKitKeyProvider.create(logger: _logger);
        livekitToken = null; // generateDevToken() used inside LiveKitService
      }
      ref.read(matrixRtcDelegateProvider).setKeyProvider(keyProvider);

      // 2. Signal call membership via MatrixRTC (publishes m.call.member).
      //    session.enter() fires _makeNewSenderKey → onSetEncryptionKey,
      //    which now correctly lands in the already-installed key provider.
      await sdk.startVideoCall(
        roomId: roomId,
        livekitServiceUrl: _livekitService.serverUrl,
        livekitAlias: roomId,
        callId: roomId,
      );

      // 3. Subscribe to MatrixRTC membership events — useful for showing
      // join/leave toasts before LiveKit participant events arrive.
      final matrixRtcStream = sdk.watchVideoCall(
        roomId: roomId,
        callId: roomId,
      );
      if (matrixRtcStream != null) {
        _matrixRtcSubscription = matrixRtcStream.listen(_onMatrixRTCEvent);
      }

      // 4. Connect to LiveKit SFU for actual audio/video with E2EE.
      //    Frame cryptor already has the local key from step 1.
      //    Use the Matrix identity (userId:deviceId) as the LiveKit participant
      //    identity so LiveKit's key lookup matches keys stored by
      //    onSetEncryptionKey.
      final livekitParticipantId = sdk.matrixParticipantId ?? contactId;
      await _livekitService.connect(
        roomId: roomId,
        participantId: livekitParticipantId,
        token: livekitToken,
        e2eeKeyProvider: keyProvider.liveKitKeyProvider,
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
