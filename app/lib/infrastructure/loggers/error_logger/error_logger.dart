import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';

import '../app_logger/app_logger.dart';

class ErrorLoggingHandler {
  ErrorLoggingHandler._();
  static const _logKey = 'EXCPTN';
  static final ErrorLoggingHandler _instance = ErrorLoggingHandler._();
  static final ErrorLoggingHandler instance = _instance;

  late final AppLogger _logger = AppLogger.instance;
  void ensureInitialized() {
    FlutterError.demangleStackTrace = (StackTrace stack) {
      if (stack is Trace) {
        return stack.vmTrace;
      }
      if (stack is Chain) {
        return stack.toTrace().vmTrace;
      }
      return stack;
    };

    FlutterError.onError = (errorDetails) {
      _logger.error(
        'Unhandled exception',
        error: errorDetails.exception,
        stackTrace: errorDetails.stack,
        name: _logKey,
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      _logger.error(
        'Unhandled exception',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return true;
    };
  }
}
