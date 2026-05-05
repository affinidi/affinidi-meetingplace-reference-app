import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';

import 'app_log_entry.dart';
import 'log_constants.dart';
import 'logger_target.dart';

/// A log target that persists every entry to a file on disk and maintains
/// an in-memory list with a live stream. On startup, the existing file is
/// parsed into [logs] and trimmed to [_maxMemoryEntries] to prevent unbounded
/// growth.
class DebugLogCollectorTarget implements LoggerTarget {
  DebugLogCollectorTarget(this._logFile, {int maxMemoryEntries = 1000})
    : _maxMemoryEntries = maxMemoryEntries {
    _writeQueue = _loadFromFile();
  }

  Future<void> _loadFromFile() async {
    if (!await _logFile.exists()) return;

    final loaded = ListQueue<AppLogEntry>();
    var exceededCap = false;

    final lines = _logFile
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final entry = AppLogEntry.tryParse(line);
      if (entry == null) continue;
      loaded.add(entry);
      if (loaded.length > _maxMemoryEntries) {
        loaded.removeFirst();
        exceededCap = true;
      }
    }

    final live = List<AppLogEntry>.from(_logs);
    _logs
      ..clear()
      ..addAll(loaded)
      ..addAll(live);
    while (_logs.length > _maxMemoryEntries) {
      _logs.removeFirst();
    }

    // Trim the on-disk file to the capped historical view. Live appends are
    if (exceededCap) {
      final buffer = StringBuffer();
      for (final entry in loaded) {
        buffer.write('${entry.serialize()}\n');
      }
      await _logFile.writeAsString(buffer.toString());
    }
  }

  final File _logFile;
  final int _maxMemoryEntries;
  final ListQueue<AppLogEntry> _logs = ListQueue<AppLogEntry>();
  final StreamController<AppLogEntry> _logController =
      StreamController<AppLogEntry>.broadcast();

  Future<void> _writeQueue = Future<void>.value();

  void _enqueueWrite(Future<void> Function() write) {
    _writeQueue = _writeQueue.then((_) => write()).catchError((_) {});
  }

  bool _isSdkLog(String loggerName) {
    final isAppLog = loggerName.contains(LogConstants.logName);
    return !isAppLog;
  }

  /// Stream of new log entries as they are added during this session.
  Stream<AppLogEntry> get logStream => _logController.stream;

  String get logFilePath => _logFile.path;

  Future<void> dispose() async {
    await _writeQueue;
    await _logController.close();
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
    if (_logs.length > _maxMemoryEntries) {
      _logs.removeFirst();
    }
    _logController.add(entry);

    _enqueueWrite(
      () => _logFile.writeAsString(
        '${entry.serialize()}\n',
        mode: FileMode.append,
      ),
    );
  }

  @override
  List<AppLogEntry> get logs => List.unmodifiable(_logs);

  @override
  void logInfo(String loggerName, String message) =>
      _addLog(loggerName, message, 'INFO');

  @override
  void logError(String loggerName, String message) =>
      _addLog(loggerName, message, 'ERROR');

  @override
  void logWarning(String loggerName, String message) =>
      _addLog(loggerName, message, 'WARNING');

  @override
  void logDebug(String loggerName, String message) =>
      _addLog(loggerName, message, 'DEBUG');

  @override
  void clearLogs() {
    _logs.clear();
    _enqueueWrite(() => _logFile.writeAsString(''));
  }
}
