import 'dart:async';

import 'package:flutter/foundation.dart';

/// A utility class for executing a timed action with optional
/// completion callback.
class TimedAction {
  /// Creates a [TimedAction].
  ///
  /// [onRun] is executed immediately when [start] is called.
  /// [onComplete] is invoked once the timer finishes.
  TimedAction({
    required void Function(List<dynamic>? args) onRun,
    VoidCallback? onComplete,
    required Duration duration,
  }) : _duration = duration,
       _onComplete = onComplete,
       _execute = onRun;

  Timer? _timer;
  final void Function(List<dynamic>? args) _execute;
  final VoidCallback? _onComplete;
  final Duration _duration;

  /// Cancels the running timer. No callbacks are invoked.
  ///
  /// Any side-effects on cancellation (e.g. clearing UI state) are the
  /// caller's responsibility.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels the running timer without invoking callbacks.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Completes the action, cancels the timer,
  /// and invokes [_onComplete] if provided.
  void _complete() {
    _onComplete?.call();

    if (_timer == null) {
      return;
    }

    _timer!.cancel();
    _timer = null;
  }

  /// Starts the timed action with optional [args].
  ///
  /// - Immediately calls [_execute] with [args].
  /// - Sets a timer that will call [_complete] after [_duration].
  /// - Does nothing if already running.
  void start({List<dynamic>? args = const []}) {
    if (_timer != null) return;

    _timer = Timer(_duration, _complete);
    _execute.call(args);
  }
}
