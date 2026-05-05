class AppLogEntry {
  AppLogEntry({
    required this.timestamp,
    required this.message,
    required this.level,
    required this.loggerName,
  });

  /// Reconstructs an entry from a single line produced by [serialize].
  /// Returns `null` if the line is malformed.
  static AppLogEntry? tryParse(String line) {
    if (line.isEmpty) return null;
    final timestampEnd = line.indexOf(_separator);
    if (timestampEnd < 0) return null;
    final levelEnd = line.indexOf(_separator, timestampEnd + 1);
    if (levelEnd < 0) return null;
    final loggerNameEnd = line.indexOf(_separator, levelEnd + 1);
    if (loggerNameEnd < 0) return null;
    final timestamp = DateTime.tryParse(line.substring(0, timestampEnd));
    if (timestamp == null) return null;
    return AppLogEntry(
      timestamp: timestamp,
      level: line.substring(timestampEnd + 1, levelEnd),
      loggerName: line.substring(levelEnd + 1, loggerNameEnd),
      message: line.substring(loggerNameEnd + 1).replaceAll(r'\n', '\n'),
    );
  }

  /// Serializes the entry as a single line. Newlines in [message] are
  /// escaped so the on-disk format stays line-oriented.
  String serialize() {
    final escapedMessage = message.replaceAll('\n', r'\n');
    return '${timestamp.toIso8601String()}'
        '$_separator$level'
        '$_separator$loggerName'
        '$_separator$escapedMessage';
  }

  static const String _separator = '\t';

  final DateTime timestamp;
  final String message;
  final String level;
  final String loggerName;
}
