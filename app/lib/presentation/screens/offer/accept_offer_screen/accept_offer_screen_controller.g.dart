// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accept_offer_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$acceptOfferScreenControllerHash() =>
    r'190cfd5d51825ca24a494778f673b29bae5ea7a4';

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

abstract class _$AcceptOfferScreenController
    extends BuildlessAutoDisposeNotifier<AcceptOfferScreenState> {
  late final String mnemonic;

  AcceptOfferScreenState build(String mnemonic);
}

/// See also [AcceptOfferScreenController].
@ProviderFor(AcceptOfferScreenController)
const acceptOfferScreenControllerProvider = AcceptOfferScreenControllerFamily();

/// See also [AcceptOfferScreenController].
class AcceptOfferScreenControllerFamily extends Family<AcceptOfferScreenState> {
  /// See also [AcceptOfferScreenController].
  const AcceptOfferScreenControllerFamily();

  /// See also [AcceptOfferScreenController].
  AcceptOfferScreenControllerProvider call(String mnemonic) {
    return AcceptOfferScreenControllerProvider(mnemonic);
  }

  @override
  AcceptOfferScreenControllerProvider getProviderOverride(
    covariant AcceptOfferScreenControllerProvider provider,
  ) {
    return call(provider.mnemonic);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'acceptOfferScreenControllerProvider';
}

/// See also [AcceptOfferScreenController].
class AcceptOfferScreenControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AcceptOfferScreenController,
          AcceptOfferScreenState
        > {
  /// See also [AcceptOfferScreenController].
  AcceptOfferScreenControllerProvider(String mnemonic)
    : this._internal(
        () => AcceptOfferScreenController()..mnemonic = mnemonic,
        from: acceptOfferScreenControllerProvider,
        name: r'acceptOfferScreenControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$acceptOfferScreenControllerHash,
        dependencies: AcceptOfferScreenControllerFamily._dependencies,
        allTransitiveDependencies:
            AcceptOfferScreenControllerFamily._allTransitiveDependencies,
        mnemonic: mnemonic,
      );

  AcceptOfferScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mnemonic,
  }) : super.internal();

  final String mnemonic;

  @override
  AcceptOfferScreenState runNotifierBuild(
    covariant AcceptOfferScreenController notifier,
  ) {
    return notifier.build(mnemonic);
  }

  @override
  Override overrideWith(AcceptOfferScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AcceptOfferScreenControllerProvider._internal(
        () => create()..mnemonic = mnemonic,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mnemonic: mnemonic,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    AcceptOfferScreenController,
    AcceptOfferScreenState
  >
  createElement() {
    return _AcceptOfferScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AcceptOfferScreenControllerProvider &&
        other.mnemonic == mnemonic;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mnemonic.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AcceptOfferScreenControllerRef
    on AutoDisposeNotifierProviderRef<AcceptOfferScreenState> {
  /// The parameter `mnemonic` of this provider.
  String get mnemonic;
}

class _AcceptOfferScreenControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AcceptOfferScreenController,
          AcceptOfferScreenState
        >
    with AcceptOfferScreenControllerRef {
  _AcceptOfferScreenControllerProviderElement(super.provider);

  @override
  String get mnemonic =>
      (origin as AcceptOfferScreenControllerProvider).mnemonic;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
