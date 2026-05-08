// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_form_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$identityFormScreenControllerHash() =>
    r'3bffba813b73da813ca237c699f82330fb6c12d7';

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

abstract class _$IdentityFormScreenController
    extends BuildlessAutoDisposeNotifier<IdentityFormScreenState> {
  late final String? identityId;

  IdentityFormScreenState build(String? identityId);
}

/// See also [IdentityFormScreenController].
@ProviderFor(IdentityFormScreenController)
const identityFormScreenControllerProvider =
    IdentityFormScreenControllerFamily();

/// See also [IdentityFormScreenController].
class IdentityFormScreenControllerFamily
    extends Family<IdentityFormScreenState> {
  /// See also [IdentityFormScreenController].
  const IdentityFormScreenControllerFamily();

  /// See also [IdentityFormScreenController].
  IdentityFormScreenControllerProvider call(String? identityId) {
    return IdentityFormScreenControllerProvider(identityId);
  }

  @override
  IdentityFormScreenControllerProvider getProviderOverride(
    covariant IdentityFormScreenControllerProvider provider,
  ) {
    return call(provider.identityId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'identityFormScreenControllerProvider';
}

/// See also [IdentityFormScreenController].
class IdentityFormScreenControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          IdentityFormScreenController,
          IdentityFormScreenState
        > {
  /// See also [IdentityFormScreenController].
  IdentityFormScreenControllerProvider(String? identityId)
    : this._internal(
        () => IdentityFormScreenController()..identityId = identityId,
        from: identityFormScreenControllerProvider,
        name: r'identityFormScreenControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$identityFormScreenControllerHash,
        dependencies: IdentityFormScreenControllerFamily._dependencies,
        allTransitiveDependencies:
            IdentityFormScreenControllerFamily._allTransitiveDependencies,
        identityId: identityId,
      );

  IdentityFormScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.identityId,
  }) : super.internal();

  final String? identityId;

  @override
  IdentityFormScreenState runNotifierBuild(
    covariant IdentityFormScreenController notifier,
  ) {
    return notifier.build(identityId);
  }

  @override
  Override overrideWith(IdentityFormScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: IdentityFormScreenControllerProvider._internal(
        () => create()..identityId = identityId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        identityId: identityId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    IdentityFormScreenController,
    IdentityFormScreenState
  >
  createElement() {
    return _IdentityFormScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IdentityFormScreenControllerProvider &&
        other.identityId == identityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, identityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IdentityFormScreenControllerRef
    on AutoDisposeNotifierProviderRef<IdentityFormScreenState> {
  /// The parameter `identityId` of this provider.
  String? get identityId;
}

class _IdentityFormScreenControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          IdentityFormScreenController,
          IdentityFormScreenState
        >
    with IdentityFormScreenControllerRef {
  _IdentityFormScreenControllerProviderElement(super.provider);

  @override
  String? get identityId =>
      (origin as IdentityFormScreenControllerProvider).identityId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
