// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a LocalAuthentication instance from the `local_auth` plugin.
///
/// Factory parameters:
/// - [ref] - Riverpod Ref used to construct the provider.

@ProviderFor(localAuth)
final localAuthProvider = LocalAuthProvider._();

/// Provides a LocalAuthentication instance from the `local_auth` plugin.
///
/// Factory parameters:
/// - [ref] - Riverpod Ref used to construct the provider.

final class LocalAuthProvider
    extends
        $FunctionalProvider<
          LocalAuthentication,
          LocalAuthentication,
          LocalAuthentication
        >
    with $Provider<LocalAuthentication> {
  /// Provides a LocalAuthentication instance from the `local_auth` plugin.
  ///
  /// Factory parameters:
  /// - [ref] - Riverpod Ref used to construct the provider.
  LocalAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localAuthHash();

  @$internal
  @override
  $ProviderElement<LocalAuthentication> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalAuthentication create(Ref ref) {
    return localAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalAuthentication value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalAuthentication>(value),
    );
  }
}

String _$localAuthHash() => r'352b04d375edb7326ce1ca3fb7835db923b866eb';
