import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'vtc_group_chat_service.dart';

/// Decides requests to join the community group chats this phone owns as
/// they arrive, and brings those chats in step with their groups when the
/// app starts and each time it comes back to the foreground: a community
/// changes a group's members and managers on its own time.
class VtcGroupChatWatcher with WidgetsBindingObserver {
  /// Creates a [VtcGroupChatWatcher] working through a [VtcGroupChatService].
  VtcGroupChatWatcher(this._service);

  final VtcGroupChatService _service;
  Future<void>? _syncing;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(sync());
  }

  /// Brings the chats in step now, unless that is already running.
  Future<void> sync() {
    return _syncing ??= _service.syncChats().whenComplete(
      () => _syncing = null,
    );
  }
}

/// Provides the [VtcGroupChatWatcher], deciding join requests from when it
/// is first read, and syncing once then.
final vtcGroupChatWatcherProvider = Provider<VtcGroupChatWatcher>((ref) {
  final service = ref.read(vtcGroupChatServiceProvider);
  final watcher = VtcGroupChatWatcher(service);
  WidgetsBinding.instance.addObserver(watcher);
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(watcher);
    unawaited(service.stop());
  });
  unawaited(service.start());
  unawaited(watcher.sync());
  return watcher;
}, name: 'vtcGroupChatWatcherProvider');
