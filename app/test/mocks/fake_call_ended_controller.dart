import 'package:mpx_flutter_reference_app/presentation/widgets/call_ended/call_ended_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call_ended/call_ended_state.dart';

/// Recorded arguments for a single show call.
typedef CallEndedShowCall = ({
  String contactId,
  String peerName,
  int callDurationSeconds,
  bool isAudioOnly,
  String? errorMessage,
});

/// Fake [CallEndedController] for testing.
///
/// Records [show] calls for assertions; does not start a timer.
class FakeCallEndedController extends CallEndedController {
  final List<CallEndedShowCall> showCalls = [];

  @override
  CallEndedState? build() => null;

  @override
  void show({
    required String contactId,
    required String peerName,
    required int callDurationSeconds,
    required bool isAudioOnly,
    String? errorMessage,
  }) {
    showCalls.add((
      contactId: contactId,
      peerName: peerName,
      callDurationSeconds: callDurationSeconds,
      isAudioOnly: isAudioOnly,
      errorMessage: errorMessage,
    ));
    state = CallEndedState(
      contactId: contactId,
      peerName: peerName,
      callDurationSeconds: callDurationSeconds,
      isAudioOnly: isAudioOnly,
      errorMessage: errorMessage,
    );
  }
}
