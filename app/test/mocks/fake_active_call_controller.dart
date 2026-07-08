import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart'
    show AudioVideoCallScreenController;
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';

/// Fake [ActiveCallController] for testing [AudioVideoCallScreenController].
///
/// Records [registerSession] calls and exposes a configurable [callChatItemId].
class FakeActiveCallController extends ActiveCallController {
  FakeActiveCallController({
    this.fixedCallChatItemId,
    this.bannerState,
    this.fixedSession,
  });

  final String? fixedCallChatItemId;
  final ActiveCallState? bannerState;
  final AudioVideoCallSession? fixedSession;

  bool sessionRegistered = false;
  bool sessionCleared = false;
  bool hangUpFromScreenCalled = false;
  CallRole? hangUpFromScreenRole;
  bool endCallChatItemCalled = false;
  CallRole? endCallChatItemRole;

  @override
  ActiveCallState? build() => bannerState;

  @override
  String? get callChatItemId => fixedCallChatItemId;

  @override
  AudioVideoCallSession? get session => fixedSession;

  @override
  void registerSession(
    AudioVideoCallSession session, {
    required String channelDid,
    required bool isAudioOnly,
    required AudioVideoCallStatus initialStatus,
    required String peerName,
    required bool isMicEnabled,
    required bool isMinimized,
    required bool isGroupContact,
  }) {
    sessionRegistered = true;
  }

  @override
  void clearSession() {
    sessionCleared = true;
  }

  @override
  void hangUpFromScreen({required CallRole role}) {
    hangUpFromScreenCalled = true;
    hangUpFromScreenRole = role;
  }

  @override
  Future<void> endCallChatItem({required CallRole role}) async {
    endCallChatItemCalled = true;
    endCallChatItemRole = role;
  }

  @override
  void update(ActiveCallState next) {}

  @override
  void clear() {}

  @override
  void restore() {}

  @override
  void startTimer([DateTime? callStartedAt]) {}

  @override
  void stopTimer() {}

  @override
  void hangUp() {}
}
