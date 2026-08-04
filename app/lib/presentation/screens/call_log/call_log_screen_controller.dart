import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/call_log_service/call_log_service.dart';
import 'call_log_screen_state.dart';

part 'call_log_screen_controller.g.dart';

@riverpod
class CallLogScreenController extends _$CallLogScreenController {
  bool _isDisposed = false;

  @override
  CallLogScreenState build() {
    ref.onDispose(() {
      _isDisposed = true;
    });

    Future.microtask(_load);

    return CallLogScreenState();
  }

  Future<void> _load() async {
    if (_isDisposed) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final entries = await ref.read(callLogEntriesProvider.future);
      if (_isDisposed) return;
      state = state.copyWith(isLoading: false, entries: entries);
    } catch (error) {
      if (_isDisposed) return;
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> refresh() async {
    ref.invalidate(callLogEntriesProvider);
    await _load();
  }
}
