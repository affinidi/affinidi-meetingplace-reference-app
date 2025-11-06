import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/biometrics/local_auth_provider.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../presentation/screens/connections/connections_screen_controller.dart';
import '../../../presentation/screens/contacts/contacts_screen_controller.dart';
import '../../../presentation/screens/identities/identities_screen_controller.dart';
import '../../../presentation/screens/settings/settings_screen_controller.dart';
import '../connections_service/connections_service.dart';
import '../contacts_service/contacts_service.dart';
import '../identities_service/identities_service.dart';
import 'authentication_state.dart';

part 'authentication_service.g.dart';

/// Service responsible for managing authentication state and biometric flows.
///
/// This service provides functionality to:
/// - Trigger biometric authentication
///
/// It relies on the platform-specific local_auth provider for biometric
/// operations and the environment provider to determine whether biometric
/// checks are enabled.
@Riverpod(keepAlive: true)
class AuthenticationService extends _$AuthenticationService {
  late final _logger = ref.read(appLoggerProvider);
  late final _auth = ref.read(localAuthProvider);
  static const _logKey = 'AUTHSVC';

  @override
  AuthenticationState build() {
    return const AuthenticationState(isLoading: false, isAuthenticated: false);
  }

  /// It preloads all identities to ensure fast access after authentication.
  /// Initializes controllers of all screens used in tabbar for them to be ready
  /// as soon as authentication is successful.
  Future<void> _warmup() async {
    await ref.read(identitiesServiceProvider.notifier).ensureInitialized();
    ref.read(identitiesScreenControllerProvider);

    await ref.read(contactsServiceProvider.notifier).ensureInitialized();
    ref.read(contactsScreenControllerProvider.notifier);

    await ref.read(connectionsServiceProvider.notifier).ensureInitialized();
    ref.read(connectionsScreenControllerProvider);

    await ref
        .read(settingsScreenControllerProvider.notifier)
        .ensureInitialized();
  }

  /// Triggers the authentication flow.
  ///
  /// If biometrics are disabled via configuration, this method will set
  /// `isAuthenticated` to `true` immediately. Otherwise it updates the state
  /// to indicate loading, calls the local biometric flow, and updates the
  /// authentication state based on the result.
  ///
  /// [reason] - The localized reason shown in the biometric prompt.
  ///
  /// Returns:
  /// - `Future<void>` completes when the authentication attempt finishes.
  Future<void> authenticate(String reason) async {
    if (!ref.read(environmentProvider).isBiometricsEnabled) {
      await _warmup();
      state = state.copyWith(isAuthenticated: true, isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);
    final success = await _authenticate(localizedReason: reason);
    if (success) await _warmup();
    state = state.copyWith(isAuthenticated: success, isLoading: false);
  }

  /// Perform local biometric authentication using the platform provider.
  ///
  /// Attempts to use device biometrics when available and supported. Any
  /// PlatformException encountered is caught and logged; on error the method
  /// returns `false`.
  ///
  /// [localizedReason] - The message displayed in the biometric prompt.
  ///
  /// Returns:
  /// - `Future<bool>` that resolves to `true` when authentication succeeds,
  ///   otherwise `false`.
  Future<bool> _authenticate({required String localizedReason}) async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (canCheckBiometrics || isDeviceSupported) {
        return await _auth.authenticate(
          localizedReason: localizedReason,
          options: const AuthenticationOptions(stickyAuth: true),
        );
      }
    } on PlatformException catch (e, st) {
      _logger.error(
        'Biometrics Error',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
    }
    return false;
  }
}
