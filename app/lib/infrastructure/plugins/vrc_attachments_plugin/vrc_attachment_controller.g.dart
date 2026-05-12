// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrc_attachment_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vrcAttachmentControllerHash() =>
    r'5e1259f7d36c95898fe47db10ae320944b7c6a54';

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

abstract class _$VrcAttachmentController
    extends BuildlessAutoDisposeNotifier<VrcAttachmentState> {
  late final String vcBlob;

  VrcAttachmentState build(String vcBlob);
}

/// See also [VrcAttachmentController].
@ProviderFor(VrcAttachmentController)
const vrcAttachmentControllerProvider = VrcAttachmentControllerFamily();

/// See also [VrcAttachmentController].
class VrcAttachmentControllerFamily extends Family<VrcAttachmentState> {
  /// See also [VrcAttachmentController].
  const VrcAttachmentControllerFamily();

  /// See also [VrcAttachmentController].
  VrcAttachmentControllerProvider call(String vcBlob) {
    return VrcAttachmentControllerProvider(vcBlob);
  }

  @override
  VrcAttachmentControllerProvider getProviderOverride(
    covariant VrcAttachmentControllerProvider provider,
  ) {
    return call(provider.vcBlob);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vrcAttachmentControllerProvider';
}

/// See also [VrcAttachmentController].
class VrcAttachmentControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          VrcAttachmentController,
          VrcAttachmentState
        > {
  /// See also [VrcAttachmentController].
  VrcAttachmentControllerProvider(String vcBlob)
    : this._internal(
        () => VrcAttachmentController()..vcBlob = vcBlob,
        from: vrcAttachmentControllerProvider,
        name: r'vrcAttachmentControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vrcAttachmentControllerHash,
        dependencies: VrcAttachmentControllerFamily._dependencies,
        allTransitiveDependencies:
            VrcAttachmentControllerFamily._allTransitiveDependencies,
        vcBlob: vcBlob,
      );

  VrcAttachmentControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vcBlob,
  }) : super.internal();

  final String vcBlob;

  @override
  VrcAttachmentState runNotifierBuild(
    covariant VrcAttachmentController notifier,
  ) {
    return notifier.build(vcBlob);
  }

  @override
  Override overrideWith(VrcAttachmentController Function() create) {
    return ProviderOverride(
      origin: this,
      override: VrcAttachmentControllerProvider._internal(
        () => create()..vcBlob = vcBlob,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vcBlob: vcBlob,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    VrcAttachmentController,
    VrcAttachmentState
  >
  createElement() {
    return _VrcAttachmentControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VrcAttachmentControllerProvider && other.vcBlob == vcBlob;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vcBlob.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VrcAttachmentControllerRef
    on AutoDisposeNotifierProviderRef<VrcAttachmentState> {
  /// The parameter `vcBlob` of this provider.
  String get vcBlob;
}

class _VrcAttachmentControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          VrcAttachmentController,
          VrcAttachmentState
        >
    with VrcAttachmentControllerRef {
  _VrcAttachmentControllerProviderElement(super.provider);

  @override
  String get vcBlob => (origin as VrcAttachmentControllerProvider).vcBlob;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
