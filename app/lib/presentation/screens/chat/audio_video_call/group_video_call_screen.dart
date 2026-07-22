import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_livekit_flutter/meeting_place_livekit_flutter.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../application/services/contacts_service/contacts_service.dart';
import '../../../../application/services/identities_service/identities_service.dart';
import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../widgets/call/call_overlay_widgets.dart';
import '../../../widgets/call/call_participant_mute_badge.dart';
import '../../../widgets/call/call_top_bar_widget.dart';
import '../../../widgets/call/video_call_pip_action_buttons.dart';
import '../../../widgets/call/video_call_pip_window.dart';
import '../../../widgets/profile_circle_avatar.dart';
import 'audio_video_call_screen_controller.dart';
import 'extensions/group_video_call_extensions.dart';
import 'rules/call_participant_identity_rules.dart';
import 'rules/group_call_layout_rules.dart';
import 'rules/group_call_participant_presentation_rules.dart';
import 'rules/group_video_call_view_rules.dart';

part 'group/group_video_call_content.dart';
part 'group/group_video_call_stage_widgets.dart';
part 'group/group_video_call_tile_widgets.dart';
part 'group/group_video_call_top_bar_widgets.dart';

class GroupVideoCallScreen extends ConsumerStatefulWidget {
  const GroupVideoCallScreen({
    super.key,
    required this.contactId,
    required this.controls,
    required this.onMinimize,
    required this.onSwitchCamera,
  });

  final String contactId;
  final Widget controls;
  final VoidCallback onMinimize;
  final VoidCallback onSwitchCamera;

  @override
  ConsumerState<GroupVideoCallScreen> createState() =>
      _GroupVideoCallScreenState();
}

class _GroupVideoCallScreenState extends ConsumerState<GroupVideoCallScreen> {
  static const double _defaultFocusedStageTopPadding = 16;
  static const double _hiddenControlsFocusedStageTopPadding = 24;
  static const double _headerBottomSpacing = 12;

  late final PageController _pageController;
  double? _headerHeight;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topSafeAreaInset = MediaQuery.paddingOf(context).top;
    final provider = audioVideoCallScreenControllerProvider(widget.contactId);
    final controller = ref.read(provider.notifier);
    final state = ref.watch(provider);
    final showControls = state.showControlsBar;
    final session = state.session;
    final memberContactCards = state.memberContactCards;
    final isCameraEnabled = state.isCameraEnabled;
    final view = state.groupVideoCallData(youLabel: context.l10n.you);
    final layoutConfig = view.layoutConfig;
    final showFullScreenSelfStage = layoutConfig.showFullScreenFocusedSelfStage;

    final focusedStageTopPadding = _focusedStageTopPadding(
      topSafeAreaInset: topSafeAreaInset,
      showControls: showControls,
      layout: layoutConfig.layout,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggleControlsBar,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showFullScreenSelfStage)
              Positioned.fill(
                child: _FocusedParticipantStage(
                  participant: view.focusedParticipant,
                  session: session,
                  memberContactCards: memberContactCards,
                  isCameraEnabled: isCameraEnabled,
                  label: view.focusedParticipantLabel,
                  isFullScreen: true,
                ),
              ),
            Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: _GroupVideoCallContent(
                          contactId: widget.contactId,
                          pageController: _pageController,
                          showControls: showControls,
                          view: view,
                          session: session,
                          memberContactCards: memberContactCards,
                          isCameraEnabled: isCameraEnabled,
                          onTapParticipant: _focusParticipantFromTile,
                          focusedStageTopPadding: focusedStageTopPadding,
                          onSwitchCamera: widget.onSwitchCamera,
                        ),
                      ),
                      CallTopBarOverlay(
                        visible: showControls,
                        child: _MeasuredTopBar(
                          onHeightChanged: _updateHeaderHeight,
                          contactId: widget.contactId,
                          onMinimize: widget.onMinimize,
                          onSwitchCamera: widget.onSwitchCamera,
                          showSwitchCamera: layoutConfig.showHeaderSwitchCamera,
                        ),
                      ),
                      CallControlsOverlay(
                        visible: showControls,
                        child: widget.controls,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Updates header height if it differs from the last stored value.
  void _updateHeaderHeight(double height) {
    if (!mounted) return;
    if (height != _headerHeight) {
      setState(() => _headerHeight = height);
    }
  }

  /// Sets focused participant and jumps paging to first page.
  void _focusParticipantFromTile(String? participantId) {
    final controller = ref.read(
      audioVideoCallScreenControllerProvider(widget.contactId).notifier,
    );
    controller.setFocusedParticipant(participantId);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }

  /// Computes focused stage top padding based on layout and visibility.
  double _focusedStageTopPadding({
    required double topSafeAreaInset,
    required bool showControls,
    required GroupCallLayout layout,
  }) {
    if (layout != GroupCallLayout.twoPeerRow &&
        layout != GroupCallLayout.pagedGrid) {
      return _defaultFocusedStageTopPadding;
    }

    if (!showControls) {
      return topSafeAreaInset + _hiddenControlsFocusedStageTopPadding;
    }

    final headerHeight = _headerHeight;
    if (headerHeight == null) {
      return _defaultFocusedStageTopPadding;
    }

    return headerHeight + _headerBottomSpacing;
  }
}
