// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_details_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$offerDetailsScreenControllerHash() =>
    r'dbe97ef33355accbe196d57cb5e885fb57494c20';

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

abstract class _$OfferDetailsScreenController
    extends BuildlessAutoDisposeNotifier<OfferDetailsScreenState> {
  late final String offerLink;

  OfferDetailsScreenState build(
    String offerLink,
  );
}

/// See also [OfferDetailsScreenController].
@ProviderFor(OfferDetailsScreenController)
const offerDetailsScreenControllerProvider =
    OfferDetailsScreenControllerFamily();

/// See also [OfferDetailsScreenController].
class OfferDetailsScreenControllerFamily
    extends Family<OfferDetailsScreenState> {
  /// See also [OfferDetailsScreenController].
  const OfferDetailsScreenControllerFamily();

  /// See also [OfferDetailsScreenController].
  OfferDetailsScreenControllerProvider call(
    String offerLink,
  ) {
    return OfferDetailsScreenControllerProvider(
      offerLink,
    );
  }

  @override
  OfferDetailsScreenControllerProvider getProviderOverride(
    covariant OfferDetailsScreenControllerProvider provider,
  ) {
    return call(
      provider.offerLink,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'offerDetailsScreenControllerProvider';
}

/// See also [OfferDetailsScreenController].
class OfferDetailsScreenControllerProvider
    extends AutoDisposeNotifierProviderImpl<OfferDetailsScreenController,
        OfferDetailsScreenState> {
  /// See also [OfferDetailsScreenController].
  OfferDetailsScreenControllerProvider(
    String offerLink,
  ) : this._internal(
          () => OfferDetailsScreenController()..offerLink = offerLink,
          from: offerDetailsScreenControllerProvider,
          name: r'offerDetailsScreenControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$offerDetailsScreenControllerHash,
          dependencies: OfferDetailsScreenControllerFamily._dependencies,
          allTransitiveDependencies:
              OfferDetailsScreenControllerFamily._allTransitiveDependencies,
          offerLink: offerLink,
        );

  OfferDetailsScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.offerLink,
  }) : super.internal();

  final String offerLink;

  @override
  OfferDetailsScreenState runNotifierBuild(
    covariant OfferDetailsScreenController notifier,
  ) {
    return notifier.build(
      offerLink,
    );
  }

  @override
  Override overrideWith(OfferDetailsScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: OfferDetailsScreenControllerProvider._internal(
        () => create()..offerLink = offerLink,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        offerLink: offerLink,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<OfferDetailsScreenController,
      OfferDetailsScreenState> createElement() {
    return _OfferDetailsScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OfferDetailsScreenControllerProvider &&
        other.offerLink == offerLink;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, offerLink.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OfferDetailsScreenControllerRef
    on AutoDisposeNotifierProviderRef<OfferDetailsScreenState> {
  /// The parameter `offerLink` of this provider.
  String get offerLink;
}

class _OfferDetailsScreenControllerProviderElement
    extends AutoDisposeNotifierProviderElement<OfferDetailsScreenController,
        OfferDetailsScreenState> with OfferDetailsScreenControllerRef {
  _OfferDetailsScreenControllerProviderElement(super.provider);

  @override
  String get offerLink =>
      (origin as OfferDetailsScreenControllerProvider).offerLink;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
