import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/group_call_participant_presentation_rules.dart';

AudioVideoCallParticipant _participant({
  required bool isSelf,
  required bool hasVideo,
}) {
  return AudioVideoCallParticipant(
    participantId: 'p',
    isSelf: isSelf,
    hasVideo: hasVideo,
    hasAudio: true,
    isSpeaking: false,
  );
}

void main() {
  group('resolveGroupCallParticipantPresentation for self', () {
    test('shows video when camera is enabled', () {
      final config = resolveGroupCallParticipantPresentation(
        participant: _participant(isSelf: true, hasVideo: true),
        isCameraEnabled: true,
        isFocusedStage: false,
        isFullScreen: false,
      );

      expect(config.showVideo, isTrue);
    });

    test('hides video when camera is disabled regardless of track state', () {
      final config = resolveGroupCallParticipantPresentation(
        participant: _participant(isSelf: true, hasVideo: true),
        isCameraEnabled: false,
        isFocusedStage: false,
        isFullScreen: false,
      );

      expect(config.showVideo, isFalse);
    });

    test('shows inline label when video is off', () {
      final config = resolveGroupCallParticipantPresentation(
        participant: _participant(isSelf: true, hasVideo: false),
        isCameraEnabled: false,
        isFocusedStage: false,
        isFullScreen: false,
      );

      expect(config.showInlineLabel, isTrue);
      expect(config.showOverlayLabel, isFalse);
    });

    test('suppresses overlay label in full-screen focused self stage', () {
      final config = resolveGroupCallParticipantPresentation(
        participant: _participant(isSelf: true, hasVideo: true),
        isCameraEnabled: true,
        isFocusedStage: true,
        isFullScreen: true,
      );

      expect(config.showOverlayLabel, isFalse);
    });

    test('suppresses inline label in full-screen focused self stage', () {
      final config = resolveGroupCallParticipantPresentation(
        participant: _participant(isSelf: true, hasVideo: false),
        isCameraEnabled: false,
        isFocusedStage: true,
        isFullScreen: true,
      );

      expect(config.showInlineLabel, isFalse);
      expect(config.showOverlayLabel, isFalse);
    });
  });

  group('resolveGroupCallParticipantPresentation for peer', () {
    test('shows video based on the peer hasVideo track state', () {
      final config = resolveGroupCallParticipantPresentation(
        participant: _participant(isSelf: false, hasVideo: true),
        isCameraEnabled: false,
        isFocusedStage: false,
        isFullScreen: false,
      );

      expect(config.showVideo, isTrue);
    });

    test('shows overlay label when peer video is on', () {
      final config = resolveGroupCallParticipantPresentation(
        participant: _participant(isSelf: false, hasVideo: true),
        isCameraEnabled: false,
        isFocusedStage: false,
        isFullScreen: false,
      );

      expect(config.showOverlayLabel, isTrue);
      expect(config.showInlineLabel, isFalse);
    });

    test('shows inline label when peer video is off', () {
      final config = resolveGroupCallParticipantPresentation(
        participant: _participant(isSelf: false, hasVideo: false),
        isCameraEnabled: true,
        isFocusedStage: false,
        isFullScreen: false,
      );

      expect(config.showInlineLabel, isTrue);
      expect(config.showOverlayLabel, isFalse);
    });
  });
}
