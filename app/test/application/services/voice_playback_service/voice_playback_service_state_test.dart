import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/voice_playback_service/voice_playback_service.dart';

void main() {
  group('VoicePlaybackState', () {
    test('progressFor returns zero when clip is not active', () {
      const state = VoicePlaybackState(
        activeClipId: 'clip-a',
        isPlaying: true,
        position: Duration(seconds: 5),
        duration: Duration(seconds: 10),
      );

      expect(state.progressFor('clip-b'), 0);
    });

    test('progressFor clamps between zero and one for the active clip', () {
      const state = VoicePlaybackState(
        activeClipId: 'clip-a',
        isPlaying: true,
        position: Duration(seconds: 5),
        duration: Duration(seconds: 10),
      );

      expect(state.progressFor('clip-a'), 0.5);
    });
  });

  group('VoicePlaybackService.clipId', () {
    test('scopes attachment cache keys per contact', () {
      const contactId = 'contact-1';
      const cacheKey = 'chat_attachment_evt_123';

      expect(
        VoicePlaybackService.clipId(contactId, cacheKey),
        '$contactId\u0000$cacheKey',
      );
      expect(
        VoicePlaybackService.clipId('contact-2', cacheKey),
        isNot(VoicePlaybackService.clipId(contactId, cacheKey)),
      );
    });
  });
}
