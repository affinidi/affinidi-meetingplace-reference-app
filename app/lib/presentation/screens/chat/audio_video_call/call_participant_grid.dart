part of 'audio_video_call_screen.dart';

class _CallParticipantGrid extends ConsumerWidget {
  const _CallParticipantGrid({
    required this.contactId,
    required this.status,
    required this.errorCode,
    required this.isAudioOnly,
    required this.participants,
    required this.session,
    required this.peerName,
    required this.memberContactCards,
    required this.controls,
  });

  final String contactId;
  final AudioVideoCallStatus status;
  final AudioVideoCallErrorCode? errorCode;
  final bool isAudioOnly;
  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final String peerName;
  final Map<String, ContactCard> memberContactCards;
  final Widget controls;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.customColors;
    final textTheme = context.textTheme;

    final provider = audioVideoCallScreenControllerProvider(contactId);
    final controller = ref.read(provider.notifier);
    final showControls = ref.watch(provider.select((s) => s.showControlsBar));
    final focusedIndex = ref.watch(
      provider.select((s) => s.focusedParticipantIndex),
    );

    if (status == AudioVideoCallStatus.connecting ||
        status == AudioVideoCallStatus.waitingForKeys) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.cyan),
            const SizedBox(height: 16),
            Text(
              status == AudioVideoCallStatus.waitingForKeys
                  ? l10n.videoCallWaitingForEncryption
                  : l10n.videoCallJoiningCall,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.whiteOverlay30,
              ),
            ),
          ],
        ),
      );
    }

    if (status == AudioVideoCallStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.videoCallError(errorCode?.name ?? ''),
            style: textTheme.bodyMedium?.copyWith(color: colors.rose),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (participants.isEmpty) {
      return Center(
        child: Text(
          l10n.videoCallWaitingForParticipants,
          style: textTheme.bodyMedium?.copyWith(color: colors.whiteOverlay30),
        ),
      );
    }

    if (focusedIndex != null && focusedIndex >= participants.length) {
      controller.setFocusedParticipant(null);
    }

    if (focusedIndex == null) {
      return _CallGridLayout(
        participants: participants,
        session: session,
        peerName: peerName,
        memberContactCards: memberContactCards,
        isAudioOnly: isAudioOnly,
        showControls: showControls,
        onToggleControls: controller.toggleControlsBar,
        onSetFocused: controller.setFocusedParticipant,
        onSetControlsVisible: controller.setControlsBarVisible,
        controls: controls,
      );
    }

    return _CallFocusedLayout(
      participants: participants,
      session: session,
      peerName: peerName,
      memberContactCards: memberContactCards,
      isAudioOnly: isAudioOnly,
      showControls: showControls,
      onToggleControls: controller.toggleControlsBar,
      onSetFocused: controller.setFocusedParticipant,
      miniGridExpanded: ref.watch(provider.select((s) => s.miniGridExpanded)),
      onToggleMiniGridExpanded: controller.toggleMiniGridExpanded,
      focusedIndex: focusedIndex,
      controls: controls,
    );
  }
}

class _CallGridLayout extends HookWidget {
  const _CallGridLayout({
    required this.participants,
    required this.session,
    required this.peerName,
    required this.memberContactCards,
    required this.isAudioOnly,
    required this.showControls,
    required this.onToggleControls,
    required this.onSetControlsVisible,
    required this.onSetFocused,
    required this.controls,
  });

  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final String peerName;
  final Map<String, ContactCard> memberContactCards;
  final bool isAudioOnly;
  final bool showControls;
  final VoidCallback onToggleControls;
  final void Function({required bool visible}) onSetControlsVisible;
  final void Function(int?) onSetFocused;
  final Widget controls;

  @override
  Widget build(BuildContext context) {
    final youLabel = context.l10n.videoCallYou;
    final peerCount = participants.where((p) => !p.isSelf).length;
    final scrollController = useScrollController();
    final pointerDownPixels = useRef(0.0);

    bool scrolledSincePointerDown() {
      if (!scrollController.hasClients) return false;
      return (scrollController.position.pixels - pointerDownPixels.value)
              .abs() >
          1.0;
    }

    return SafeArea(
      child: Stack(
        children: [
          Listener(
            onPointerDown: (_) {
              pointerDownPixels.value = scrollController.hasClients
                  ? scrollController.position.pixels
                  : 0.0;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  onSetControlsVisible(visible: false);
                } else if (notification is ScrollEndNotification) {
                  onSetControlsVisible(visible: true);
                }
                return false;
              },
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 80,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: participants.length,
                itemBuilder: (_, i) {
                  final participant = participants[i];
                  return GestureDetector(
                    onTap: () {
                      if (!scrolledSincePointerDown()) {
                        onSetFocused(i);
                      }
                    },
                    child: _CallParticipantTile(
                      participant: participant,
                      session: session,
                      isAudioOnly: isAudioOnly,
                      contactCard: _contactCardFor(
                        participant,
                        memberContactCards: memberContactCards,
                      ),
                      displayName: _displayNameFor(
                        participant,
                        youLabel: youLabel,
                        peerName: peerName,
                        peerCount: peerCount,
                        memberContactCards: memberContactCards,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _AnimatedControlsOverlay(
            visible: showControls,
            duration: const Duration(milliseconds: 100),
            child: controls,
          ),
        ],
      ),
    );
  }
}

class _CallFocusedLayout extends StatelessWidget {
  const _CallFocusedLayout({
    required this.participants,
    required this.session,
    required this.peerName,
    required this.memberContactCards,
    required this.isAudioOnly,
    required this.showControls,
    required this.onToggleControls,
    required this.onSetFocused,
    required this.miniGridExpanded,
    required this.onToggleMiniGridExpanded,
    required this.focusedIndex,
    required this.controls,
  });

  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final String peerName;
  final Map<String, ContactCard> memberContactCards;
  final bool isAudioOnly;
  final bool showControls;
  final VoidCallback onToggleControls;
  final void Function(int?) onSetFocused;
  final bool miniGridExpanded;
  final VoidCallback onToggleMiniGridExpanded;
  final int focusedIndex;
  final Widget controls;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final youLabel = context.l10n.videoCallYou;
    final peerCount = participants.where((p) => !p.isSelf).length;

    final fi = focusedIndex;
    final others = <int>[];
    for (var i = 0; i < participants.length; i++) {
      if (i != fi) others.add(i);
    }

    final otherParticipants = <AudioVideoCallParticipant>[];
    final otherDisplayNames = <String>[];
    for (final idx in others) {
      otherParticipants.add(participants[idx]);
      otherDisplayNames.add(
        _displayNameFor(
          participants[idx],
          youLabel: youLabel,
          peerName: peerName,
          peerCount: peerCount,
          memberContactCards: memberContactCards,
        ),
      );
    }

    final focusedName = _displayNameFor(
      participants[fi],
      youLabel: youLabel,
      peerName: peerName,
      peerCount: peerCount,
      memberContactCards: memberContactCards,
    );

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onToggleControls,
              child: _CallFocusedTile(
                participant: participants[fi],
                session: session,
                isAudioOnly: isAudioOnly,
                contactCard: _contactCardFor(
                  participants[fi],
                  memberContactCards: memberContactCards,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: showControls ? 1.0 : 0.0,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!showControls) onToggleControls();
                        onSetFocused(null);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.grey900.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: colorScheme.onSurface,
                          size: 22,
                        ),
                      ),
                    ),
                    if (focusedName.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.grey900.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            focusedName,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (others.isNotEmpty)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: showControls ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !showControls,
                child: _CallDraggableMiniGrid(
                  participants: otherParticipants,
                  session: session,
                  displayNames: otherDisplayNames,
                  isAudioOnly: isAudioOnly,
                  miniGridExpanded: miniGridExpanded,
                  onToggleMiniGridExpanded: onToggleMiniGridExpanded,
                  onTapParticipant: (tappedIdx) {
                    onSetFocused(others[tappedIdx]);
                  },
                  memberContactCards: memberContactCards,
                ),
              ),
            ),
          _AnimatedControlsOverlay(
            visible: showControls,
            duration: const Duration(milliseconds: 150),
            child: controls,
          ),
        ],
      ),
    );
  }
}

class _CallFocusedTile extends ConsumerWidget {
  const _CallFocusedTile({
    required this.participant,
    required this.session,
    required this.isAudioOnly,
    required this.contactCard,
  });

  final AudioVideoCallParticipant participant;
  final AudioVideoCallSession? session;
  final bool isAudioOnly;
  final ContactCard? contactCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.customColors;
    final cacheManager = ref.read(cacheManagerProvider);
    final participantDid = participant.did;
    final identityCard = ref.watch(
      identitiesServiceProvider.select(
        (state) =>
            state.currentIdentity?.card ?? state.identities.firstOrNull?.card,
      ),
    );
    final contactStoreCard = participantDid == null || participantDid.isEmpty
        ? null
        : ref.watch(
            contactsServiceProvider.select(
              (state) =>
                  state.getContactByChannelDid(participantDid)?.card ??
                  state.getContactByCardDid(participantDid)?.card,
            ),
          );
    final resolvedContactCard = _bestAvatarCard([
      if (participant.isSelf) identityCard,
      contactCard,
      contactStoreCard,
    ]);
    final image =
        resolvedContactCard?.image(cacheManager: cacheManager) ??
        defaultProfileImage;

    return Container(
      color: colors.grey900,
      child: !isAudioOnly && participant.hasVideo
          ? IgnorePointer(
              child: AudioVideoCallView(
                session: session,
                participantId: participant.participantId,
                hasVideo: participant.hasVideo,
                mirror: participant.isSelf,
              ),
            )
          : Center(child: ProfileCircleAvatar(radius: 60, image: image)),
    );
  }
}

class _CallParticipantTile extends ConsumerWidget {
  const _CallParticipantTile({
    required this.participant,
    required this.session,
    required this.isAudioOnly,
    required this.contactCard,
    required this.displayName,
    this.borderRadius = 12,
  });

  final AudioVideoCallParticipant participant;
  final AudioVideoCallSession? session;
  final bool isAudioOnly;
  final ContactCard? contactCard;
  final String displayName;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final cacheManager = ref.read(cacheManagerProvider);
    final participantDid = participant.did;
    final identityCard = ref.watch(
      identitiesServiceProvider.select(
        (state) =>
            state.currentIdentity?.card ?? state.identities.firstOrNull?.card,
      ),
    );
    final contactStoreCard = participantDid == null || participantDid.isEmpty
        ? null
        : ref.watch(
            contactsServiceProvider.select(
              (state) =>
                  state.getContactByChannelDid(participantDid)?.card ??
                  state.getContactByCardDid(participantDid)?.card,
            ),
          );
    final resolvedContactCard = _bestAvatarCard([
      if (participant.isSelf) identityCard,
      contactCard,
      contactStoreCard,
    ]);
    final image =
        resolvedContactCard?.image(cacheManager: cacheManager) ??
        defaultProfileImage;

    final showVideo = !isAudioOnly && participant.hasVideo;

    return Container(
      decoration: BoxDecoration(
        color: colors.grey900,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (showVideo)
              Positioned.fill(
                child: IgnorePointer(
                  child: AudioVideoCallView(
                    session: session,
                    participantId: participant.participantId,
                    hasVideo: participant.hasVideo,
                    mirror: participant.isSelf,
                  ),
                ),
              )
            else
              Center(child: ProfileCircleAvatar(radius: 36, image: image)),
            if (displayName.isNotEmpty)
              Positioned(
                bottom: 8,
                left: 8,
                child: Text(
                  displayName,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    shadows: const [Shadow(blurRadius: 4)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
