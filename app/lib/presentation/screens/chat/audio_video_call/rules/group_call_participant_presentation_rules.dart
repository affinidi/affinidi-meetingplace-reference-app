import 'package:meeting_place_matrix/meeting_place_matrix.dart';

/// Presentation rules for a participant in the group call UI.
class GroupCallParticipantPresentationConfig {
  const GroupCallParticipantPresentationConfig({
    required this.showVideo,
    required this.showOverlayLabel,
    required this.showInlineLabel,
  });

  /// Whether the participant's video track should be rendered.
  final bool showVideo;

  /// Whether to show the participant name as a lower-left overlay (only
  /// when video is on).
  final bool showOverlayLabel;

  /// Whether to show the participant name below the avatar (only when
  /// video is off).
  final bool showInlineLabel;
}

/// Resolves presentation rules for a participant based on state and context.
GroupCallParticipantPresentationConfig resolveGroupCallParticipantPresentation({
  required AudioVideoCallParticipant participant,
  required bool isCameraEnabled,
  required bool isFocusedStage,
  required bool isFullScreen,
}) {
  final showVideo = participant.isSelf ? isCameraEnabled : participant.hasVideo;
  final showOverlayLabel =
      showVideo && !(isFullScreen && participant.isSelf && isFocusedStage);

  return GroupCallParticipantPresentationConfig(
    showVideo: showVideo,
    showOverlayLabel: showOverlayLabel,
    showInlineLabel: !showVideo,
  );
}
