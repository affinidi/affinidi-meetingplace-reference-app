import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:path_provider/path_provider.dart';

import 'app_log_entry.dart';
import 'log_constants.dart';
import 'logger_target.dart';

/// A log target that persists every entry to a file on disk and maintains
/// an in-memory list with a live stream. On startup, the existing file is
/// parsed into [logs] and trimmed to [_maxFileLines] to prevent unbounded
/// growth.
class DebugLogCollectorTarget implements LoggerTarget {
  DebugLogCollectorTarget() {
    _initialize();
  }

  File? _logFile;
  final List<AppLogEntry> _pendingBuffer = [];
  final List<AppLogEntry> _logs = [];
  final StreamController<AppLogEntry> _logController =
      StreamController<AppLogEntry>.broadcast();

  static const int _maxFileLines = 5000;
  static const int _maxMemoryEntries = 2000;
  static final RegExp _lineRegex = RegExp(r'^\[(.+?)\] \[(.+?)\] (.+)$');

  Future<void> _initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File('${dir.path}/app_debug.log');

    // Flush any buffered entries synchronously now that we have a path.
    if (_pendingBuffer.isNotEmpty) {
      final buffer = StringBuffer();
      for (final entry in _pendingBuffer) {
        buffer.write('${_formatEntry(entry)}\n');
      }
      _logFile!.writeAsStringSync(buffer.toString(), mode: FileMode.append);
      _pendingBuffer.clear();
    }

    // Parse existing log file into the in-memory list.
    if (await _logFile!.exists()) {
      final lines = await _logFile!.readAsLines();
      final nonEmptyLines = lines.where((l) => l.trim().isNotEmpty).toList();

      // Trim file on disk if it exceeds the max line cap.
      if (nonEmptyLines.length > _maxFileLines) {
        final trimmed = nonEmptyLines.sublist(
          nonEmptyLines.length - _maxFileLines,
        );
        _logFile!.writeAsStringSync('${trimmed.join('\n')}\n');
        _loadEntries(trimmed);
      } else {
        _loadEntries(nonEmptyLines);
      }
    }
  }

  void _loadEntries(List<String> lines) {
    final entries = lines.map(_parseLine).whereType<AppLogEntry>().toList();
    final capped = entries.length > _maxMemoryEntries
        ? entries.sublist(entries.length - _maxMemoryEntries)
        : entries;
    _logs
      ..clear()
      ..addAll(capped);
  }

  /// Stream of new log entries as they are added during this session.
  Stream<AppLogEntry> get logStream => _logController.stream;

  String? get logFilePath => _logFile?.path;

  void dispose() => _logController.close();

  AppLogEntry? _parseLine(String line) {
    final match = _lineRegex.firstMatch(line);
    if (match == null) return null;
    final timestamp = DateTime.tryParse(match.group(1)!);
    if (timestamp == null) return null;
    final level = match.group(2)!;
    final rest = match.group(3)!;
    // rest = "loggerName message" — loggerName is either "[APP] name" or a
    // single word without spaces.
    String loggerName;
    String message;
    if (rest.startsWith('[')) {
      final closingBracket = rest.indexOf(']');
      if (closingBracket != -1 && rest.length > closingBracket + 2) {
        final afterBracket = rest.substring(closingBracket + 2);
        final nextSpace = afterBracket.indexOf(' ');
        if (nextSpace != -1) {
          loggerName =
              '${rest.substring(0, closingBracket + 1)} '
              '${afterBracket.substring(0, nextSpace)}';
          message = afterBracket.substring(nextSpace + 1);
        } else {
          loggerName = rest;
          message = '';
        }
      } else {
        loggerName = rest;
        message = '';
      }
    } else {
      final spaceIndex = rest.indexOf(' ');
      if (spaceIndex != -1) {
        loggerName = rest.substring(0, spaceIndex);
        message = rest.substring(spaceIndex + 1);
      } else {
        loggerName = rest;
        message = '';
      }
    }
    return AppLogEntry(
      timestamp: timestamp,
      level: level,
      loggerName: loggerName,
      message: message,
    );
  }

  String _formatEntry(AppLogEntry entry) {
    return '[${entry.timestamp.toIso8601String()}] '
        '[${entry.level}] ${entry.loggerName} ${entry.message}';
  }

  void _addLog(String loggerName, String message, String level) {
    final isAppLog = loggerName.contains(LogConstants.logName);
    final formattedName = isAppLog
        ? '[${LogConstants.logName}] $loggerName'
        : loggerName;
    final entry = AppLogEntry(
      timestamp: clock.now(),
      message: message,
      level: level,
      loggerName: formattedName,
    );

    _logs.add(entry);
    if (_logs.length > _maxMemoryEntries) {
      _logs.removeAt(0);
    }
    _logController.add(entry);

    final file = _logFile;
    if (file == null) {
      _pendingBuffer.add(entry);
    } else {
      file.writeAsStringSync('${_formatEntry(entry)}\n', mode: FileMode.append);
    }
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
    _logFile?.writeAsStringSync('');
  }
}