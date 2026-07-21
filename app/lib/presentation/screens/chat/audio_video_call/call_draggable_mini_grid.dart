part of 'audio_video_call_screen.dart';

class _CallDraggableMiniGrid extends HookWidget {
  const _CallDraggableMiniGrid({
    required this.participants,
    required this.session,
    required this.displayNames,
    required this.isAudioOnly,
    required this.miniGridExpanded,
    required this.onToggleMiniGridExpanded,
    required this.onTapParticipant,
    required this.memberContactCards,
  });

  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final List<String> displayNames;
  final bool isAudioOnly;
  final bool miniGridExpanded;
  final VoidCallback onToggleMiniGridExpanded;
  final void Function(int index) onTapParticipant;
  final Map<String, ContactCard> memberContactCards;

  static const double _tileSize = 64;
  static const double _spacing = 4;
  static const int _maxColumns = 2;
  static const int _maxCollapsed = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;

    final alignment = useState(const Alignment(1.0, -1.0));

    final hasOverflow = participants.length > _maxCollapsed;
    final isExpanded = miniGridExpanded && hasOverflow;
    final visibleCount = isExpanded
        ? participants.length
        : participants.length.clamp(0, _maxCollapsed);
    final overflow = participants.length - _maxCollapsed;

    final columns = visibleCount == 1 ? 1 : _maxColumns;
    final collapsedRows = (visibleCount / columns).ceil();
    final width = columns * _tileSize + (columns - 1) * _spacing + 8;

    const barHeight = 28.0;

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
            color: colors.grey900.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colors.grey900.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(
                child: !isExpanded
                    ? _CallMiniGridTileWrap(
                        count: visibleCount,
                        isExpandedMode: false,
                        participants: participants,
                        session: session,
                        displayNames: displayNames,
                        isAudioOnly: isAudioOnly,
                        onTapParticipant: onTapParticipant,
                        memberContactCards: memberContactCards,
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
                          child: _CallMiniGridTileWrap(
                            count: visibleCount,
                            isExpandedMode: true,
                            expandedNotifier: null,
                            onCollapse: onToggleMiniGridExpanded,
                            participants: participants,
                            session: session,
                            displayNames: displayNames,
                            isAudioOnly: isAudioOnly,
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
                            memberContactCards: memberContactCards,
                          ),
                        ),
                      )
                    : _CallMiniGridTileWrap(
                        count: visibleCount,
                        isExpandedMode: true,
                        expandedNotifier: null,
                        onCollapse: onToggleMiniGridExpanded,
                        participants: participants,
                        session: session,
                        displayNames: displayNames,
                        isAudioOnly: isAudioOnly,
                        onTapParticipant: onTapParticipant,
                        memberContactCards: memberContactCards,
                      ),
              ),
              if (hasOverflow)
                GestureDetector(
                  onTap: onToggleMiniGridExpanded,
                  child: Container(
                    height: barHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.grey900.withValues(alpha: 0.9),
                      borderRadius: const BorderRadius.vertical(
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
                          color: colorScheme.onSurface,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isExpanded
                              ? context.l10n.videoCallShowLess
                              : context.l10n.videoCallShowMore(overflow),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface,
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

class _CallMiniGridTileWrap extends StatelessWidget {
  const _CallMiniGridTileWrap({
    required this.count,
    required this.isExpandedMode,
    required this.participants,
    required this.session,
    required this.displayNames,
    required this.isAudioOnly,
    required this.onTapParticipant,
    required this.memberContactCards,
    this.expandedNotifier,
    this.onCollapse,
  });

  final int count;
  final bool isExpandedMode;
  final List<AudioVideoCallParticipant> participants;
  final AudioVideoCallSession? session;
  final List<String> displayNames;
  final bool isAudioOnly;
  final void Function(int index) onTapParticipant;
  final Map<String, ContactCard> memberContactCards;
  final ValueNotifier<bool>? expandedNotifier;
  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _CallDraggableMiniGrid._spacing,
      runSpacing: _CallDraggableMiniGrid._spacing,
      children: [
        for (var i = 0; i < count; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isExpandedMode
                ? () {
                    expandedNotifier?.value = false;
                    onCollapse?.call();
                    onTapParticipant(i);
                  }
                : null,
            child: SizedBox(
              width: _CallDraggableMiniGrid._tileSize,
              height: _CallDraggableMiniGrid._tileSize,
              child: IgnorePointer(
                child: _CallParticipantTile(
                  participant: participants[i],
                  session: session,
                  isAudioOnly: isAudioOnly,
                  displayName: displayNames[i],
                  borderRadius: 8,
                  contactCard: _contactCardFor(
                    participants[i],
                    memberContactCards: memberContactCards,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
