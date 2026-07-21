part of 'audio_video_call_screen.dart';

class _VideoCallViewData {
  const _VideoCallViewData({
    required this.contactId,
    required this.status,
    required this.errorCode,
    required this.participants,
    required this.session,
    required this.peerName,
    required this.memberContactCards,
    required this.peerParticipant,
    required this.selfParticipant,
    required this.pipState,
    required this.controls,
  });

  final String contactId;
  final AudioVideoCallStatus status;
  final AudioVideoCallErrorCode? errorCode;
  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final String peerName;
  final Map<String, ContactCard> memberContactCards;
  final AudioVideoCallParticipant? peerParticipant;
  final AudioVideoCallParticipant? selfParticipant;
  final _PiPState pipState;
  final _CallControls controls;
}

class _VideoCallActions {
  const _VideoCallActions({
    required this.onToggleControls,
    required this.onMinimize,
    required this.onSwitchCamera,
    required this.onToggleMic,
  });

  final VoidCallback onToggleControls;
  final VoidCallback onMinimize;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleMic;
}

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
    final isGroupContact = ref.watch(provider.select((s) => s.isGroupContact));
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
        unawaited(controller.endCallFromScreen());
        if (context.mounted) Navigator.of(context).pop();
      },
    );

    final peerParticipant = participants.where((p) => !p.isSelf).firstOrNull;
    final selfParticipant = participants.where((p) => p.isSelf).firstOrNull;

    final viewData = _VideoCallViewData(
      contactId: contactId,
      status: status,
      errorCode: errorCode,
      participants: participants,
      session: session,
      peerName: peerName,
      memberContactCards: memberContactCards,
      peerParticipant: peerParticipant,
      selfParticipant: selfParticipant,
      pipState: _PiPState(
        isCameraEnabled: isCameraEnabled,
        isMicEnabled: isMicEnabled,
        micPermissionError: micPermissionError,
        showControls: showControls,
      ),
      controls: controls,
    );

    final actions = _VideoCallActions(
      onToggleControls: controller.toggleControlsBar,
      onMinimize: () => _minimizeAndPop(context, controller),
      onSwitchCamera: () => unawaited(controller.switchCamera()),
      onToggleMic: () => unawaited(controller.toggleMic()),
    );

    if (isGroupContact) {
      return _GroupVideoCallScaffold(viewData: viewData, actions: actions);
    }

    return _IndividualVideoCallScaffold(viewData: viewData, actions: actions);
  }
}

class _GroupVideoCallScaffold extends ConsumerWidget {
  const _GroupVideoCallScaffold({
    required this.viewData,
    required this.actions,
  });

  final _VideoCallViewData viewData;
  final _VideoCallActions actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          ColoredBox(
            color: Colors.black,
            child: SafeArea(
              bottom: false,
              child: _CallTopBar.group(
                contactId: viewData.contactId,
                onMinimize: actions.onMinimize,
              ),
            ),
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: _CallParticipantGrid(
                contactId: viewData.contactId,
                status: viewData.status,
                errorCode: viewData.errorCode,
                isAudioOnly: false,
                participants: viewData.participants,
                session: viewData.session,
                peerName: viewData.peerName,
                memberContactCards: viewData.memberContactCards,
                controls: _ControlsOverlayContent(controls: viewData.controls),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndividualVideoCallScaffold extends StatelessWidget {
  const _IndividualVideoCallScaffold({
    required this.viewData,
    required this.actions,
  });

  final _VideoCallViewData viewData;
  final _VideoCallActions actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: actions.onToggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _IndividualVideoCallStage(
              contactId: viewData.contactId,
              session: viewData.session,
              peerParticipant: viewData.peerParticipant,
              selfParticipant: viewData.selfParticipant,
              isCameraEnabled: viewData.pipState.isCameraEnabled,
            ),
            Positioned.fill(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    fit: StackFit.expand,
                    children: [
                      _CallTopBarOverlay(
                        visible: viewData.pipState.showControls,
                        child: _CallTopBar.cameraSwitch(
                          contactId: viewData.contactId,
                          onMinimize: actions.onMinimize,
                          onSwitchCamera: actions.onSwitchCamera,
                        ),
                      ),
                      if (viewData.peerParticipant != null &&
                          viewData.selfParticipant != null)
                        VideoCallPiPWindow(
                          contactId: viewData.contactId,
                          session: viewData.session,
                          participant: viewData.selfParticipant!,
                          isCameraEnabled: viewData.pipState.isCameraEnabled,
                          availableSize: constraints.biggest,
                          useCameraSizedWindowWhenVideoOff: true,
                          showControlsBar: viewData.pipState.showControls,
                          overlayChildren: [
                            if (!viewData.pipState.showControls)
                              _InCallMuteButton(
                                isMicEnabled: viewData.pipState.isMicEnabled,
                                isPermissionError:
                                    viewData.pipState.micPermissionError,
                                onTap: actions.onToggleMic,
                              ),
                          ],
                        ),
                      _AnimatedControlsOverlay(
                        visible: viewData.pipState.showControls,
                        duration: const Duration(milliseconds: 100),
                        child: _ControlsOverlayContent(
                          controls: viewData.controls,
                        ),
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

class _IndividualVideoCallStage extends StatelessWidget {
  const _IndividualVideoCallStage({
    required this.contactId,
    required this.session,
    required this.peerParticipant,
    required this.selfParticipant,
    required this.isCameraEnabled,
  });

  final String contactId;
  final AudioVideoCallSession? session;
  final AudioVideoCallParticipant? peerParticipant;
  final AudioVideoCallParticipant? selfParticipant;
  final bool isCameraEnabled;

  @override
  Widget build(BuildContext context) {
    final peer = peerParticipant;
    if (peer != null) {
      return VideoCallBackground(
        contactId: contactId,
        peerParticipant: peer,
        session: session,
      );
    }

    final self = selfParticipant;
    final selfPreviewParticipantId = switch (session) {
      LiveKitCallSession liveKitSession => liveKitSession.room.ownParticipantId,
      _ => null,
    };
    final showSelfVideo =
        isCameraEnabled &&
        ((self != null && self.hasVideo) || selfPreviewParticipantId != null);

    if (showSelfVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: VideoCallPeerPlaceholder(
              contactId: contactId,
              showCurrentIdentity: false,
            ),
          ),
          AudioVideoCallView(
            session: session,
            participantId: self?.participantId ?? selfPreviewParticipantId!,
            hasVideo: true,
            mirror: true,
          ),
        ],
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: VideoCallPeerPlaceholder(
        contactId: contactId,
        showCurrentIdentity: false,
      ),
    );
  }
}
