import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallParticipant, AudioVideoCallSession, AudioVideoCallState;
import 'package:meeting_place_matrix_livekit/meeting_place_matrix_livekit.dart';

import '../room/flutter_livekit_room.dart';
import 'plugin_scope.dart';

/// Renders the video track for a call participant.
///
/// Use this when you have an [AudioVideoCallSession]. It sets up the Riverpod
/// scope automatically so you don't need to wrap it yourself.
///
/// If you're already inside a `PluginScope` and only have the channel DID,
/// use `MeetingPlaceLiveKitVideoView` instead.
///
/// Returns [SizedBox.shrink] when the participant has no active video track.
/// Pass [mirror] = true for the local camera preview.
///
/// Example:
/// ```dart
/// // You have an AudioVideoCallSession from your controller:
/// @override
/// Widget build(BuildContext context) {
///   return AudioVideoCallView(
///     session: activeCallSession,
///     participantId: 'remote-user-id',
///   );
/// }
/// ```
class AudioVideoCallView extends StatelessWidget {
  const AudioVideoCallView({
    super.key,
    required this.session,
    required this.participantId,
    this.mirror = false,
  });

  final AudioVideoCallSession session;
  final String participantId;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    if (session is! LiveKitCallSession) return const SizedBox.shrink();
    final lkSession = session as LiveKitCallSession;
    return PluginScope(
      container: lkSession.container,
      child: _VideoViewInScope(
        otherPartyChannelDid: lkSession.otherPartyChannelDid,
        participantId: participantId,
        mirror: mirror,
      ),
    );
  }
}

class _VideoViewInScope extends ConsumerWidget {
  const _VideoViewInScope({
    required this.otherPartyChannelDid,
    required this.participantId,
    required this.mirror,
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
