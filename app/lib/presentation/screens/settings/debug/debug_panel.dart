import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/loggers/app_logger/app_log_entry.dart';
import '../../../../infrastructure/loggers/app_logger/log_constants.dart';
import 'debug_panel_controller.dart';

class DebugPanel extends HookConsumerWidget {
  const DebugPanel({super.key});

  void _copyLogsToClipboard(BuildContext context, WidgetRef ref) {
    final logs = ref.read(debugPanelControllerProvider).logs;
    final buffer = StringBuffer('=== DEBUG LOGS ===\n');
    final timeFormatter = DateFormat.Hms();

    for (final log in logs) {
      buffer.writeln(
        '[${timeFormatter.format(log.timestamp)}] '
        '[${log.level}] ${log.loggerName} ${log.message}',
      );
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.debugPanelLogsCopied),
        backgroundColor: context.colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(debugPanelControllerProvider);
    final controller = ref.read(debugPanelControllerProvider.notifier);
    final l10n = context.l10n;

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        controller.initialize();
      });

      return null;
    }, []);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        foregroundColor: context.colorScheme.onSurface,
        title: Text(l10n.debugPanelTitle),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => switch (value) {
              LogConstants.clearLogs => controller.clearLogs(),
              LogConstants.copyLogs => _copyLogsToClipboard(context, ref),
              LogConstants.shareLogs => controller.shareLogFile(),
              LogConstants.addTestLog => controller.addTestLog(),
              _ => null,
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: LogConstants.clearLogs,
                child: Text(l10n.debugPanelClearLogs),
              ),
              PopupMenuItem(
                value: LogConstants.copyLogs,
                child: Text(l10n.debugPanelCopyLogs),
              ),
              PopupMenuItem(
                value: LogConstants.shareLogs,
                child: Text(l10n.debugPanelShareLogs),
              ),
              PopupMenuItem(
                value: LogConstants.addTestLog,
                child: Text(l10n.debugPanelAddTestLog),
              ),
            ],
          ),
        ],
      ),
      body: state.logs.isEmpty
          ? const _EmptyState()
          : _LogsList(
              logs: state.logs,
              scrollController: controller.scrollController,
              controller: controller,
            ),
      floatingActionButton: state.logs.isNotEmpty
          ? _DebugFAB(
              isAtBottom: state.isAtBottom,
              onScrollToTop: controller.scrollToTop,
              onScrollToBottom: controller.scrollToBottom,
            )
          : null,
    );
  }
}

class _LogsList extends StatelessWidget {
  const _LogsList({
    required this.logs,
    required this.scrollController,
    required this.controller,
  });

  final List<AppLogEntry> logs;
  final ScrollController scrollController;
  final DebugPanelController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Container(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: false,
        thickness: 1,
        radius: const Radius.circular(3),
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(8),
          itemCount: logs.length,
          itemBuilder: (context, index) => _LogEntry(
            log: logs[index],
            textTheme: textTheme,
            colorScheme: colorScheme,
            controller: controller,
          ),
        ),
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  const _LogEntry({
    required this.log,
    required this.textTheme,
    required this.colorScheme,
    required this.controller,
  });

  final AppLogEntry log;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final DebugPanelController controller;

  static final _timeFormatter = DateFormat.Hms();

  Color _getLogColor({
    required String level,
    required String loggerName,
    required BuildContext context,
  }) {
    final isSdk = controller.isSdkLog(loggerName);
    final logColors = context.logColors;

    return switch ((level.toUpperCase(), isSdk)) {
      ('ERROR', true) => logColors.sdkError,
      ('WARNING', true) => logColors.sdkWarning,
      ('DEBUG', true) => logColors.sdkDebug,
      ('INFO', true) => logColors.sdkInfo,
      (_, true) => logColors.sdkOther,
      ('ERROR', false) => logColors.appError,
      ('WARNING', false) => logColors.appWarning,
      ('DEBUG', false) => logColors.appDebug,
      ('INFO', false) => logColors.appInfo,
      (_, false) => logColors.appOther,
    };
  }

  @override
  Widget build(BuildContext context) {
    final logColors = context.logColors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: RichText(
        softWrap: true,
        text: TextSpan(
          style: textTheme.bodySmall?.copyWith(
            fontFamily: 'FiraMono',
            height: 1.4,
            color: colorScheme.onSurface,
            fontSize: 10,
          ),
          children: [
            TextSpan(
              text: '[${_timeFormatter.format(log.timestamp)}] ',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: '[${log.level}] ',
              style: TextStyle(
                color: _getLogColor(
                  level: log.level,
                  loggerName: log.loggerName,
                  context: context,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '${log.loggerName} ',
              style: TextStyle(
                color: controller.isSdkLog(log.loggerName)
                    ? logColors.sdkContext
                    : logColors.appContext,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: log.message.trim(),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.terminal,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.debugPanelNoLogs,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.debugPanelLogsAppearMessage,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DebugFAB extends StatelessWidget {
  const _DebugFAB({
    required this.isAtBottom,
    required this.onScrollToTop,
    required this.onScrollToBottom,
  });

  final bool isAtBottom;
  final VoidCallback onScrollToTop;
  final VoidCallback onScrollToBottom;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return FloatingActionButton(
      onPressed: isAtBottom ? onScrollToTop : onScrollToBottom,
      backgroundColor: Colors.white.withValues(alpha: 0.4),
      elevation: 2,
      mini: true,
      shape: const CircleBorder(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isAtBottom
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          key: ValueKey(isAtBottom),
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
