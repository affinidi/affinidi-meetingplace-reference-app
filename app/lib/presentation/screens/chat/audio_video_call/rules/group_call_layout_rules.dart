import 'package:meeting_place_matrix/meeting_place_matrix.dart';

/// Single source of truth for group video call layout selection.
///
/// Widgets should render the resolved layout spec instead of re-deriving
/// joiner-count behavior with local booleans.

/// The visual layout mode for a group call based on joiner count.
enum GroupCallLayout {
  /// Self only, no peer participants.
  selfOnly,

  /// One peer participant staged full-screen with self as PiP.
  singlePeerStage,

  /// Two peer participants shown in a single row.
  twoPeerRow,

  /// Multiple peer participants in a paged grid layout.
  pagedGrid,
}

/// Layout decisions for rendering a group call screen.
class GroupCallLayoutConfig {
  const GroupCallLayoutConfig({
    required this.layout,
    required this.peerParticipantCount,
    required this.tileColumns,
    required this.tileRowsPerPage,
    required this.tileHeight,
    required this.showFullScreenFocusedSelfStage,
    required this.showSinglePeerStage,
    required this.showParticipantTiles,
    required this.showPaginationIndicator,
    required this.showHeaderSwitchCamera,
  });

  /// The resolved layout for this call state.
  final GroupCallLayout layout;

  /// The number of peer (non-self) participants in the call.
  final int peerParticipantCount;

  /// The number of tile columns to render per row.
  final int tileColumns;

  /// The number of tile rows to render per page.
  final int tileRowsPerPage;

  /// The tile height for the current layout.
  final double tileHeight;

  /// Whether to show the focused participant as a full-screen stage (self
  /// only, no peers).
  final bool showFullScreenFocusedSelfStage;

  /// Whether to show the single peer stage layout.
  final bool showSinglePeerStage;

  /// Whether to show the participant tiles in a paged grid.
  final bool showParticipantTiles;

  /// Whether to show the page indicator dots (only when tiles are paginated).
  final bool showPaginationIndicator;

  /// Whether to show the switch-camera button in the top bar header.
  final bool showHeaderSwitchCamera;
}

/// Resolves the layout config based on participant count and pagination state.
GroupCallLayoutConfig resolveGroupCallLayoutConfig({
  required List<AudioVideoCallParticipant> participants,
  required AudioVideoCallParticipant focusedParticipant,
  required int pageCount,
}) {
  final peerParticipantCount = participants.where((p) => !p.isSelf).length;
  final showFullScreenFocusedSelfStage =
      peerParticipantCount == 0 && focusedParticipant.isSelf;
  final layout = switch (peerParticipantCount) {
    0 => GroupCallLayout.selfOnly,
    1 => GroupCallLayout.singlePeerStage,
    2 => GroupCallLayout.twoPeerRow,
    _ => GroupCallLayout.pagedGrid,
  };
  final tileColumns = switch (layout) {
    GroupCallLayout.twoPeerRow => 2,
    GroupCallLayout.pagedGrid => 3,
    _ => 0,
  };
  final tileRowsPerPage = switch (layout) {
    GroupCallLayout.twoPeerRow => 1,
    GroupCallLayout.pagedGrid => 2,
    _ => 0,
  };
  final tileHeight = switch (layout) {
    GroupCallLayout.twoPeerRow => 180.0,
    GroupCallLayout.pagedGrid => 104.0,
    _ => 104.0,
  };

  return GroupCallLayoutConfig(
    layout: layout,
    peerParticipantCount: peerParticipantCount,
    tileColumns: tileColumns,
    tileRowsPerPage: tileRowsPerPage,
    tileHeight: tileHeight,
    showFullScreenFocusedSelfStage: showFullScreenFocusedSelfStage,
    showSinglePeerStage: layout == GroupCallLayout.singlePeerStage,
    showParticipantTiles:
        layout == GroupCallLayout.twoPeerRow ||
        layout == GroupCallLayout.pagedGrid,
    showPaginationIndicator:
        (layout == GroupCallLayout.twoPeerRow ||
            layout == GroupCallLayout.pagedGrid) &&
        pageCount > 1,
    showHeaderSwitchCamera: peerParticipantCount == 0,
  );
}
