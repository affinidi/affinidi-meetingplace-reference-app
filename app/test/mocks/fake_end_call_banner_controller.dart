import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_ui_rules.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_state.dart';

/// Recorded arguments for a single show call.
typedef EndCallBannerShowCall = ({
  String contactId,
  String peerName,
  CallEndState endState,
  bool isAudioOnly,
});

/// Fake EndCallBannerController for testing ActiveCallController.
///
/// Records show calls for assertions.
class FakeEndCallBannerController extends EndCallBannerController {
  final List<EndCallBannerShowCall> showCalls = [];

  @override
  EndCallBannerState? build() => null;

  @override
  void show({
    required String contactId,
    required String peerName,
    required CallEndState endState,
    required bool isAudioOnly,
  }) {
    showCalls.add((
      contactId: contactId,
      peerName: peerName,
      endState: endState,
      isAudioOnly: isAudioOnly,
    ));
  }
}
