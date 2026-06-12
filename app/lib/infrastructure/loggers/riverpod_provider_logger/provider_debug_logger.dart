import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_logger/app_logger.dart';

base class ProviderDebugLogger extends ProviderObserver {
  static const _logKey = 'PROV';
  final AppLogger _logger = AppLogger.instance;

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    _logger.info(
      'Add: "${context.provider.name ?? context.provider.runtimeType}"',
      name: _logKey,
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    _logger.info(
      'Dispose: "${context.provider.name ?? context.provider.runtimeType}"',
      name: _logKey,
    );
  }
}
