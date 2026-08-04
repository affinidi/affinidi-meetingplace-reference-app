import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/call_log/call_log_entry.dart';

part 'call_log_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class CallLogScreenState with _$CallLogScreenState {
  factory CallLogScreenState({
    @Default(true) bool isLoading,
    @Default([]) List<CallLogEntry> entries,
    String? errorMessage,
  }) = _CallLogScreenState;
}
