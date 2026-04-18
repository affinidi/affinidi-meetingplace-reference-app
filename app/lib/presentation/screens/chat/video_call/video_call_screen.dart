import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import 'video_call_screen_controller.dart';
import 'video_call_screen_state.dart';

class VideoCallScreen extends HookConsumerWidget {
  const VideoCallScreen({
    super.key,
    required this.roomId,
    required this.contactId,
    this.audioOnly = false,
  });

  final String roomId;
  final String contactId;
  final bool audioOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final participantEvent = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
        audioOnly,
      ).select((s) => s.participantEvent),
    );

    useEffect(() {
      if (participantEvent == null) return null;

      final message = switch (participantEvent.type) {
        ParticipantEventType.joined => l10n.videoCallParticipantJoined(
          participantEvent.names,
        ),
        ParticipantEventType.left => l10n.videoCallParticipantLeft(
          participantEvent.names,
        ),
      };

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onErrorContainer,
              ),
            ),
            backgroundColor: context.customColors.success,
          ),
        );
      });
      return null;
    }, [participantEvent]);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          audioOnly ? l10n.groupCallVoiceAppBarTitle : l10n.videoCallTitle,
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: _ParticipantGrid(
              roomId: roomId,
              contactId: contactId,
              audioOnly: audioOnly,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantGrid extends HookConsumerWidget {
  const _ParticipantGrid({
    required this.roomId,
    required this.contactId,
    required this.audioOnly,
  });

  final String roomId;
  final String contactId;
  final bool audioOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
        audioOnly,
      ).select((s) => s.status),
    );
    final hasError = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
        audioOnly,
      ).select((s) => s.hasError),
    );
    final error = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
        audioOnly,
      ).select((s) => s.error),
    );
    final participants = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
        audioOnly,
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

    final totalCount = participants.length;

    final showControls = useState(true);
    final focusedIndex = useState<int?>(null);

    if (focusedIndex.value != null && focusedIndex.value! >= totalCount) {
      focusedIndex.value = null;
    }

    if (focusedIndex.value == null) {
      return _GridLayout(
        roomId: roomId,
        contactId: contactId,
        audioOnly: audioOnly,
        participants: participants,
        totalCount: totalCount,
        showControls: showControls,
        focusedIndex: focusedIndex,
      );
    }

    return _FocusedLayout(
      roomId: roomId,
      contactId: contactId,
      audioOnly: audioOnly,
      participants: participants,
      totalCount: totalCount,
      showControls: showControls,
      focusedIndex: focusedIndex,
    );
  }
}

class _DraggableMiniGrid extends HookWidget {
  const _DraggableMiniGrid({
    required this.participants,
    required this.displayNames,
    required this.onTapParticipant,
  });

  final List<Participant?> participants;
  final List<String> displayNames;
  final void Function(int index) onTapParticipant;

  static const double _tileSize = 64;
  static const double _spacing = 4;
  static const int _maxColumns = 2;
  static const int _maxCollapsed = 4;

  @override
  Widget build(BuildContext context) {
    final alignment = useState(const Alignment(1.0, -1.0));
    final expanded = useState(false);

    final hasOverflow = participants.length > _maxCollapsed;
    final isExpanded = expanded.value && hasOverflow;
    final visibleCount = isExpanded
        ? participants.length
        : participants.length.clamp(0, _maxCollapsed);
    final overflow = participants.length - _maxCollapsed;

    final columns = visibleCount == 1 ? 1 : _maxColumns;
    final collapsedRows = (visibleCount / columns).ceil();
    final width = columns * _tileSize + (columns - 1) * _spacing + 8;

    const barHeight = 28.0;

    // In expanded mode, cap height at 60% of screen.
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxExpandedHeight = screenHeight * 0.6;
    final naturalTileHeight =
        collapsedRows * _tileSize + (collapsedRows - 1) * _spacing + 8;
    final totalNatural = naturalTileHeight + (hasOverflow ? barHeight : 0);
    final height = isExpanded
        ? totalNatural.clamp(0.0, maxExpandedHeight)
        : naturalTileHeight + (hasOverflow ? barHeight : 0);
    final tileAreaHeight = height - (hasOverflow ? barHeight : 0);
    final needsScroll = isExpanded && naturalTileHeight > tileAreaHeight;

    final snapController = useAnimationController();
    final miniScrollController = useScrollController();
    final miniPointerDownPixels = useRef(0.0);

    // Capture the alignment at pan-end for the spring interpolation.
    final startX = useRef(0.0);
    final targetX = useRef(1.0);

    useEffect(() {
      void listener() {
        final t = snapController.value;
        alignment.value = Alignment(
          startX.value + (targetX.value - startX.value) * t,
          alignment.value.y,
        );
      }

      snapController.addListener(listener);
      return () => snapController.removeListener(listener);
    }, [snapController]);

    return Align(
      alignment: alignment.value,
      child: GestureDetector(
        onPanStart: isExpanded ? null : (_) => snapController.stop(),
        onPanUpdate: isExpanded
            ? null
            : (details) {
                final size = MediaQuery.sizeOf(context);
                final dx = details.delta.dx / (size.width / 4);
                final dy = details.delta.dy / (size.height / 4);
                alignment.value = Alignment(
                  (alignment.value.x + dx).clamp(-1.0, 1.0),
                  (alignment.value.y + dy).clamp(-1.0, 1.0),
                );
              },
        onPanEnd: isExpanded
            ? null
            : (_) {
                startX.value = alignment.value.x;
                targetX.value = alignment.value.x >= 0 ? 1.0 : -1.0;
                snapController
                  ..reset()
                  ..animateWith(
                    SpringSimulation(
                      const SpringDescription(
                        mass: 1,
                        stiffness: 150,
                        damping: 18,
                      ),
                      0,
                      1,
                      0,
                    ),
                  );
              },
        onTapUp: isExpanded
            ? null
            : (details) {
                final x = details.localPosition.dx - 4;
                final y = details.localPosition.dy - 4;
                final col = (x / (_tileSize + _spacing)).floor();
                final row = (y / (_tileSize + _spacing)).floor();
                final index = row * columns + col;
                if (index >= 0 && index < visibleCount) {
                  onTapParticipant(index);
                }
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              // Tile area.
              Expanded(
                child: !isExpanded
                    ? _MiniGridTileWrap(
                        count: visibleCount,
                        isExpandedMode: false,
                        participants: participants,
                        displayNames: displayNames,
                        onTapParticipant: onTapParticipant,
                      )
                    : needsScroll
                    ? Listener(
                        onPointerDown: (_) {
                          miniPointerDownPixels.value =
                              miniScrollController.hasClients
                              ? miniScrollController.position.pixels
                              : 0.0;
                        },
                        child: SingleChildScrollView(
                          controller: miniScrollController,
                          child: _MiniGridTileWrap(
                            count: visibleCount,
                            isExpandedMode: true,
                            expandedNotifier: expanded,
                            participants: participants,
                            displayNames: displayNames,
                            onTapParticipant: (i) {
                              if (miniScrollController.hasClients &&
                                  (miniScrollController.position.pixels -
                                              miniPointerDownPixels.value)
                                          .abs() >
                                      1.0) {
                                return;
                              }
                              onTapParticipant(i);
                            },
                          ),
                        ),
                      )
                    : _MiniGridTileWrap(
                        count: visibleCount,
                        isExpandedMode: true,
                        expandedNotifier: expanded,
                        participants: participants,
                        displayNames: displayNames,
                        onTapParticipant: onTapParticipant,
                      ),
              ),

              // Expand/collapse bar below the tiles.
              if (hasOverflow)
                GestureDetector(
                  onTap: () => expanded.value = !expanded.value,
                  child: Container(
                    height: barHeight,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isExpanded
                              ? context.l10n.videoCallShowLess
                              : context.l10n.videoCallShowMore(overflow),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniGridTileWrap extends StatelessWidget {
  const _MiniGridTileWrap({
    required this.count,
    required this.isExpandedMode,
    required this.participants,
    required this.displayNames,
    required this.onTapParticipant,
    this.expandedNotifier,
  });

  final int count;
  final bool isExpandedMode;
  final List<Participant?> participants;
  final List<String> displayNames;
  final void Function(int index) onTapParticipant;
  final ValueNotifier<bool>? expandedNotifier;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _DraggableMiniGrid._spacing,
      runSpacing: _DraggableMiniGrid._spacing,
      children: [
        for (var i = 0; i < count; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isExpandedMode
                ? () {
                    // Collapse and focus the tapped participant.
                    expandedNotifier?.value = false;
                    onTapParticipant(i);
                  }
                : null,
            child: SizedBox(
              width: _DraggableMiniGrid._tileSize,
              height: _DraggableMiniGrid._tileSize,
              child: IgnorePointer(
                child: participants[i] != null
                    ? _ParticipantTile(
                        participant: participants[i]!,
                        displayName: displayNames[i],
                        borderRadius: 8,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}

class _GridLayout extends HookConsumerWidget {
  const _GridLayout({
    required this.roomId,
    required this.contactId,
    required this.audioOnly,
    required this.participants,
    required this.totalCount,
    required this.showControls,
    required this.focusedIndex,
  });

  final String roomId;
  final String contactId;
  final bool audioOnly;
  final List<Participant> participants;
  final int totalCount;
  final ValueNotifier<bool> showControls;
  final ValueNotifier<int?> focusedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      videoCallScreenControllerProvider(roomId, contactId, audioOnly)
          .notifier,
    );
    final youLabel = context.l10n.videoCallYou;
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
                  showControls.value = false;
                } else if (notification is ScrollEndNotification) {
                  showControls.value = true;
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
                itemCount: totalCount,
                itemBuilder: (_, i) {
                  final participant = participants[i];
                  return GestureDetector(
                    onTap: () {
                      if (!scrolledSincePointerDown()) {
                        focusedIndex.value = i;
                      }
                    },
                    child: _ParticipantTile(
                      participant: participant,
                      displayName: controller.displayNameFor(
                        participant,
                        youLabel,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          _AnimatedControlsOverlay(
            visible: showControls.value,
            duration: const Duration(milliseconds: 100),
            roomId: roomId,
            contactId: contactId,
            audioOnly: audioOnly,
          ),
        ],
      ),
    );
  }
}

class _FocusedLayout extends ConsumerWidget {
  const _FocusedLayout({
    required this.roomId,
    required this.contactId,
    required this.audioOnly,
    required this.participants,
    required this.totalCount,
    required this.showControls,
    required this.focusedIndex,
  });

  final String roomId;
  final String contactId;
  final bool audioOnly;
  final List<Participant> participants;
  final int totalCount;
  final ValueNotifier<bool> showControls;
  final ValueNotifier<int?> focusedIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      videoCallScreenControllerProvider(roomId, contactId, audioOnly)
          .notifier,
    );
    final youLabel = context.l10n.videoCallYou;

    final fi = focusedIndex.value!;
    final others = <int>[];
    for (var i = 0; i < totalCount; i++) {
      if (i != fi) others.add(i);
    }

    final otherDisplayNames = <String>[];
    final otherParticipants = <Participant?>[];
    for (final idx in others) {
      otherParticipants.add(participants[idx]);
      otherDisplayNames.add(
        controller.displayNameFor(participants[idx], youLabel),
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          // Full-screen focused participant.
          Positioned.fill(
            child: GestureDetector(
              onTap: () => showControls.value = !showControls.value,
              child: _FocusedTile(
                focusedIndex: fi,
                participants: participants,
                controller: controller,
                youLabel: youLabel,
              ),
            ),
          ),

          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: showControls.value ? 1.0 : 0.0,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showControls.value = true;
                        focusedIndex.value = null;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          controller.displayNameFor(participants[fi], youLabel),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (others.isNotEmpty)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: showControls.value ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !showControls.value,
                child: _DraggableMiniGrid(
                  participants: otherParticipants,
                  displayNames: otherDisplayNames,
                  onTapParticipant: (tappedIdx) {
                    focusedIndex.value = others[tappedIdx];
                  },
                ),
              ),
            ),

          _AnimatedControlsOverlay(
            visible: showControls.value,
            duration: const Duration(milliseconds: 150),
            roomId: roomId,
            contactId: contactId,
            audioOnly: audioOnly,
          ),
        ],
      ),
    );
  }
}

/// The full-screen tile for the focused participant.
class _FocusedTile extends StatelessWidget {
  const _FocusedTile({
    required this.focusedIndex,
    required this.participants,
    required this.controller,
    required this.youLabel,
  });

  final int focusedIndex;
  final List<Participant> participants;
  final VideoCallScreenController controller;
  final String youLabel;

  @override
  Widget build(BuildContext context) {
    final participant = participants[focusedIndex];
    final videoTrack = participant.videoTrackPublications
        .where((TrackPublication<Track> pub) => pub.track != null && !pub.muted)
        .firstOrNull;

    return Container(
      color: Colors.grey[900],
      child: videoTrack != null
          ? IgnorePointer(
              child: VideoTrackRenderer(
                videoTrack.track! as VideoTrack,
                fit: VideoViewFit.cover,
              ),
            )
          : const Center(
              child: Icon(Icons.person, color: Colors.white54, size: 48),
            ),
    );
  }
}

/// Animated slide + fade overlay for call controls.
class _AnimatedControlsOverlay extends StatelessWidget {
  const _AnimatedControlsOverlay({
    required this.visible,
    required this.duration,
    required this.roomId,
    required this.contactId,
    required this.audioOnly,
  });

  final bool visible;
  final Duration duration;
  final String roomId;
  final String contactId;
  final bool audioOnly;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSlide(
        duration: duration,
        offset: visible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: duration,
          opacity: visible ? 1.0 : 0.0,
          child: _CallControls(
            roomId: roomId,
            contactId: contactId,
            audioOnly: audioOnly,
          ),
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.participant,
    required this.displayName,
    this.borderRadius = 12,
  });

  final Participant participant;
  final String displayName;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final videoTrack = participant.videoTrackPublications
        .where((TrackPublication<Track> pub) => pub.track != null && !pub.muted)
        .firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (videoTrack != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: VideoTrackRenderer(
                    videoTrack.track! as VideoTrack,
                    fit: VideoViewFit.cover,
                  ),
                ),
              )
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
  const _CallControls({
    required this.roomId,
    required this.contactId,
    required this.audioOnly,
  });

  final String roomId;
  final String contactId;
  final bool audioOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      videoCallScreenControllerProvider(roomId, contactId, audioOnly)
          .notifier,
    );
    final isMicEnabled = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
        audioOnly,
      ).select((s) => s.isMicEnabled),
    );
    final isCameraEnabled = ref.watch(
      videoCallScreenControllerProvider(
        roomId,
        contactId,
        audioOnly,
      ).select((s) => s.isCameraEnabled),
    );
    final l10n = context.l10n;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
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
