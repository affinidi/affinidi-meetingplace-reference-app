// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service responsible for managing authentication state and biometric flows.
///
/// This service provides functionality to:
/// - Trigger biometric authentication
///
/// It relies on the platform-specific local_auth provider for biometric
/// operations and the environment provider to determine whether biometric
/// checks are enabled.

@ProviderFor(AuthenticationService)
const authenticationServiceProvider = AuthenticationServiceProvider._();

/// Service responsible for managing authentication state and biometric flows.
///
/// This service provides functionality to:
/// - Trigger biometric authentication
///
/// It relies on the platform-specific local_auth provider for biometric
/// operations and the environment provider to determine whether biometric
/// checks are enabled.
final class AuthenticationServiceProvider
    extends $NotifierProvider<AuthenticationService, AuthenticationState> {
  /// Service responsible for managing authentication state and biometric flows.
  ///
  /// This service provides functionality to:
  /// - Trigger biometric authentication
  ///
  /// It relies on the platform-specific local_auth provider for biometric
  /// operations and the environment provider to determine whether biometric
  /// checks are enabled.
  const AuthenticationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authenticationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authenticationServiceHash();

  @$internal
  @override
  AuthenticationService create() => AuthenticationService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthenticationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthenticationState>(value),
    );
  }
}

String _$authenticationServiceHash() =>
    r'24fdca7b6c4ca87e55903090ddad6b62645c578a';

/// Service responsible for managing authentication state and biometric flows.
///
/// This service provides functionality to:
/// - Trigger biometric authentication
///
/// It relies on the platform-specific local_auth provider for biometric
/// operations and the environment provider to determine whether biometric
/// checks are enabled.

abstract class _$AuthenticationService extends $Notifier<AuthenticationState> {
  AuthenticationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AuthenticationState, AuthenticationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthenticationState, AuthenticationState>,
              AuthenticationState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
