// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrc_details_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vrcDetailsScreenControllerHash() =>
    r'8d629bef40b7df61443593a41c471d18b463f200';

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

abstract class _$VrcDetailsScreenController
    extends BuildlessAutoDisposeNotifier<VrcDetailsScreenState> {
  late final String credentialId;
  late final String? vcBlob;

  VrcDetailsScreenState build(String credentialId, {String? vcBlob});
}

/// See also [VrcDetailsScreenController].
@ProviderFor(VrcDetailsScreenController)
const vrcDetailsScreenControllerProvider = VrcDetailsScreenControllerFamily();

/// See also [VrcDetailsScreenController].
class VrcDetailsScreenControllerFamily extends Family<VrcDetailsScreenState> {
  /// See also [VrcDetailsScreenController].
  const VrcDetailsScreenControllerFamily();

  /// See also [VrcDetailsScreenController].
  VrcDetailsScreenControllerProvider call(
    String credentialId, {
    String? vcBlob,
  }) {
    return VrcDetailsScreenControllerProvider(credentialId, vcBlob: vcBlob);
  }

  @override
  VrcDetailsScreenControllerProvider getProviderOverride(
    covariant VrcDetailsScreenControllerProvider provider,
  ) {
    return call(provider.credentialId, vcBlob: provider.vcBlob);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vrcDetailsScreenControllerProvider';
}

/// See also [VrcDetailsScreenController].
class VrcDetailsScreenControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          VrcDetailsScreenController,
          VrcDetailsScreenState
        > {
  /// See also [VrcDetailsScreenController].
  VrcDetailsScreenControllerProvider(String credentialId, {String? vcBlob})
    : this._internal(
        () => VrcDetailsScreenController()
          ..credentialId = credentialId
          ..vcBlob = vcBlob,
        from: vrcDetailsScreenControllerProvider,
        name: r'vrcDetailsScreenControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vrcDetailsScreenControllerHash,
        dependencies: VrcDetailsScreenControllerFamily._dependencies,
        allTransitiveDependencies:
            VrcDetailsScreenControllerFamily._allTransitiveDependencies,
        credentialId: credentialId,
        vcBlob: vcBlob,
      );

  VrcDetailsScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.credentialId,
    required this.vcBlob,
  }) : super.internal();

  final String credentialId;
  final String? vcBlob;

  @override
  VrcDetailsScreenState runNotifierBuild(
    covariant VrcDetailsScreenController notifier,
  ) {
    return notifier.build(credentialId, vcBlob: vcBlob);
  }

  @override
  Override overrideWith(VrcDetailsScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: VrcDetailsScreenControllerProvider._internal(
        () => create()
          ..credentialId = credentialId
          ..vcBlob = vcBlob,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        credentialId: credentialId,
        vcBlob: vcBlob,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    VrcDetailsScreenController,
    VrcDetailsScreenState
  >
  createElement() {
    return _VrcDetailsScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VrcDetailsScreenControllerProvider &&
        other.credentialId == credentialId &&
        other.vcBlob == vcBlob;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, credentialId.hashCode);
    hash = _SystemHash.combine(hash, vcBlob.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VrcDetailsScreenControllerRef
    on AutoDisposeNotifierProviderRef<VrcDetailsScreenState> {
  /// The parameter `credentialId` of this provider.
  String get credentialId;

  /// The parameter `vcBlob` of this provider.
  String? get vcBlob;
}

class _VrcDetailsScreenControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          VrcDetailsScreenController,
          VrcDetailsScreenState
        >
    with VrcDetailsScreenControllerRef {
  _VrcDetailsScreenControllerProviderElement(super.provider);

  @override
  String get credentialId =>
      (origin as VrcDetailsScreenControllerProvider).credentialId;
  @override
  String? get vcBlob => (origin as VrcDetailsScreenControllerProvider).vcBlob;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
