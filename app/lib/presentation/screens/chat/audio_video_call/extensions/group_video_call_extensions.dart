import '../rules/group_call_layout_rules.dart';
import '../rules/group_video_call_view_rules.dart';

extension GroupVideoCallDataExtensions on GroupVideoCallData {
  /// Whether participant tiles are configured and available to display.
  bool get hasTiles => layoutConfig.showParticipantTiles && pages.isNotEmpty;

  /// The tile entries for the first pagination page, if any exist.
  List<ParticipantTileData>? get firstPageEntries => pages.firstOrNull;
}

extension GroupCallLayoutConfigExtensions on GroupCallLayoutConfig {
  /// Whether the layout should account for peer participant presence.
  bool get hasPeerParticipants => peerParticipantCount > 0;
}
