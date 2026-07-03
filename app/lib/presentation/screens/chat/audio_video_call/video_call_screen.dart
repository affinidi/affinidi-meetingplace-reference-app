part of 'audio_video_call_screen.dart';

/// State needed to render the self-view PiP overlay in a 1:1 video call.
class _PiPState {
  const _PiPState({
    required this.isCameraEnabled,
    required this.isMicEnabled,
    required this.micPermissionError,
    required this.showControls,
  });

  final bool isCameraEnabled;
  final bool isMicEnabled;
  final bool micPermissionError;
  final bool showControls;
}

/// Video call screen: peer camera full-screen with self-view PiP and call
/// overlays.
///
/// For 1:1 calls (at most one peer): the peer's camera fills the
/// background, with a draggable self-view window and the same top-bar and
/// controls overlay as the audio call screen.
///
/// For group calls (two or more peers): falls back to
/// [_CallParticipantGrid] with a tiled layout.
class _VideoCallScreen extends ConsumerWidget {
  const _VideoCallScreen({required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = audioVideoCallScreenControllerProvider(contactId);
    final controller = ref.read(provider.notifier);
    final showControls = ref.watch(provider.select((s) => s.showControlsBar));

    final participants = ref.watch(provider.select((s) => s.participants));
    final session = ref.watch(provider.select((s) => s.session));
    final status = ref.watch(provider.select((s) => s.status));
    final errorCode = ref.watch(provider.select((s) => s.errorCode));
    final peerName = ref.watch(provider.select((s) => s.peerName));
    final memberContactCards = ref.watch(
      provider.select((s) => s.memberContactCards),
    );
    final isMicEnabled = ref.watch(provider.select((s) => s.isMicEnabled));
    final isSpeakerEnabled = ref.watch(
      provider.select((s) => s.isSpeakerEnabled),
    );
    final isCameraEnabled = ref.watch(
      provider.select((s) => s.isCameraEnabled),
    );
    final micPermissionError = ref.watch(
      provider.select((s) => s.micPermissionError),
    );
    final cameraPermissionError = ref.watch(
      provider.select((s) => s.cameraPermissionError),
    );

    final controls = _CallControls(
      mic: CallButtonConfig(
        isEnabled: isMicEnabled,
        isDisabled: micPermissionError,
        onTap: controller.toggleMic,
      ),
      speaker: CallButtonConfig(
        isEnabled: isSpeakerEnabled,
        onTap: controller.toggleSpeaker,
      ),
      camera: CallButtonConfig(
        isEnabled: isCameraEnabled,
        isDisabled: cameraPermissionError,
        onTap: controller.toggleCamera,
      ),
      onEndCall: () {
        unawaited(controller.leaveCall());
        if (context.mounted) Navigator.of(context).pop();
      },
    );

    final remotePeer = participants.where((p) => !p.isSelf).firstOrNull;
    final selfParticipant = participants.where((p) => p.isSelf).firstOrNull;

    // Group call: two or more peers use the tiled grid layout.
    final remoteCount = participants.where((p) => !p.isSelf).length;
    if (remoteCount > 1) {
      return _GroupVideoCallScaffold(
        contactId: contactId,
        status: status,
        errorCode: errorCode,
        participants: participants,
        session: session,
        peerName: peerName,
        memberContactCards: memberContactCards,
        controls: controls,
      );
    }

    return _IndividualVideoCallScaffold(
      contactId: contactId,
      session: session,
      remotePeer: remotePeer,
      selfParticipant: selfParticipant,
      pipState: _PiPState(
        isCameraEnabled: isCameraEnabled,
        isMicEnabled: isMicEnabled,
        micPermissionError: micPermissionError,
        showControls: showControls,
      ),
      controls: controls,
      onToggleControls: controller.toggleControlsBar,
      onMinimize: () {
        controller.minimize();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      onSwitchCamera: () => unawaited(controller.switchCamera()),
      onToggleMic: () => unawaited(controller.toggleMic()),
    );
  }
}

class _GroupVideoCallScaffold extends StatelessWidget {
  const _GroupVideoCallScaffold({
    required this.contactId,
    required this.status,
    required this.errorCode,
    required this.participants,
    required this.session,
    required this.peerName,
    required this.memberContactCards,
    required this.controls,
  });

  final String contactId;
  final AudioVideoCallStatus status;
  final AudioVideoCallErrorCode? errorCode;
  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final String peerName;
  final Map<String, ContactCard> memberContactCards;
  final _CallControls controls;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Scaffold(
      backgroundColor: colors.grey900,
      body: _CallParticipantGrid(
        contactId: contactId,
        status: status,
        errorCode: errorCode,
        isAudioOnly: false,
        participants: participants,
        session: session,
        peerName: peerName,
        memberContactCards: memberContactCards,
        controls: _ControlsOverlayContent(controls: controls),
      ),
    );
  }
}

class _IndividualVideoCallScaffold extends StatelessWidget {
  const _IndividualVideoCallScaffold({
    required this.contactId,
    required this.session,
    required this.remotePeer,
    required this.selfParticipant,
    required this.pipState,
    required this.controls,
    required this.onToggleControls,
    required this.onMinimize,
    required this.onSwitchCamera,
    required this.onToggleMic,
  });

  final String contactId;
  final AudioVideoCallSession? session;
  final AudioVideoCallParticipant? remotePeer;
  final AudioVideoCallParticipant? selfParticipant;
  final _PiPState pipState;
  final _CallControls controls;
  final VoidCallback onToggleControls;
  final VoidCallback onMinimize;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleMic;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Scaffold(
      backgroundColor: colors.grey900,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _VideoCallBackground(remotePeer: remotePeer, session: session),
            Positioned.fill(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    fit: StackFit.expand,
                    children: [
                      _CallTopBarOverlay(
                        visible: pipState.showControls,
                        child: _CallTopBar(
                          contactId: contactId,
                          onMinimize: onMinimize,
                        ),
                      ),
                      if (selfParticipant != null)
                        VideoCallPiPWindow(
                          contactId: contactId,
                          session: session,
                          participant: selfParticipant!,
                          isCameraEnabled: pipState.isCameraEnabled,
                          availableSize: constraints.biggest,
                          showControlsBar: pipState.showControls,
                          overlayChildren: [
                            if (pipState.isCameraEnabled &&
                                selfParticipant!.hasVideo)
                              _InCallFlipCameraButton(onTap: onSwitchCamera),
                            if (!pipState.showControls)
                              _InCallMuteButton(
                                isMicEnabled: pipState.isMicEnabled,
                                isPermissionError: pipState.micPermissionError,
                                onTap: onToggleMic,
                              ),
                          ],
                        ),
                      _AnimatedControlsOverlay(
                        visible: pipState.showControls,
                        duration: const Duration(milliseconds: 100),
                        child: _ControlsOverlayContent(controls: controls),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoCallBackground extends StatelessWidget {
  const _VideoCallBackground({required this.remotePeer, required this.session});

  final AudioVideoCallParticipant? remotePeer;
  final AudioVideoCallSession? session;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    if (remotePeer == null) {
      return Container(color: colors.grey900);
    }

    return AudioVideoCallView(
      session: session,
      participantId: remotePeer!.participantId,
      hasVideo: remotePeer!.hasVideo,
      mirror: false,
    );
  }
}
