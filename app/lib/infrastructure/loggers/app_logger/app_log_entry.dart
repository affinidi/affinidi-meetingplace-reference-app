class AppLogEntry {
  AppLogEntry({
    required this.timestamp,
    required this.message,
    required this.level,
    required this.loggerName,
  });
  final DateTime timestamp;
  final String message;
  final String level;
  final String loggerName;
}
