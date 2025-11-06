import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../infrastructure/loggers/app_logger/log_constants.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import 'debug_panel_state.dart';

part 'debug_panel_controller.g.dart';

@riverpod
class DebugPanelController extends _$DebugPanelController {
  static const _logKey = 'UXDBG';

  late final ScrollController _scrollController;
  bool _isAtBottom = true;

  @override
  DebugPanelState build() {
    _logPanelOpened();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    ref.listen(
      appLoggerProvider.select((logger) => logger.logs),
      (prev, next) {
        final wasAtBottom = _isAtBottom;
        Future.microtask(() {
          state = state.copyWith(logs: next);
        });

        if (prev != null && next.length > prev.length && wasAtBottom) {
          Future.microtask(scrollToBottom);
        }
      },
      fireImmediately: true,
    );

    ref.onDispose(() {
      _scrollController.dispose();
    });

    return DebugPanelState(
      logs: ref.read(appLoggerProvider).logs,
      isAtBottom: _isAtBottom,
    );
  }

  void initialize() {
    final logs = ref.read(appLoggerProvider).logs;
    if (logs.isNotEmpty && _scrollController.hasClients) {
      scrollToBottom();
    }
  }

  ScrollController get scrollController => _scrollController;

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final isAtBottom = position.pixels >= position.maxScrollExtent - 10;

    if (isAtBottom != _isAtBottom) {
      _isAtBottom = isAtBottom;
      state = state.copyWith(isAtBottom: isAtBottom);
    }
  }

  void scrollToBottom() {
    if (!_scrollController.hasClients) return;

    Future(() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent * 2.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void scrollToTop() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _logPanelOpened() {
    ref.read(appLoggerProvider).info('Panel opened', name: _logKey);
  }

  void clearLogs() {
    ref.read(appLoggerProvider).clearLogs();
    state = state.copyWith(logs: []);
  }

  void addTestLog() {
    ref.read(appLoggerProvider).info(
          'Test log message ${DateTime.now().millisecondsSinceEpoch}',
          name: _logKey,
        );
    state = state.copyWith(logs: ref.read(appLoggerProvider).logs);
    Future(scrollToBottom);
  }

  bool isSdkLog(String loggerName) {
    final isAppLog = loggerName.contains(LogConstants.logName);

    return !isAppLog;
  }
}
