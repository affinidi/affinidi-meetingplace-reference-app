import 'dart:io';

import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import 'app_log_entry.dart';
import 'console_logger_target.dart';
import 'debug_log_collector_target.dart';
import 'logger_target.dart';

class AppLogger
    implements MeetingPlaceChatSDKLogger, MeetingPlaceCoreSDKLogger {
  AppLogger._(this._debugCollector, this._loggers);

  static AppLogger? _instance;

  static AppLogger get instance {
    return _instance!;
  }

  static void initialize(File logFile, {int maxLogMemoryEntries = 1000}) {
    if (_instance != null) return;
    final debugCollector = DebugLogCollectorTarget(
      logFile,
      maxMemoryEntries: maxLogMemoryEntries,
    );
    _instance = AppLogger._(debugCollector, <LoggerTarget>[
      ConsoleLoggerTarget(),
      debugCollector,
    ]);
  }

  final DebugLogCollectorTarget _debugCollector;
  final List<LoggerTarget> _loggers;

  /// Path to the persisted log file, or null until initialize completes.
  String get logFilePath => _debugCollector.logFilePath;

  Stream<AppLogEntry> get logStream => _debugCollector.logStream;

  List<AppLogEntry> get logs =>
      List.unmodifiable(_loggers.expand((l) => l.logs).toList());

  @override
  void info(String message, {String name = ''}) {
    for (final logger in _loggers) {
      logger.logInfo(name, message);
    }
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = '',
  }) {
    final fullMessage = [
      message,
      error,
      _getOriginalException(error),
      stackTrace,
    ].where((e) => e != null).join('\n');

    for (final logger in _loggers) {
      logger.logError(name, fullMessage);
    }
  }

  @override
  void warning(String message, {String name = ''}) {
    for (final logger in _loggers) {
      logger.logWarning(name, message);
    }
  }

  @override
  void debug(String message, {String name = ''}) {
    assert(() {
      for (final logger in _loggers) {
        logger.logDebug(name, message);
      }
      return true;
    }());
  }

  void clearLogs() {
    for (final logger in _loggers) {
      logger.clearLogs();
    }
  }

  Object? _getOriginalException(Object? error) {
    if (error == null) return null;
    if (error is MeetingPlaceCoreSDKException) return error.innerException;
    return null;
  }
}
