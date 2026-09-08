import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../async_loaders/async_loading_status_error_localizer.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

final errorSnackBarControllerProvider = Provider<ErrorSnackBarController>(
  (ref) => ErrorSnackBarController(ref.read(appLoggerProvider)),
);

class ErrorSnackBarController with AsyncLoadingStatusErrorLocalizer {
  ErrorSnackBarController(this._logger);

  static const _logKey = 'SNACK';

  final AppLogger _logger;

  void show(Object error, StackTrace stackTrace) {
    final context = scaffoldMessengerKey.currentContext;
    if (context == null) {
      _logger.error(
        error.toString(),
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return;
    }

    final message = getErrorMessage(context, error);
    _logger.error(message, error: error, stackTrace: stackTrace, name: _logKey);

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onErrorContainer,
          ),
        ),
        backgroundColor: context.colorScheme.errorContainer,
      ),
    );
  }
}
