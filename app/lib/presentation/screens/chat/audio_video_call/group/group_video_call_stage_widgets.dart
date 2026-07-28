part of '../group_video_call_screen.dart';

class _FocusedParticipantStage extends StatelessWidget {
  const _FocusedParticipantStage({
    required this.participant,
    required this.session,
    required this.memberContactCards,
    required this.isCameraEnabled,
    required this.label,
    this.isFullScreen = false,
  });

  final AudioVideoCallParticipant participant;
  final AudioVideoCallSession? session;
  final Map<String, ContactCard> memberContactCards;
  final bool isCameraEnabled;
  final String label;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    final presentation = resolveGroupCallParticipantPresentation(
      participant: participant,
      isCameraEnabled: isCameraEnabled,
      isFocusedStage: true,
      isFullScreen: isFullScreen,
    );

    final stage = Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: context.customColors.callControlSurface,
          child: IgnorePointer(
            child: _ParticipantVideoOrAvatar(
              participant: participant,
              session: session,
              memberContactCards: memberContactCards,
              isCameraEnabled: isCameraEnabled,
              avatarRadius: isFullScreen ? 96 : 58,
              label: presentation.showInlineLabel ? label : null,
              showVideo: presentation.showVideo,
              labelStyle: context.textTheme.titleMedium?.copyWith(
                color: context.customColors.pureWhite,
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Visibility(
            visible: participant.hasAudio == false,
            child: const CallParticipantMuteBadge(),
          ),
        ),
        if (presentation.showOverlayLabel)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.customColors.pureWhite,
              ),
            ),
          ),
      ],
    );

    if (isFullScreen) {
      return stage;
    }

    return ClipRRect(borderRadius: BorderRadius.circular(28), child: stage);
  }
}

class _GroupVideoTopBar extends StatelessWidget {
  const _GroupVideoTopBar({
    required this.contactId,
    required this.onMinimize,
    required this.onSwitchCamera,
    required this.showSwitchCamera,
  });

  final String contactId;
  final VoidCallback onMinimize;
  final VoidCallback onSwitchCamera;
  final bool showSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return CallTopBarWidget(
      contactId: contactId,
      onMinimize: onMinimize,
      crossAxisAlignment: CrossAxisAlignment.start,
      centerPadding: const EdgeInsets.symmetric(horizontal: 16),
      trailing: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CallTopBarActionButton(
              icon: Icons.people_alt_outlined,
              onPressed: () =>
                  CallParticipantsSheet.show(context, contactId: contactId),
            ),
            if (showSwitchCamera) ...[
              const SizedBox(height: 8),
              CallTopBarActionButton(
                icon: Icons.flip_camera_ios,
                onPressed: onSwitchCamera,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SinglePeerVideoStage extends StatelessWidget {
  const _SinglePeerVideoStage({
    required this.contactId,
    required this.peerParticipant,
    required this.selfParticipant,
    required this.session,
    required this.memberContactCards,
    required this.isCameraEnabled,
    required this.showControlsBar,
    required this.isMicEnabled,
    required this.micPermissionError,
    required this.cameraPermissionError,
    required this.onToggleMic,
    required this.onSwitchCamera,
  });

  final String contactId;
  final AudioVideoCallParticipant peerParticipant;
  final AudioVideoCallParticipant selfParticipant;
  final AudioVideoCallSession? session;
  final Map<String, ContactCard> memberContactCards;
  final bool isCameraEnabled;
  final bool showControlsBar;
  final bool isMicEnabled;
  final bool micPermissionError;
  final bool cameraPermissionError;
  final VoidCallback onToggleMic;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _PeerParticipantStage(
          contactId: contactId,
          peerParticipant: peerParticipant,
          session: session,
        ),
        Positioned.fill(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                fit: StackFit.expand,
                children: [
                  VideoCallPiPWindow(
                    contactId: contactId,
                    session: session,
                    participant: selfParticipant,
                    isCameraEnabled: isCameraEnabled,
                    availableSize: constraints.biggest,
                    useCameraSizedWindowWhenVideoOff: true,
                    showControlsBar: showControlsBar,
                    overlayChildren: [
                      if (!showControlsBar)
                        VideoCallPiPMuteButton(
                          isMicEnabled: isMicEnabled,
                          isPermissionError: micPermissionError,
                          onTap: onToggleMic,
                        ),
                      VideoCallPiPFlipCameraButton(
                        isPermissionError: cameraPermissionError,
                        onTap: onSwitchCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PeerParticipantStage extends StatelessWidget {
  const _PeerParticipantStage({
    required this.contactId,
    required this.peerParticipant,
    required this.session,
  });

  final String contactId;
  final AudioVideoCallParticipant peerParticipant;
  final AudioVideoCallSession? session;

  @override
  Widget build(BuildContext context) {
    if (peerParticipant.hasVideo) {
      return ColoredBox(
        color: Colors.black,
        child: IgnorePointer(
          child: AudioVideoCallView(
            session: session,
            participantId: peerParticipant.participantId,
            hasVideo: true,
            mirror: false,
          ),
        ),
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: ProfileCircleAvatar(
          radius: 96,
          child: Icon(
            Icons.person,
            size: 96,
            color: context.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
