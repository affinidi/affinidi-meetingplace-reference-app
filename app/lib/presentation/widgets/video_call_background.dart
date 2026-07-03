import 'package:flutter/material.dart';
import 'package:meeting_place_livekit_flutter/meeting_place_livekit_flutter.dart'
    show AudioVideoCallView;
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import 'video_call_peer_placeholder.dart';

/// Full-screen background for a 1:1 video call.
///
/// Renders the remote peer's camera feed when it has an active, renderable
/// video track. Otherwise it shows [VideoCallPeerPlaceholder] (the peer's
/// avatar) instead of a black screen: the peer has not joined yet, has turned
/// their camera off mid-call, or the feed is still initialising.
class VideoCallBackground extends StatelessWidget {
  const VideoCallBackground({
    super.key,
    required this.contactId,
    required this.remotePeer,
    required this.session,
  });

  final String contactId;
  final AudioVideoCallParticipant? remotePeer;
  final AudioVideoCallSession? session;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    final peer = remotePeer;
    if (peer == null || !peer.hasVideo) {
      return ColoredBox(
        color: colors.grey900,
        child: VideoCallPeerPlaceholder(contactId: contactId),
      );
    }

    return AudioVideoCallView(
      session: session,
      participantId: peer.participantId,
      hasVideo: peer.hasVideo,
      mirror: false,
    );
  }
}
