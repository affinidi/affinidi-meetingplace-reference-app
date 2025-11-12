import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../loggers/app_logger/app_logger.dart';

part 'app_logger_provider.g.dart';

/// A Riverpod provider that exposes the global [AppLogger] instance.
///
/// Useful for consistent logging across the app.
///
/// [ref] - The Riverpod reference used for dependency injection.
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) {
  return AppLogger.instance;
}
