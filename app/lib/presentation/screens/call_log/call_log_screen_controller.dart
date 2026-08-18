import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/call_log_service/call_log_service.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'call_log_screen_state.dart';

part 'call_log_screen_controller.g.dart';

const _logKey = 'CallLogScreenController';

@riverpod
class CallLogScreenController extends _$CallLogScreenController {
  bool _isDisposed = false;
  bool _isLoadInFlight = false;

  @override
  CallLogScreenState build() {
    ref.onDispose(() {
      _isDisposed = true;
    });

    Future.microtask(_load);

    return CallLogScreenState();
  }

  Future<void> _load() async {
    if (_isDisposed || _isLoadInFlight) return;
    _isLoadInFlight = true;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final entries = await ref.read(callLogEntriesProvider.future);
      if (_isDisposed) return;
      state = state.copyWith(isLoading: false, entries: entries);
    } catch (error, stackTrace) {
      if (_isDisposed) return;
      ref
          .read(appLoggerProvider)
          .error(
            'callLogEntries load failed',
            error: error,
            stackTrace: stackTrace,
            name: _logKey,
          );
      state = state.copyWith(isLoading: false, errorMessage: 'error');
    } finally {
      _isLoadInFlight = false;
    }
  }

  Future<void> refresh() async {
    if (_isLoadInFlight) return;
    ref.invalidate(callLogEntriesProvider);
    await _load();
  }
}
