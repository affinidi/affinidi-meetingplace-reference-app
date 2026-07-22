part of '../group_video_call_screen.dart';

class _GroupVideoCallContent extends ConsumerWidget {
  const _GroupVideoCallContent({
    required this.contactId,
    required this.pageController,
    required this.showControls,
    required this.view,
    required this.session,
    required this.memberContactCards,
    required this.isCameraEnabled,
    required this.onTapParticipant,
    required this.focusedStageTopPadding,
    required this.onSwitchCamera,
  });

  final String contactId;
  final PageController pageController;
  final bool showControls;
  final GroupVideoCallData view;
  final AudioVideoCallSession? session;
  final Map<String, ContactCard> memberContactCards;
  final bool isCameraEnabled;
  final ValueChanged<String?> onTapParticipant;
  final double focusedStageTopPadding;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = audioVideoCallScreenControllerProvider(contactId);
    final isMicEnabled = ref.watch(
      provider.select((state) => state.isMicEnabled),
    );
    final micPermissionError = ref.watch(
      provider.select((state) => state.micPermissionError),
    );
    final cameraPermissionError = ref.watch(
      provider.select((state) => state.cameraPermissionError),
    );
    final controller = ref.read(provider.notifier);

    final layoutConfig = view.layoutConfig;
    final singlePeerParticipant = view.singlePeerParticipant;
    final selfParticipant = view.selfParticipant;
    final showFullScreenSelfStage = layoutConfig.showFullScreenFocusedSelfStage;
    final layoutMetrics = _ContentLayoutMetrics.resolve(
      context: context,
      showControls: showControls,
      layoutConfig: layoutConfig,
      firstPageEntries: view.firstPageEntries,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (layoutConfig.showSinglePeerStage &&
            singlePeerParticipant != null &&
            selfParticipant != null)
          Positioned.fill(
            child: _SinglePeerVideoStage(
              contactId: contactId,
              peerParticipant: singlePeerParticipant,
              selfParticipant: selfParticipant,
              session: session,
              memberContactCards: memberContactCards,
              isCameraEnabled: isCameraEnabled,
              showControlsBar: showControls,
              isMicEnabled: isMicEnabled,
              micPermissionError: micPermissionError,
              cameraPermissionError: cameraPermissionError,
              onToggleMic: controller.toggleMic,
              onSwitchCamera: onSwitchCamera,
            ),
          )
        else if (!showFullScreenSelfStage)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: focusedStageTopPadding,
                bottom: layoutMetrics.tilesBottom,
              ),
              child: _GroupVideoCallPagedBody(
                view: view,
                session: session,
                memberContactCards: memberContactCards,
                isCameraEnabled: isCameraEnabled,
                onTapParticipant: onTapParticipant,
                pageController: pageController,
                tileBlockHeight: layoutMetrics.tileBlockHeight,
              ),
            ),
          ),
        if (view.showPaginationIndicator)
          Positioned(
            left: 0,
            right: 0,
            bottom: layoutMetrics.indicatorBottom,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: view.pages.length,
                effect: WormEffect(
                  dotWidth: 8,
                  dotHeight: 8,
                  dotColor: context.customColors.whiteOverlay30,
                  activeDotColor: context.customColors.cyan,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Encapsulates computed vertical layout measurements for tiles, pagination,
/// and controls.
class _ContentLayoutMetrics {
  /// Computes layout metrics from context, controls visibility, and
  /// participant entries.
  factory _ContentLayoutMetrics.resolve({
    required BuildContext context,
    required bool showControls,
    required GroupCallLayoutConfig layoutConfig,
    required List<ParticipantTileData>? firstPageEntries,
  }) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final controlsReservedHeight =
        bottomPadding +
        (showControls
            ? _expandedControlsBottomInset
            : _compactControlsBottomInset);
    final hasPeer = layoutConfig.hasPeerParticipants;

    return _ContentLayoutMetrics(
      tileBlockHeight: _tileBlockHeight(
        firstPageEntries: firstPageEntries,
        layoutConfig: layoutConfig,
      ),
      indicatorBottom: hasPeer
          ? controlsReservedHeight
          : _indicatorBottomWithoutPeers,
      tilesBottom: hasPeer
          ? controlsReservedHeight + _tilesToIndicatorGap
          : controlsReservedHeight,
    );
  }

  /// Creates layout metrics with the specified vertical measurements.
  const _ContentLayoutMetrics({
    required this.tileBlockHeight,
    required this.indicatorBottom,
    required this.tilesBottom,
  });

  static const double _tileSpacing = 8.0;
  static const double _compactControlsBottomInset = 20.0;
  static const double _expandedControlsBottomInset = 148.0;
  static const double _indicatorBottomWithoutPeers = 8.0;
  static const double _tilesToIndicatorGap = 28.0;

  final double tileBlockHeight;
  final double indicatorBottom;
  final double tilesBottom;

  /// Calculates total height for the tile grid.
  static double _tileBlockHeight({
    required List<ParticipantTileData>? firstPageEntries,
    required GroupCallLayoutConfig layoutConfig,
  }) {
    if (firstPageEntries == null || firstPageEntries.isEmpty) {
      return 0.0;
    }

    final rowCount =
        ((firstPageEntries.length - 1) ~/ layoutConfig.tileColumns) + 1;
    return (rowCount * layoutConfig.tileHeight) +
        ((rowCount - 1) * _tileSpacing);
  }
}

class _GroupVideoCallPagedBody extends StatelessWidget {
  const _GroupVideoCallPagedBody({
    required this.view,
    required this.session,
    required this.memberContactCards,
    required this.isCameraEnabled,
    required this.onTapParticipant,
    required this.pageController,
    required this.tileBlockHeight,
  });

  final GroupVideoCallData view;
  final AudioVideoCallSession? session;
  final Map<String, ContactCard> memberContactCards;
  final bool isCameraEnabled;
  final ValueChanged<String?> onTapParticipant;
  final PageController pageController;
  final double tileBlockHeight;

  @override
  Widget build(BuildContext context) {
    if (!view.hasTiles) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _FocusedParticipantStage(
          participant: view.focusedParticipant,
          session: session,
          memberContactCards: memberContactCards,
          isCameraEnabled: isCameraEnabled,
          label: view.focusedParticipantLabel,
        ),
      );
    }

    return PageView.builder(
      controller: pageController,
      itemCount: view.pages.length,
      itemBuilder: (context, pageIndex) {
        if (pageIndex == 0) {
          return _GroupVideoCallFirstPage(
            view: view,
            session: session,
            memberContactCards: memberContactCards,
            isCameraEnabled: isCameraEnabled,
            onTapParticipant: onTapParticipant,
            tileBlockHeight: tileBlockHeight,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.topCenter,
            child: _ParticipantGrid(
              tileColumns: view.layoutConfig.tileColumns,
              tileHeight: view.layoutConfig.tileHeight,
              entries: view.pages[pageIndex],
              session: session,
              memberContactCards: memberContactCards,
              isCameraEnabled: isCameraEnabled,
              onTapParticipant: onTapParticipant,
            ),
          ),
        );
      },
    );
  }
}

class _GroupVideoCallFirstPage extends StatelessWidget {
  const _GroupVideoCallFirstPage({
    required this.view,
    required this.session,
    required this.memberContactCards,
    required this.isCameraEnabled,
    required this.onTapParticipant,
    required this.tileBlockHeight,
  });

  final GroupVideoCallData view;
  final AudioVideoCallSession? session;
  final Map<String, ContactCard> memberContactCards;
  final bool isCameraEnabled;
  final ValueChanged<String?> onTapParticipant;
  final double tileBlockHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FocusedParticipantStage(
              participant: view.focusedParticipant,
              session: session,
              memberContactCards: memberContactCards,
              isCameraEnabled: isCameraEnabled,
              label: view.focusedParticipantLabel,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: tileBlockHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ParticipantGrid(
              tileColumns: view.layoutConfig.tileColumns,
              tileHeight: view.layoutConfig.tileHeight,
              entries: view.pages.first,
              session: session,
              memberContactCards: memberContactCards,
              isCameraEnabled: isCameraEnabled,
              onTapParticipant: onTapParticipant,
            ),
          ),
        ),
      ],
    );
  }
}
