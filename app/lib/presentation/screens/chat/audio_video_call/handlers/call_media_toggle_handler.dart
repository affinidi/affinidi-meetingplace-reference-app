import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallSession;
import 'package:permission_handler/permission_handler.dart';

import '../../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../../infrastructure/services/permission_service/permission_service.dart';
import '../audio_video_call_screen_state.dart';
import '../call_media_update.dart';

/// Handles all media device toggles (mic, camera, speaker) and initial
/// permission checks for an active call.
///
/// Reads current device state from caller-supplied parameters and delegates
/// session calls via the `getSession` callback. All state changes are reported
/// through `onUpdate`.
///
/// Plain Dart class with no Riverpod dependency — unit-testable without a
/// ProviderContainer.
class CallMediaToggleHandler {
  CallMediaToggleHandler({
    required this._logger,
    required this._getSession,
    required this._getPermissionService,
    required this._onUpdate,
  });

  static const _logKey = 'CallMediaToggleHandler';

  final AppLogger _logger;
  final AudioVideoCallSession? Function() _getSession;
  final PermissionService Function() _getPermissionService;
  final void Function(CallMediaUpdate update) _onUpdate;

  /// Checks the current microphone and camera permission status and reports
  /// errors via `onUpdate` for any permanently denied permission.
  Future<void> checkInitialPermissions() async {
    final ps = _getPermissionService();
    final camStatus = await ps.getCameraPermissionStatus();
    final micStatus = await ps.getMicrophonePermissionStatus();
    _onUpdate(
      CallMediaUpdate(
        cameraPermissionError: camStatus.isPermanentlyDenied,
        micPermissionError: micStatus.isPermanentlyDenied,
      ),
    );
  }

  /// Toggles the microphone.
  ///
  /// Re-checks permission only if a prior denial was recorded. LiveKit handles
  /// the AVAudioSession natively on first enable, so undetermined permission
  /// is not re-queried here.
  Future<void> toggleMic({
    required bool currentValue,
    required bool permissionError,
  }) => _toggleDevice(
    permission: () async {
      if (!permissionError) return PermissionStatus.granted;
      final ps = _getPermissionService();
      final current = await ps.getMicrophonePermissionStatus();
      if (current.isDenied) return ps.requestMicrophonePermission();
      return current;
    },
    isGranted: (s) => s.isGranted || s.isLimited,
    onDenied: () => _onUpdate(const CallMediaUpdate(micPermissionError: true)),
    currentValue: currentValue,
    apply: (v) async => _getSession()?.setMicrophoneEnabled(v),
    onSuccess: (v) =>
        _onUpdate(CallMediaUpdate(isMicEnabled: v, micPermissionError: false)),
    failureType: CallActionFailure.microphone,
    failureLabel: 'Failed to toggle microphone',
  );

  /// Toggles the camera.
  ///
  /// Same permission-skip-if-active logic as [toggleMic].
  Future<void> toggleCamera({
    required bool currentValue,
    required bool permissionError,
  }) => _toggleDevice(
    permission: () async {
      if (!permissionError) return PermissionStatus.granted;
      final ps = _getPermissionService();
      final current = await ps.getCameraPermissionStatus();
      if (current.isDenied) return ps.requestCameraPermission();
      return current;
    },
    isGranted: (s) => s.isGranted || s.isLimited,
    onDenied: () =>
        _onUpdate(const CallMediaUpdate(cameraPermissionError: true)),
    currentValue: currentValue,
    apply: (v) async => _getSession()?.setCameraEnabled(v),
    onSuccess: (v) => _onUpdate(
      CallMediaUpdate(isCameraEnabled: v, cameraPermissionError: false),
    ),
    failureType: CallActionFailure.camera,
    failureLabel: 'Failed to toggle camera',
  );

  /// Toggles the speakerphone.
  Future<void> toggleSpeaker({required bool currentValue}) async {
    final next = !currentValue;
    try {
      await _getSession()?.setSpeakerphoneEnabled(next);
      _onUpdate(CallMediaUpdate(isSpeakerEnabled: next));
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to toggle speaker',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      _onUpdate(const CallMediaUpdate(failure: CallActionFailure.speaker));
    }
  }

  /// Switches between front and rear camera.
  Future<void> switchCamera() async {
    _logger.info('switchCamera', name: _logKey);
    await _getSession()?.switchCamera();
  }

  Future<void> _toggleDevice({
    required Future<PermissionStatus> Function() permission,
    required bool Function(PermissionStatus) isGranted,
    required void Function() onDenied,
    required bool currentValue,
    required Future<void> Function(bool) apply,
    required void Function(bool) onSuccess,
    required CallActionFailure failureType,
    required String failureLabel,
  }) async {
    final status = await permission();
    if (!isGranted(status)) {
      onDenied();
      return;
    }
    final next = !currentValue;
    try {
      await apply(next);
      onSuccess(next);
    } catch (e, stackTrace) {
      _logger.error(
        failureLabel,
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      _onUpdate(CallMediaUpdate(failure: failureType));
    }
  }
}
