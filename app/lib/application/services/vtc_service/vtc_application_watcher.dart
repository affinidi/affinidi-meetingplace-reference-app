import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'vtc_service.dart';

/// Checks the member's open join requests, and completes admissions still
/// to settle, when the app starts and each time it comes back to the
/// foreground: a community decides on its own time, and the decision is
/// recorded so it survives a restart.
class VtcApplicationWatcher with WidgetsBindingObserver {
  /// Creates a [VtcApplicationWatcher] checking through a [VtcService].
  VtcApplicationWatcher(this._service);

  final VtcService _service;
  Future<void>? _checking;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(check());
  }

  /// Checks now, unless a check is already running.
  Future<void> check() {
    return _checking ??= _service.checkApplications().whenComplete(
      () => _checking = null,
    );
  }
}

/// Provides the [VtcApplicationWatcher], checking once when first read.
final vtcApplicationWatcherProvider = Provider<VtcApplicationWatcher>((ref) {
  final watcher = VtcApplicationWatcher(ref.read(vtcServiceProvider));
  WidgetsBinding.instance.addObserver(watcher);
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(watcher));
  unawaited(watcher.check());
  return watcher;
}, name: 'vtcApplicationWatcherProvider');
