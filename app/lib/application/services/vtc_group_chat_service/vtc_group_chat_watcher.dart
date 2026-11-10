import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../vtc_service/vtc_service.dart';
import 'vtc_group_chat_service.dart';

/// Decides requests to join the community group chats this phone owns as
/// they arrive, and brings those chats in step with their groups and joins
/// the chats of the member's groups when the app starts, each time it comes
/// back to the foreground, when a membership changes, and every
/// [interval] while it stays in the foreground: a community links a group's
/// chat, and changes a group's members and managers, on its own time, and
/// tells no member's phone when it does.
class VtcGroupChatWatcher with WidgetsBindingObserver {
  /// Creates a [VtcGroupChatWatcher] working through a [VtcGroupChatService].
  VtcGroupChatWatcher(this._service, {this.interval = defaultInterval});

  /// How often the chats are synced while the app is in the foreground.
  static const defaultInterval = Duration(minutes: 1);

  final VtcGroupChatService _service;

  /// How often the chats are synced while the app is in the foreground.
  final Duration interval;

  Future<void>? _syncing;
  Timer? _timer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        startTimer();
        unawaited(sync());
      case AppLifecycleState.paused ||
          AppLifecycleState.hidden ||
          AppLifecycleState.detached:
        stopTimer();
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// Syncs every [interval] from now on, until [stopTimer].
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(sync()));
  }

  /// Stops syncing every [interval].
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Brings the chats in step and joins those of the member's groups now,
  /// unless that is already running.
  Future<void> sync() {
    return _syncing ??= _sync().whenComplete(() => _syncing = null);
  }

  Future<void> _sync() async {
    await _service.syncChats();
    await _service.joinGroupChats();
  }
}

/// Provides the [VtcGroupChatWatcher], deciding join requests from when it
/// is first read, and syncing once then and every interval after.
final vtcGroupChatWatcherProvider = Provider<VtcGroupChatWatcher>((ref) {
  final service = ref.read(vtcGroupChatServiceProvider);
  final watcher = VtcGroupChatWatcher(service);
  WidgetsBinding.instance.addObserver(watcher);
  final memberships = ref
      .read(vtcServiceProvider)
      .membershipsChanged
      .listen((_) => unawaited(watcher.sync()));
  ref.onDispose(() {
    watcher.stopTimer();
    WidgetsBinding.instance.removeObserver(watcher);
    unawaited(memberships.cancel());
    unawaited(service.stop());
  });
  unawaited(service.start());
  unawaited(watcher.sync());
  watcher.startTimer();
  return watcher;
}, name: 'vtcGroupChatWatcherProvider');
