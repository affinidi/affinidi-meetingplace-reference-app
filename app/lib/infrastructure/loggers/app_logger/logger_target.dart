import 'app_log_entry.dart';

abstract class LoggerTarget {
  List<AppLogEntry> get logs;
  void logInfo(String loggerName, String message);
  void logError(String loggerName, String message);
  void logWarning(String loggerName, String message);
  void logDebug(String loggerName, String message);
  void clearLogs();
}
