import 'package:flutter/widgets.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallSession;
import 'package:meeting_place_matrix_livekit/meeting_place_matrix_livekit.dart';

import '../room/flutter_livekit_room.dart';

/// Renders the video track for a call participant.
///
/// [hasVideo] must reflect whether [participantId] currently has an active
/// video track. Pass it from the controller state so this widget rebuilds
/// only when the caller decides — not via an internal stream subscription.
///
/// Returns [SizedBox.shrink] when [hasVideo] is false, the session is not
/// LiveKit-backed, or the room has no renderable track for [participantId].
/// Pass [mirror] = true for the local camera preview.
///
/// Example:
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   final session = ref.watch(provider.select((s) => s.session));
///   final hasVideo = ref.watch(
///     provider.select(
///       (s) => s.participants.firstWhereOrNull(
///             (p) => p.participantId == participantId,
///           )?.hasVideo ?? false,
///     ),
///   );
///   return AudioVideoCallView(
///     session: session,
///     participantId: participantId,
///     hasVideo: hasVideo,
///   );
/// }
/// ```
class AudioVideoCallView extends StatelessWidget {
  const AudioVideoCallView({
    super.key,
    required this.session,
    required this.participantId,
    required this.hasVideo,
    this.mirror = false,
  });

  final AudioVideoCallSession? session;
  final String participantId;
  final bool hasVideo;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    if (!hasVideo) return const SizedBox.shrink();
    final lkSession = session;
    if (lkSession is! LiveKitCallSession) return const SizedBox.shrink();
    final room = lkSession.room;
    if (room is! FlutterLiveKitRoom) return const SizedBox.shrink();
    final track = room.renderableVideoTrackFor(participantId);
    if (track == null) return const SizedBox.shrink();

    return VideoTrackRenderer(
      track,
      fit: VideoViewFit.cover,
      mirrorMode: mirror ? VideoViewMirrorMode.mirror : VideoViewMirrorMode.off,
    );
  }
}
