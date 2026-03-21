import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:matrix/matrix.dart';
import 'package:webrtc_interface/webrtc_interface.dart' show MediaDevices;

/// Minimal `WebRTCDelegate` for MatrixRTC signalling via LiveKit backend.
///
/// LiveKit handles audio/video media via livekit client directly, so
/// peer-connection methods are no-ops. The delegate only satisfies the
/// `VoIP` constructor and hooks into device-change events.
///
/// Call `setKeyProvider` before starting a call when per-participant
/// LiveKit FrameCryptor E2EE is enabled, so the Matrix SDK can distribute
/// per-participant keys via Olm-encrypted to-device messages.
class FlutterMatrixRTCDelegate implements WebRTCDelegate {
  EncryptionKeyProvider? _keyProvider;
  @override
  MediaDevices get mediaDevices => webrtc.navigator.mediaDevices;

  @override
  Future<webrtc.RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration, [
    Map<String, dynamic> constraints = const {},
  ]) => webrtc.createPeerConnection(configuration, constraints);

  @override
  Future<void> playRingtone() async {}
  @override
  Future<void> stopRingtone() async {}
  @override
  Future<void> registerListeners(CallSession session) async {}
  @override
  Future<void> handleNewCall(CallSession session) async {}
  @override
  Future<void> handleCallEnded(CallSession session) async {}
  @override
  Future<void> handleMissedCall(CallSession session) async {}
  @override
  Future<void> handleNewGroupCall(GroupCallSession session) async {}
  @override
  Future<void> handleGroupCallEnded(GroupCallSession session) async {}
  @override
  bool get isWeb => false;
  @override
  bool get canHandleNewCall => true;
  @override
  EncryptionKeyProvider? get keyProvider => _keyProvider;

  /// Sets the `EncryptionKeyProvider` used for per-participant LiveKit
  /// FrameCryptor E2EE key distribution. Not required for the shared-key
  /// LiveKit E2EE path — only needed when `LiveKitBackend.e2eeEnabled = true`.
  void setKeyProvider(EncryptionKeyProvider provider) {
    _keyProvider = provider;
  }
}
