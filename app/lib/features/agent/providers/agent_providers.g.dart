// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$httpClientHash() => r'3357f2d87f15f4a92efbbea9b115d288f48f503a';

/// Shared HTTP client — single instance for the lifetime of the app.
///
/// Copied from [httpClient].
@ProviderFor(httpClient)
final httpClientProvider = Provider<http.Client>.internal(
  httpClient,
  name: r'httpClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$httpClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HttpClientRef = ProviderRef<http.Client>;
String _$agentLearnServiceHash() => r'eb7570e732397aff5570f62e92e2e53784cecdad';

/// Provides [AgentLearnService] backed by the app-wide [SharedPreferences]
/// instance (already initialised before [ProviderScope] starts).
///
/// Copied from [agentLearnService].
@ProviderFor(agentLearnService)
final agentLearnServiceProvider = Provider<AgentLearnService>.internal(
  agentLearnService,
  name: r'agentLearnServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$agentLearnServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AgentLearnServiceRef = ProviderRef<AgentLearnService>;
String _$agentRepositoryHash() => r'a72c79de28fef53d9ad1c845d1379d2a60a37ec4';

/// Provides [AgentRepository] for readiness polling and deployment calls.
///
/// Copied from [agentRepository].
@ProviderFor(agentRepository)
final agentRepositoryProvider = Provider<AgentRepository>.internal(
  agentRepository,
  name: r'agentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$agentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AgentRepositoryRef = ProviderRef<AgentRepository>;
String _$agentReadinessHash() => r'b434fda3ea403cbd2eb0e02e9cd207fabdfb284a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Auto-disposing readiness fetch — invalidate to force a refresh.
///
/// Copied from [agentReadiness].
@ProviderFor(agentReadiness)
const agentReadinessProvider = AgentReadinessFamily();

/// Auto-disposing readiness fetch — invalidate to force a refresh.
///
/// Copied from [agentReadiness].
class AgentReadinessFamily extends Family<AsyncValue<AgentReadinessState>> {
  /// Auto-disposing readiness fetch — invalidate to force a refresh.
  ///
  /// Copied from [agentReadiness].
  const AgentReadinessFamily();

  /// Auto-disposing readiness fetch — invalidate to force a refresh.
  ///
  /// Copied from [agentReadiness].
  AgentReadinessProvider call(String ownerDid) {
    return AgentReadinessProvider(ownerDid);
  }

  @override
  AgentReadinessProvider getProviderOverride(
    covariant AgentReadinessProvider provider,
  ) {
    return call(provider.ownerDid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'agentReadinessProvider';
}

/// Auto-disposing readiness fetch — invalidate to force a refresh.
///
/// Copied from [agentReadiness].
class AgentReadinessProvider
    extends AutoDisposeFutureProvider<AgentReadinessState> {
  /// Auto-disposing readiness fetch — invalidate to force a refresh.
  ///
  /// Copied from [agentReadiness].
  AgentReadinessProvider(String ownerDid)
    : this._internal(
        (ref) => agentReadiness(ref as AgentReadinessRef, ownerDid),
        from: agentReadinessProvider,
        name: r'agentReadinessProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$agentReadinessHash,
        dependencies: AgentReadinessFamily._dependencies,
        allTransitiveDependencies:
            AgentReadinessFamily._allTransitiveDependencies,
        ownerDid: ownerDid,
      );

  AgentReadinessProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ownerDid,
  }) : super.internal();

  final String ownerDid;

  @override
  Override overrideWith(
    FutureOr<AgentReadinessState> Function(AgentReadinessRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AgentReadinessProvider._internal(
        (ref) => create(ref as AgentReadinessRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ownerDid: ownerDid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AgentReadinessState> createElement() {
    return _AgentReadinessProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AgentReadinessProvider && other.ownerDid == ownerDid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ownerDid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AgentReadinessRef on AutoDisposeFutureProviderRef<AgentReadinessState> {
  /// The parameter `ownerDid` of this provider.
  String get ownerDid;
}

class _AgentReadinessProviderElement
    extends AutoDisposeFutureProviderElement<AgentReadinessState>
    with AgentReadinessRef {
  _AgentReadinessProviderElement(super.provider);

  @override
  String get ownerDid => (origin as AgentReadinessProvider).ownerDid;
}

String _$deploymentNotifierHash() =>
    r'938d459d6c5f998b82cacb4b355a6532cea07965';

/// Manages the full deploy lifecycle. State is
/// [AsyncValue<DeploymentResult?>]:
///   • [AsyncData(null)]    — idle
///   • [AsyncLoading]       — in-flight
///   • [AsyncData(result)]  — success
///   • [AsyncError]         — failed
///
/// Copied from [DeploymentNotifier].
@ProviderFor(DeploymentNotifier)
final deploymentNotifierProvider =
    NotifierProvider<
      DeploymentNotifier,
      AsyncValue<DeploymentResult?>
    >.internal(
      DeploymentNotifier.new,
      name: r'deploymentNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$deploymentNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DeploymentNotifier = Notifier<AsyncValue<DeploymentResult?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
