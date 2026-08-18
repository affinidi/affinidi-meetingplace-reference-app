// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the app's [GoRouter] configuration.
///
/// Sets up navigation guards, refresh logic, and the main route table.
///
/// [ref] - Used to read dependencies like authentication and settings state.

@ProviderFor(routerConfig)
const routerConfigProvider = RouterConfigProvider._();

/// Provides the app's [GoRouter] configuration.
///
/// Sets up navigation guards, refresh logic, and the main route table.
///
/// [ref] - Used to read dependencies like authentication and settings state.

final class RouterConfigProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Provides the app's [GoRouter] configuration.
  ///
  /// Sets up navigation guards, refresh logic, and the main route table.
  ///
  /// [ref] - Used to read dependencies like authentication and settings state.
  const RouterConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerConfigHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return routerConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$routerConfigHash() => r'd54e4bf3af7c36cff42d819b08477aff49cf2bb6';
