import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

/// Minimal stub for [MeetingPlaceMatrixSDK] usable in tests that need the
/// provider to resolve but don't exercise call-related methods.
class FakeMeetingPlaceMatrixSDK extends Fake implements MeetingPlaceMatrixSDK {
  int leaveCurrentCallCount = 0;

  @override
  bool get isCallSupported => false;

  @override
  Stream<IncomingAudioVideoCallEvent> get incomingCalls => const Stream.empty();

  @override
  Stream<IncomingAudioVideoCallEvent> get cancelledCalls =>
      const Stream.empty();

  @override
  Stream<CallSignal> get callSignals => const Stream.empty();

  @override
  Future<void> leaveCurrentCall() async {
    leaveCurrentCallCount++;
  }
}
