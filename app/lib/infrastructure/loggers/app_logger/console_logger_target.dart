import 'dart:developer';

import 'app_log_entry.dart';
import 'log_constants.dart';
import 'logger_target.dart';

class ConsoleLoggerTarget implements LoggerTarget {
  final List<AppLogEntry> _logs = [];

  bool _isSdkLog(String loggerName) {
    final isAppLog = loggerName.contains(LogConstants.logName);
    return !isAppLog;
  }

  String _formatLoggerName(String loggerName) {
    return _isSdkLog(loggerName)
        ? loggerName
        : '[${LogConstants.logName}] $loggerName';
  }

  @override
  List<AppLogEntry> get logs => List.unmodifiable(_logs);

  @override
  void logInfo(String loggerName, String message) {
    final formatted = _formatLoggerName(loggerName);
    log('$formatted $message', name: 'INFO');
  }

  @override
  void logError(String loggerName, String message) {
    final formatted = _formatLoggerName(loggerName);
    log('$formatted $message', name: 'ERROR');
  }

  @override
  void logWarning(String loggerName, String message) {
    final formatted = _formatLoggerName(loggerName);
    log('$formatted $message', name: 'WARNING');
  }

  @override
  void logDebug(String loggerName, String message) {
    final formatted = _formatLoggerName(loggerName);
    log('$formatted $message', name: 'DEBUG');
  }

  @override
  void clearLogs() {
    _logs.clear();
  }
}
