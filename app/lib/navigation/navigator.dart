import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router_config_provider.dart';

/// A wrapper around [GoRouter] to provide safe navigation methods.
///
/// Catches navigation errors and logs them instead of letting them crash
/// the app.
class Navigator {
  Navigator(this._router);

  final GoRouter _router;

  static const _logKey = 'NAVSVC';

  /// Navigates to the given [path], replacing the current route.
  ///
  /// [path] - The target route path to navigate to.
  void go(String path) {
    try {
      _router.go(path);
    } catch (e, stackTrace) {
      _handleNavigationError('go', path, e, stackTrace);
    }
  }

  /// Pushes a new route onto the navigation stack.
  ///
  /// [path] - The target route path to push.
  Future<T?> push<T extends Object?>(String path) async {
    try {
      return await _router.push<T>(path);
    } catch (e, stackTrace) {
      _handleNavigationError('push', path, e, stackTrace);
      return null;
    }
  }

  /// Pops the current route off the navigation stack.
  ///
  /// [result] - (Optional) A result to return to the previous route.
  void pop<T extends Object?>([T? result]) {
    try {
      _router.pop(result);
    } catch (e, stackTrace) {
      _handleNavigationError('pop', '', e, stackTrace);
    }
  }

  /// Handles navigation errors by logging them.
  ///
  /// [method] - The navigation method being used (e.g. `go`, `push`, `pop`).
  /// [path] - The path involved in the navigation attempt.
  /// [error] - The caught error object.
  /// [stackTrace] - The stack trace of the error.
  void _handleNavigationError(
    String method,
    String path,
    Object error,
    StackTrace stackTrace,
  ) {
    log('Error using $method to "$path": $error', name: _logKey);
    log('$stackTrace', name: _logKey);
  }
}

/// Provides a [Navigator] instance bound to the app's [GoRouter].
final navigatorProvider = Provider<Navigator>((ref) {
  final router = ref.watch(routerConfigProvider);
  return Navigator(router);
});
