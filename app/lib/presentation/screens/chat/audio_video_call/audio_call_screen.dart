part of 'audio_video_call_screen.dart';

/// Minimizes the active call and dismisses the current call screen.
void _minimizeAndPop(
  BuildContext context,
  AudioVideoCallScreenController controller,
) {
  controller.minimize();
  if (context.mounted) Navigator.of(context).pop();
}

class _AudioCallViewData {
  const _AudioCallViewData({
    required this.contactId,
    required this.peerAvatarImage,
    required this.isGroupContact,
    required this.peerName,
    required this.isPeerMuted,
    required this.session,
    required this.audioCallData,
    required this.showControls,
    required this.controls,
  });

  final String contactId;
  final ImageProvider<Object>? peerAvatarImage;
  final bool isGroupContact;
  final String peerName;
  final bool isPeerMuted;
  final AudioVideoCallSession? session;
  final GroupAudioCallData audioCallData;
  final bool showControls;
  final _CallControls controls;
}

class _AudioCallActions {
  const _AudioCallActions({
    required this.onToggleControls,
    required this.onMinimize,
  });

  final VoidCallback onToggleControls;
  final VoidCallback onMinimize;
}

/// Shows a confirmation dialog to switch from audio to video call.
Future<void> _showSwitchToVideoDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) async {
  final l10n = context.l10n;
  await showAdaptiveDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog.adaptive(
      title: Text(l10n.videoCallSwitchToVideoTitle),
      actions: [
        ActionButton(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          label: l10n.videoCallCancel,
          isDestructiveAction: true,
        ),
        ActionButton(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop();
            onConfirm();
          },
          label: l10n.videoCallSwitch,
          isDefaultAction: true,
        ),
      ],
    ),
  );
}

/// Audio-only call UI for ringing and active states.
class _AudioCallScreen extends ConsumerWidget {
  const _AudioCallScreen({required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = audioVideoCallScreenControllerProvider(contactId);
    final showControls = ref.watch(provider.select((s) => s.showControlsBar));
    final isGroupContact = ref.watch(provider.select((s) => s.isGroupContact));
    final participants = ref.watch(provider.select((s) => s.participants));
    final session = ref.watch(provider.select((s) => s.session));
    final peerName = ref.watch(provider.select((s) => s.peerName));
    final memberContactCards = ref.watch(
      provider.select((s) => s.memberContactCards),
    );
    final controller = ref.read(provider.notifier);
    final peerParticipants = participants.where(
      (participant) => participant.isSelf == false,
    );
    final peerParticipant = peerParticipants.isEmpty
        ? null
        : peerParticipants.first;

    final isMicEnabled = ref.watch(provider.select((s) => s.isMicEnabled));
    final isSpeakerEnabled = ref.watch(
      provider.select((s) => s.isSpeakerEnabled),
    );
    final micPermissionError = ref.watch(
      provider.select((s) => s.micPermissionError),
    );
    final cameraPermissionError = ref.watch(
      provider.select((s) => s.cameraPermissionError),
    );

    final peerCard = ref
        .watch(contactsServiceProvider)
        .getContactById(contactId)
        ?.card;
    final peerAvatarImage = peerCard?.hasProfilePic == true
        ? peerCard!.image(cacheManager: ref.read(cacheManagerProvider))
        : null;
    final effectivePeerAvatarImage = isGroupContact ? null : peerAvatarImage;

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
        isEnabled: false,
        isDisabled: cameraPermissionError,
        onTap: () => _showSwitchToVideoDialog(
          context: context,
          onConfirm: () => unawaited(controller.toggleCamera()),
        ),
      ),
      onEndCall: () {
        unawaited(controller.endCallFromScreen());
        if (context.mounted) Navigator.of(context).pop();
      },
    );

    return _AudioCallScaffold(
      viewData: _AudioCallViewData(
        contactId: contactId,
        peerAvatarImage: effectivePeerAvatarImage,
        isGroupContact: isGroupContact,
        peerName: peerName,
        isPeerMuted: peerParticipant?.hasAudio == false,
        session: session,
        audioCallData: resolveGroupAudioCallView(
          participants: participants,
          memberContactCards: memberContactCards,
          youLabel: context.l10n.videoCallYou,
          peerName: peerName,
        ),
        showControls: showControls,
        controls: controls,
      ),
      actions: _AudioCallActions(
        onToggleControls: controller.toggleControlsBar,
        onMinimize: () => _minimizeAndPop(context, controller),
      ),
    );
  }
}

class _AudioCallScaffold extends StatelessWidget {
  const _AudioCallScaffold({required this.viewData, required this.actions});

  final _AudioCallViewData viewData;
  final _AudioCallActions actions;

  @override
  Widget build(BuildContext context) {
    if (viewData.isGroupContact) {
      return _GroupAudioCallScaffold(viewData: viewData, actions: actions);
    }

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: GestureDetector(
        onTap: actions.onToggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _AudioCallBackground(peerAvatarImage: viewData.peerAvatarImage),
            Positioned.fill(
              child: SafeArea(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CallTopBarOverlay(
                      visible: viewData.showControls,
                      child: _CallTopBar(
                        contactId: viewData.contactId,
                        onMinimize: actions.onMinimize,
                        statusPill: viewData.isPeerMuted
                            ? _IndividualAudioMutedPill(
                                peerName: viewData.peerName,
                              )
                            : null,
                      ),
                    ),
                    Center(
                      child: _IndividualAudioCallAvatar(
                        peerAvatarImage: viewData.peerAvatarImage,
                      ),
                    ),
                    _AnimatedControlsOverlay(
                      visible: viewData.showControls,
                      duration: const Duration(milliseconds: 100),
                      child: _ControlsOverlayContent(
                        controls: viewData.controls,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupAudioCallScaffold extends StatelessWidget {
  const _GroupAudioCallScaffold({
    required this.viewData,
    required this.actions,
  });

  final _AudioCallViewData viewData;
  final _AudioCallActions actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: GestureDetector(
        onTap: actions.onToggleControls,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: viewData.showControls ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: !viewData.showControls,
                  child: _CallTopBar.group(
                    contactId: viewData.contactId,
                    onMinimize: actions.onMinimize,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _AudioCallBackground(
                    peerAvatarImage: viewData.peerAvatarImage,
                  ),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: _GroupAudioCallContent(
                      view: viewData.audioCallData,
                      session: viewData.session,
                    ),
                  ),
                  _AnimatedControlsOverlay(
                    visible: viewData.showControls,
                    duration: const Duration(milliseconds: 100),
                    child: _ControlsOverlayContent(controls: viewData.controls),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupAudioCallContent extends StatelessWidget {
  const _GroupAudioCallContent({required this.view, required this.session});

  final GroupAudioCallData view;
  final AudioVideoCallSession? session;

  double _bottomContentInset(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return bottomInset + 124;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = _bottomContentInset(context);

    if (view.peerCount == 0) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: const Center(child: _CallPersonAvatar(isGroup: true)),
      );
    }

    final singlePeerTile = view.singlePeerTile;
    if (singlePeerTile != null) {
      return Padding(
        padding: EdgeInsets.only(top: 16, bottom: bottomInset),
        child: _SinglePeerGroupAudioParticipant(
          participant: singlePeerTile.participant,
          contactCard: singlePeerTile.contactCard,
          displayName: singlePeerTile.displayName,
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: view.tiles.length,
      itemBuilder: (_, index) {
        final tile = view.tiles[index];
        return _CallParticipantTile(
          participant: tile.participant,
          session: session,
          isAudioOnly: true,
          contactCard: tile.contactCard,
          displayName: tile.displayName,
        );
      },
    );
  }
}

class _AudioCallBackground extends StatelessWidget {
  const _AudioCallBackground({required this.peerAvatarImage});

  final ImageProvider<Object>? peerAvatarImage;

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black);
  }
}

class _IndividualAudioCallAvatar extends StatelessWidget {
  const _IndividualAudioCallAvatar({required this.peerAvatarImage});

  final ImageProvider<Object>? peerAvatarImage;

  static const double _diameter = 192;

  @override
  Widget build(BuildContext context) {
    if (peerAvatarImage == null) {
      return const _CallPersonAvatar();
    }

    return ProfileCircleAvatar(
      radius: _diameter / 2,
      image: peerAvatarImage,
      child: Icon(
        Icons.person,
        size: _diameter / 2,
        color: context.colorScheme.onSurface,
      ),
    );
  }
}

class _IndividualAudioMutedPill extends StatelessWidget {
  const _IndividualAudioMutedPill({required this.peerName});

  final String peerName;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final label = peerName.isEmpty
        ? context.l10n.videoCallMuted
        : context.l10n.videoCallPeerMuted(peerName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.darkGrey,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _SinglePeerGroupAudioParticipant extends ConsumerWidget {
  const _SinglePeerGroupAudioParticipant({
    required this.participant,
    required this.contactCard,
    required this.displayName,
  });

  static const double _avatarDiameter = 192;
  static const double _muteBadgeSize = 36;

  final AudioVideoCallParticipant participant;
  final ContactCard? contactCard;
  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final cacheManager = ref.read(cacheManagerProvider);
    final participantDid = participant.did;
    final contactStoreCard = participantDid == null || participantDid.isEmpty
        ? null
        : ref.watch(
            contactsServiceProvider.select(
              (state) =>
                  state.getContactByChannelDid(participantDid)?.card ??
                  state.getContactByCardDid(participantDid)?.card,
            ),
          );
    final resolvedContactCard = resolveBestAvatarCard([
      contactCard,
      contactStoreCard,
    ]);
    final image =
        resolvedContactCard?.image(cacheManager: cacheManager) ??
        defaultProfileImage;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: colors.grey900,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.24)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfileCircleAvatar(
                    radius: _avatarDiameter / 2,
                    image: image,
                  ),
                  if (displayName.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (participant.hasAudio == false)
            const Positioned(
              top: 16,
              left: 16,
              child: CallParticipantMuteBadge(size: _muteBadgeSize),
            ),
        ],
      ),
    );
  }
}
