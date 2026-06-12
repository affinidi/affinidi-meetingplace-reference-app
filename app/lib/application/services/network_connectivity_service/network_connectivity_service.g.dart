// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_connectivity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service for monitoring network connectivity status and notifying changes.

@ProviderFor(NetworkConnectivityService)
const networkConnectivityServiceProvider =
    NetworkConnectivityServiceProvider._();

/// Service for monitoring network connectivity status and notifying changes.
final class NetworkConnectivityServiceProvider
    extends
        $NotifierProvider<
          NetworkConnectivityService,
          NetworkConnectivityServiceState
        > {
  /// Service for monitoring network connectivity status and notifying changes.
  const NetworkConnectivityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkConnectivityServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkConnectivityServiceHash();

  @$internal
  @override
  NetworkConnectivityService create() => NetworkConnectivityService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkConnectivityServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkConnectivityServiceState>(
        value,
      ),
    );
  }
}

String _$networkConnectivityServiceHash() =>
    r'c39ef7af6a96313a30e8e2612bfdaf8651afe737';

/// Service for monitoring network connectivity status and notifying changes.

abstract class _$NetworkConnectivityService
    extends $Notifier<NetworkConnectivityServiceState> {
  NetworkConnectivityServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              NetworkConnectivityServiceState,
              NetworkConnectivityServiceState
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                NetworkConnectivityServiceState,
                NetworkConnectivityServiceState
              >,
              NetworkConnectivityServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
