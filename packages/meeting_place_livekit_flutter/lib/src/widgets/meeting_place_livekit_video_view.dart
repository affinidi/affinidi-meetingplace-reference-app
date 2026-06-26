import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallParticipant, AudioVideoCallState;
import 'package:meeting_place_matrix_livekit/meeting_place_matrix_livekit.dart';

import '../room/flutter_livekit_room.dart';

/// Renders the video track for a participant in an active call.
///
/// Use this only if you're already inside a `PluginScope` and have the
/// channel DID. For most cases, use `AudioVideoCallView` instead — it's
/// simpler and handles the scope setup for you.
///
/// Rebuilds only when the participant's `hasVideo` flag changes, not on
/// every state update.
///
/// Returns [SizedBox.shrink] when the room is not connected, the participant
/// is not found, or there is no active video track.
///
/// Example:
/// ```dart
/// PluginScope(
///   container: lkSession.container,
///   child: MeetingPlaceLiveKitVideoView(
///     otherPartyChannelDid: lkSession.otherPartyChannelDid,
///     participantId: remoteParticipantId,
///   ),
/// )
/// ```
class MeetingPlaceLiveKitVideoView extends ConsumerWidget {
  const MeetingPlaceLiveKitVideoView({
    super.key,
    required this.otherPartyChannelDid,
    required this.participantId,
    this.mirror = false,
  });

  final String otherPartyChannelDid;
  final String participantId;
  final bool mirror;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(
      audioVideoCallServiceProvider(otherPartyChannelDid).select<bool>((
        AudioVideoCallState? s,
      ) {
        if (s == null) return false;
        return s.participants
                .where(
                  (AudioVideoCallParticipant p) =>
                      p.participantId == participantId,
                )
                .firstOrNull
                ?.hasVideo ??
            false;
      }),
    );
    final room = ref.read(livekitRoomProvider(otherPartyChannelDid));
    final track = room is FlutterLiveKitRoom
        ? room.renderableVideoTrackFor(participantId)
        : null;
    if (track == null) return const SizedBox.shrink();
    return VideoTrackRenderer(
      track,
      fit: VideoViewFit.cover,
      mirrorMode: mirror ? VideoViewMirrorMode.mirror : VideoViewMirrorMode.off,
    );
  }
}
