import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';

class FakeAudioVideoCallScreenController
    extends AudioVideoCallScreenController {
  FakeAudioVideoCallScreenController([this._state]);

  final AudioVideoCallScreenState? _state;

  @override
  AudioVideoCallScreenState build(String contactId) =>
      _state ??
      AudioVideoCallScreenState(
        isCameraEnabled: true,
        isMicEnabled: true,
        participants: const [
          AudioVideoCallParticipant(participantId: 'local', isSelf: true),
        ],
      );
}
