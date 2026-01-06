import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_logger/app_logger.dart';

class ProviderDebugLogger extends ProviderObserver {
  static const _logKey = 'PROV';
  final AppLogger _logger = AppLogger.instance;

  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    _logger.info(
      'Add: "${provider.name ?? provider.runtimeType}"',
      name: _logKey,
    );
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    _logger.info(
      'Dispose: "${provider.name ?? provider.runtimeType}"',
      name: _logKey,
    );
  }
}
