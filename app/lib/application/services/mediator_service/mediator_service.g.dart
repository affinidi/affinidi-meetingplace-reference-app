// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mediator_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service to manage mediators: loading, adding, renaming, and removing.
///
/// This service provides a centralized interface for mediator operations
/// including fetching default and custom mediators, adding new custom
/// mediators with auto-generated names, renaming existing mediators,
/// removing mediators, resolving mediator DIDs from URLs, and finding
/// mediators by creation time and DID.
///
/// The service maintains state through Riverpod and persists custom
/// mediators using a repository layer with secure storage backing.

@ProviderFor(MediatorService)
const mediatorServiceProvider = MediatorServiceProvider._();

/// Service to manage mediators: loading, adding, renaming, and removing.
///
/// This service provides a centralized interface for mediator operations
/// including fetching default and custom mediators, adding new custom
/// mediators with auto-generated names, renaming existing mediators,
/// removing mediators, resolving mediator DIDs from URLs, and finding
/// mediators by creation time and DID.
///
/// The service maintains state through Riverpod and persists custom
/// mediators using a repository layer with secure storage backing.
final class MediatorServiceProvider
    extends $NotifierProvider<MediatorService, MediatorServiceState> {
  /// Service to manage mediators: loading, adding, renaming, and removing.
  ///
  /// This service provides a centralized interface for mediator operations
  /// including fetching default and custom mediators, adding new custom
  /// mediators with auto-generated names, renaming existing mediators,
  /// removing mediators, resolving mediator DIDs from URLs, and finding
  /// mediators by creation time and DID.
  ///
  /// The service maintains state through Riverpod and persists custom
  /// mediators using a repository layer with secure storage backing.
  const MediatorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediatorServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediatorServiceHash();

  @$internal
  @override
  MediatorService create() => MediatorService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediatorServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediatorServiceState>(value),
    );
  }
}

String _$mediatorServiceHash() => r'59ab60881a851487557792f56781515f633037c4';

/// Service to manage mediators: loading, adding, renaming, and removing.
///
/// This service provides a centralized interface for mediator operations
/// including fetching default and custom mediators, adding new custom
/// mediators with auto-generated names, renaming existing mediators,
/// removing mediators, resolving mediator DIDs from URLs, and finding
/// mediators by creation time and DID.
///
/// The service maintains state through Riverpod and persists custom
/// mediators using a repository layer with secure storage backing.

abstract class _$MediatorService extends $Notifier<MediatorServiceState> {
  MediatorServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MediatorServiceState, MediatorServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MediatorServiceState, MediatorServiceState>,
              MediatorServiceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
