// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_offer_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$publishOfferScreenControllerHash() =>
    r'0f4d6090ed2084a4138eee895e2e1d2449cd96d8';

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

abstract class _$PublishOfferScreenController
    extends BuildlessAutoDisposeNotifier<PublishOfferScreenState> {
  late final String identityId;
  late final AppLocalizations l10n;

  PublishOfferScreenState build(String identityId, AppLocalizations l10n);
}

/// See also [PublishOfferScreenController].
@ProviderFor(PublishOfferScreenController)
const publishOfferScreenControllerProvider =
    PublishOfferScreenControllerFamily();

/// See also [PublishOfferScreenController].
class PublishOfferScreenControllerFamily
    extends Family<PublishOfferScreenState> {
  /// See also [PublishOfferScreenController].
  const PublishOfferScreenControllerFamily();

  /// See also [PublishOfferScreenController].
  PublishOfferScreenControllerProvider call(
    String identityId,
    AppLocalizations l10n,
  ) {
    return PublishOfferScreenControllerProvider(identityId, l10n);
  }

  @override
  PublishOfferScreenControllerProvider getProviderOverride(
    covariant PublishOfferScreenControllerProvider provider,
  ) {
    return call(provider.identityId, provider.l10n);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'publishOfferScreenControllerProvider';
}

/// See also [PublishOfferScreenController].
class PublishOfferScreenControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          PublishOfferScreenController,
          PublishOfferScreenState
        > {
  /// See also [PublishOfferScreenController].
  PublishOfferScreenControllerProvider(String identityId, AppLocalizations l10n)
    : this._internal(
        () => PublishOfferScreenController()
          ..identityId = identityId
          ..l10n = l10n,
        from: publishOfferScreenControllerProvider,
        name: r'publishOfferScreenControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$publishOfferScreenControllerHash,
        dependencies: PublishOfferScreenControllerFamily._dependencies,
        allTransitiveDependencies:
            PublishOfferScreenControllerFamily._allTransitiveDependencies,
        identityId: identityId,
        l10n: l10n,
      );

  PublishOfferScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.identityId,
    required this.l10n,
  }) : super.internal();

  final String identityId;
  final AppLocalizations l10n;

  @override
  PublishOfferScreenState runNotifierBuild(
    covariant PublishOfferScreenController notifier,
  ) {
    return notifier.build(identityId, l10n);
  }

  @override
  Override overrideWith(PublishOfferScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PublishOfferScreenControllerProvider._internal(
        () => create()
          ..identityId = identityId
          ..l10n = l10n,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        identityId: identityId,
        l10n: l10n,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    PublishOfferScreenController,
    PublishOfferScreenState
  >
  createElement() {
    return _PublishOfferScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PublishOfferScreenControllerProvider &&
        other.identityId == identityId &&
        other.l10n == l10n;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, identityId.hashCode);
    hash = _SystemHash.combine(hash, l10n.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PublishOfferScreenControllerRef
    on AutoDisposeNotifierProviderRef<PublishOfferScreenState> {
  /// The parameter `identityId` of this provider.
  String get identityId;

  /// The parameter `l10n` of this provider.
  AppLocalizations get l10n;
}

class _PublishOfferScreenControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          PublishOfferScreenController,
          PublishOfferScreenState
        >
    with PublishOfferScreenControllerRef {
  _PublishOfferScreenControllerProviderElement(super.provider);

  @override
  String get identityId =>
      (origin as PublishOfferScreenControllerProvider).identityId;
  @override
  AppLocalizations get l10n =>
      (origin as PublishOfferScreenControllerProvider).l10n;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
