import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../widgets/async_loaders/modal_async_loading_status.dart';
import 'video_call_screen_controller.dart';
import 'video_call_screen_state.dart';

class VideoCallScreen extends ConsumerWidget {
  const VideoCallScreen({
    super.key,
    required this.roomId,
    required this.contactId,
  });

  final String roomId;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      videoCallScreenControllerProvider(roomId, contactId).notifier,
    );
    final matrixEventMessage = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
      ).select((s) => s.matrixEventMessage),
    );
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.videoCallTitle),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          ModalAsyncLoadingStatus(
            controller.participantEventLoadingController,
            successMessage: matrixEventMessage,
          ),
          Expanded(
            child: _ParticipantGrid(roomId: roomId, contactId: contactId),
          ),
          _CallControls(roomId: roomId, contactId: contactId),
        ],
      ),
    );
  }
}

class _ParticipantGrid extends ConsumerWidget {
  const _ParticipantGrid({required this.roomId, required this.contactId});

  final String roomId;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
      ).select((s) => s.status),
    );
    final hasError = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
      ).select((s) => s.hasError),
    );
    final error = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
      ).select((s) => s.error),
    );
    final participants = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
      ).select((s) => s.participants),
    );

    final l10n = context.l10n;

    if (status == VideoCallStatus.connecting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              l10n.videoCallJoiningCall,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Text(
          l10n.videoCallFailedToJoin(error.toString()),
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (participants.isEmpty) {
      return Center(
        child: Text(
          l10n.videoCallWaitingForParticipants,
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    final memberNames = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
      ).select((s) => s.memberNames),
    );

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: participants.length,
      itemBuilder: (_, i) {
        final participant = participants[i];
        final String displayName;
        if (participant is LocalParticipant) {
          displayName = context.l10n.videoCallYou;
        } else {
          // participant.name is the Group member firstName broadcast via
          // the LiveKit JWT `name` claim by the remote device.
          final broadcastName = participant.name;
          if (broadcastName.isNotEmpty &&
              broadcastName != participant.identity) {
            displayName = broadcastName;
          } else {
            // Fallback: look up from the memberNames map keyed by
            // md5(DID). Extract the Matrix localpart from the identity if
            // it looks like a Matrix user ID, otherwise try the raw value.
            final localpart = _parseIdentity(participant.identity);
            displayName = memberNames[localpart] ?? localpart;
          }
        }
        return _ParticipantTile(
          participant: participant,
          displayName: displayName,
        );
      },
    );
  }

  /// Extracts the Matrix localpart from a LiveKit identity string.
  /// `@alice:server.com:DEVICEID` → `alice`
  String _parseIdentity(String identity) {
    if (identity.startsWith('@')) {
      final body = identity.substring(1);
      final colon = body.indexOf(':');
      if (colon > 0) return body.substring(0, colon);
    }
    return identity;
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.participant,
    required this.displayName,
  });

  final Participant participant;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final videoTrack = participant.videoTrackPublications
        .where((TrackPublication<Track> pub) => pub.track != null && !pub.muted)
        .firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            if (videoTrack != null)
              VideoTrackRenderer(videoTrack.track! as VideoTrack)
            else
              const Center(
                child: Icon(Icons.person, color: Colors.white54, size: 48),
              ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  shadows: [Shadow(blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallControls extends ConsumerWidget {
  const _CallControls({required this.roomId, required this.contactId});

  final String roomId;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      videoCallScreenControllerProvider(roomId, contactId).notifier,
    );
    final isMicEnabled = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
      ).select((s) => s.isMicEnabled),
    );
    final isCameraEnabled = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
      ).select((s) => s.isCameraEnabled),
    );
    final l10n = context.l10n;

    return SafeArea(
      top: false,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlButton(
              icon: isMicEnabled ? Icons.mic : Icons.mic_off,
              label: isMicEnabled ? l10n.videoCallMute : l10n.videoCallUnmute,
              onTap: controller.toggleMic,
            ),
            _ControlButton(
              icon: isCameraEnabled ? Icons.videocam : Icons.videocam_off,
              label: isCameraEnabled
                  ? l10n.videoCallCameraOff
                  : l10n.videoCallCameraOn,
              onTap: controller.toggleCamera,
            ),
            _ControlButton(
              icon: Icons.call_end,
              label: l10n.videoCallEnd,
              backgroundColor: Colors.red,
              onTap: () async {
                await controller.leaveCall();
                if (context.mounted) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: backgroundColor ?? Colors.grey[800],
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
