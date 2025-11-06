import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/connectivity_provider.dart';
import 'network_connectivity_service_state.dart';

part 'network_connectivity_service.g.dart';

/// Service for monitoring network connectivity status and notifying changes.
@Riverpod(keepAlive: true)
class NetworkConnectivityService extends _$NetworkConnectivityService {
  NetworkConnectivityService() : super();
  static const _logKey = 'NETCONNSVC';

  late final AppLogger _logger = ref.read(appLoggerProvider);
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  late final _connectivity = ref.read(connectivityProvider);

  @override
  NetworkConnectivityServiceState build() {
    ref.onDispose(() {
      _connectivitySubscription?.cancel();
    });

    _initializeConnectivityMonitoring();

    return const NetworkConnectivityServiceState(isConnected: true);
  }

  void _initializeConnectivityMonitoring() {
    _logger.info(
      'Initializing network connectivity monitoring',
      name: _logKey,
    );

    _checkInitialConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      _logger.info(
        'Initial connectivity check: $connectivityResults',
        name: _logKey,
      );
      _handleConnectivityChange(connectivityResults);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to check initial connectivity',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isConnected = _isConnected(results);

    _logger.info(
      'Network connectivity changed: $results (connected: $isConnected)',
      name: _logKey,
    );

    if (isConnected) {
      _logger.info('Network connectivity established', name: _logKey);
    } else {
      _logger.warning('No network connectivity', name: _logKey);
    }

    state = state.copyWith(isConnected: isConnected);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }
}
