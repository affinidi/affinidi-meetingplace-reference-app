import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../infrastructure/loggers/app_logger/app_log_entry.dart';

part 'debug_panel_state.freezed.dart';

@freezed
abstract class DebugPanelState with _$DebugPanelState {
  const factory DebugPanelState({
    @Default([]) List<AppLogEntry> logs,
    @Default(true) bool isAtBottom,
  }) = _DebugPanelState;
}
