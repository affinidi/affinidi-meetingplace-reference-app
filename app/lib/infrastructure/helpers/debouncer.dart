import 'dart:async';
import 'package:flutter/widgets.dart';

import '../configuration/environment.dart';

/// Utility to debounce function calls
class Debouncer {
  Debouncer({Duration? duration})
      : _duration = duration ?? Environment.instance.inputDebounceDuration;

  final Duration _duration;
  Timer? _timer;

  /// Runs the debouncer after the specified duration
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(_duration, action);
  }

  /// Cancel any pending debounced action
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
