import 'dart:async';

import 'package:flutter/foundation.dart';

/// A utility class for executing a timed action with optional
/// cancel and completion callbacks.
class TimedAction {
  /// Creates a [TimedAction].
  ///
  /// [onRun] is executed immediately when [start] is called.
  /// [onCancel] is invoked if [cancel] is called before completion.
  /// [onComplete] is invoked once the timer finishes.
  TimedAction({
    required void Function(List<dynamic>? args) onRun,
    VoidCallback? onCancel,
    VoidCallback? onComplete,
    required Duration duration,
  }) : _duration = duration,
       _onCancel = onCancel,
       _onComplete = onComplete,
       _execute = onRun;

  Timer? _timer;
  final void Function(List<dynamic>? args) _execute;
  final VoidCallback? _onCancel;
  final VoidCallback? _onComplete;
  final Duration _duration;

  /// Cancels the running timer and invokes [_onCancel] if provided.
  void cancel() {
    if (_timer == null) {
      return;
    }

    _onCancel?.call();

    _timer!.cancel();
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
