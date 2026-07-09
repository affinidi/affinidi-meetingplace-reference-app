import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_log_entry.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';

/// Fake [AppLogger] for testing.
class FakeAppLogger implements AppLogger {
  @override
  void info(String message, {String name = ''}) {}

  @override
  void warning(String message, {String name = '', dynamic error}) {}

  @override
  void error(
    String message, {
    String name = '',
    dynamic error,
    StackTrace? stackTrace,
  }) {}

  @override
  void debug(String message, {String name = ''}) {}

  @override
  void clearLogs() {}

  @override
  String get logFilePath => '';

  @override
  Stream<AppLogEntry> get logStream => const Stream.empty();

  @override
  List<AppLogEntry> get logs => [];
}
