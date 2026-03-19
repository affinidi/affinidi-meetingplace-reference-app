import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:matrix/matrix.dart';
import 'package:webrtc_interface/webrtc_interface.dart' show MediaDevices;

/// Minimal [WebRTCDelegate] for MatrixRTC signalling via LiveKit backend.
///
/// LiveKit handles audio/video media via livekit client directly, so
/// peer-connection methods are no-ops. The delegate only satisfies the
/// [VoIP] constructor and hooks into device-change events.
class FlutterMatrixRTCDelegate implements WebRTCDelegate {
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
  EncryptionKeyProvider? get keyProvider => null;
}
