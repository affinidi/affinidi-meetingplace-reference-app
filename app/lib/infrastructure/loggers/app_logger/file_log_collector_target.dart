import 'dart:io';

import 'package:clock/clock.dart';
import 'package:path_provider/path_provider.dart';

import 'app_log_entry.dart';
import 'log_constants.dart';
import 'logger_target.dart';

/// A log target that persists every entry to [_logFile] on disk so logs
/// survive app restarts and crashes. On [initialize], the existing file is
/// parsed back into [historicalLogs] and trimmed to [_maxFileLines] to prevent
/// unbounded growth.
class FileLogCollectorTarget implements LoggerTarget {
  FileLogCollectorTarget();

  File? _logFile;
  final List<AppLogEntry> _pendingBuffer = [];
  List<AppLogEntry> _historicalLogs = [];

  static const int _maxFileLines = 5000;
  static const int _maxHistoricalEntries = 2000;
  static final RegExp _lineRegex = RegExp(r'^\[(.+?)\] \[(.+?)\] (.+)$');

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File('${dir.path}/app_debug.log');

    // Parse existing log file into historical entries.
    if (await _logFile!.exists()) {
      final lines = await _logFile!.readAsLines();
      final nonEmptyLines = lines.where((l) => l.trim().isNotEmpty).toList();

      // Trim file on disk if it exceeds the max line cap.
      if (nonEmptyLines.length > _maxFileLines) {
        final trimmed = nonEmptyLines.sublist(
          nonEmptyLines.length - _maxFileLines,
        );
        await _logFile!.writeAsString('${trimmed.join('\n')}\n');
        final entries = trimmed
            .map(_parseLine)
            .whereType<AppLogEntry>()
            .toList();
        _historicalLogs = entries.length > _maxHistoricalEntries
            ? entries.sublist(entries.length - _maxHistoricalEntries)
            : entries;
      } else {
        final entries = nonEmptyLines
            .map(_parseLine)
            .whereType<AppLogEntry>()
            .toList();
        // Keep only the last N entries to avoid unbounded memory use.
        _historicalLogs = entries.length > _maxHistoricalEntries
            ? entries.sublist(entries.length - _maxHistoricalEntries)
            : entries;
      }
    }

    if (_pendingBuffer.isNotEmpty) {
      final sink = _logFile!.openWrite(mode: FileMode.append);
      for (final entry in _pendingBuffer) {
        sink.writeln(_formatEntry(entry));
      }
      await sink.flush();
      await sink.close();
      _pendingBuffer.clear();
    }
  }

  /// Log entries parsed from the file written during previous app runs.
  List<AppLogEntry> get historicalLogs => List.unmodifiable(_historicalLogs);

  String? get logFilePath => _logFile?.path;

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
      // e.g. "[APP] UXDBG some message with spaces"
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

    final file = _logFile;
    if (file == null) {
      _pendingBuffer.add(entry);
    } else {
      file.writeAsString('${_formatEntry(entry)}\n', mode: FileMode.append);
    }
  }

  @override
  List<AppLogEntry> get logs => const [];

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
  void clearLogs() => _logFile?.writeAsStringSync('');
}
