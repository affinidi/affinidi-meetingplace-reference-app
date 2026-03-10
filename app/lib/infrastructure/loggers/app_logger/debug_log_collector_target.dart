import 'dart:async';

import 'package:clock/clock.dart';

import 'app_log_entry.dart';
import 'log_constants.dart';
import 'logger_target.dart';

class DebugLogCollectorTarget implements LoggerTarget {
  DebugLogCollectorTarget();

  final StreamController<AppLogEntry> _logController =
      StreamController<AppLogEntry>.broadcast();
  final List<AppLogEntry> _logs = [];

  @override
  List<AppLogEntry> get logs => List.unmodifiable(_logs);

  bool _isSdkLog(String loggerName) {
    final isAppLog = loggerName.contains(LogConstants.logName);
    return !isAppLog;
  }

  /// Prepends [entries] (from a previous session) before any current-run logs.
  void prependHistoricalLogs(List<AppLogEntry> entries) {
    if (entries.isEmpty) return;
    _logs.insertAll(0, entries);
    if (_logs.length > 1000) {
      _logs.removeRange(0, _logs.length - 1000);
    }
  }

  void _addLog(String loggerName, String message, String level) {
    final formattedLoggerName = _isSdkLog(loggerName)
        ? loggerName
        : '[${LogConstants.logName}] $loggerName';
    final entry = AppLogEntry(
      timestamp: clock.now(),
      message: message,
      level: level,
      loggerName: formattedLoggerName,
    );
    _logs.add(entry);
    if (_logs.length > 1000) {
      _logs.removeAt(0);
    }
    _logController.add(entry);
  }

  @override
  void logInfo(String loggerName, String message) {
    _addLog(loggerName, message, 'INFO');
  }

  @override
  void logError(String loggerName, String message) {
    _addLog(loggerName, message, 'ERROR');
  }

  @override
  void logWarning(String loggerName, String message) {
    _addLog(loggerName, message, 'WARNING');
  }

  @override
  void logDebug(String loggerName, String message) {
    _addLog(loggerName, message, 'DEBUG');
  }

  @override
  void clearLogs() {
    _logs.clear();
  }

  void dispose() {
    _logController.close();
  }
}
