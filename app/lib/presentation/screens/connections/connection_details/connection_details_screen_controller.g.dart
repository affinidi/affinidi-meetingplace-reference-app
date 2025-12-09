// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_details_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectionDetailsScreenControllerHash() =>
    r'3daeaf2aac89936233b856e624e8985fc432b439';

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

abstract class _$ConnectionDetailsScreenController
    extends BuildlessAutoDisposeNotifier<ConnectionDetailsScreenState> {
  late final String contactId;

  ConnectionDetailsScreenState build(
    String contactId,
  );
}

/// See also [ConnectionDetailsScreenController].
@ProviderFor(ConnectionDetailsScreenController)
const connectionDetailsScreenControllerProvider =
    ConnectionDetailsScreenControllerFamily();

/// See also [ConnectionDetailsScreenController].
class ConnectionDetailsScreenControllerFamily
    extends Family<ConnectionDetailsScreenState> {
  /// See also [ConnectionDetailsScreenController].
  const ConnectionDetailsScreenControllerFamily();

  /// See also [ConnectionDetailsScreenController].
  ConnectionDetailsScreenControllerProvider call(
    String contactId,
  ) {
    return ConnectionDetailsScreenControllerProvider(
      contactId,
    );
  }

  @override
  ConnectionDetailsScreenControllerProvider getProviderOverride(
    covariant ConnectionDetailsScreenControllerProvider provider,
  ) {
    return call(
      provider.contactId,
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
  String? get name => r'connectionDetailsScreenControllerProvider';
}

/// See also [ConnectionDetailsScreenController].
class ConnectionDetailsScreenControllerProvider
    extends AutoDisposeNotifierProviderImpl<ConnectionDetailsScreenController,
        ConnectionDetailsScreenState> {
  /// See also [ConnectionDetailsScreenController].
  ConnectionDetailsScreenControllerProvider(
    String contactId,
  ) : this._internal(
          () => ConnectionDetailsScreenController()..contactId = contactId,
          from: connectionDetailsScreenControllerProvider,
          name: r'connectionDetailsScreenControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$connectionDetailsScreenControllerHash,
          dependencies: ConnectionDetailsScreenControllerFamily._dependencies,
          allTransitiveDependencies: ConnectionDetailsScreenControllerFamily
              ._allTransitiveDependencies,
          contactId: contactId,
        );

  ConnectionDetailsScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final String contactId;

  @override
  ConnectionDetailsScreenState runNotifierBuild(
    covariant ConnectionDetailsScreenController notifier,
  ) {
    return notifier.build(
      contactId,
    );
  }

  @override
  Override overrideWith(ConnectionDetailsScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ConnectionDetailsScreenControllerProvider._internal(
        () => create()..contactId = contactId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ConnectionDetailsScreenController,
      ConnectionDetailsScreenState> createElement() {
    return _ConnectionDetailsScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConnectionDetailsScreenControllerProvider &&
        other.contactId == contactId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConnectionDetailsScreenControllerRef
    on AutoDisposeNotifierProviderRef<ConnectionDetailsScreenState> {
  /// The parameter `contactId` of this provider.
  String get contactId;
}

class _ConnectionDetailsScreenControllerProviderElement
    extends AutoDisposeNotifierProviderElement<
        ConnectionDetailsScreenController, ConnectionDetailsScreenState>
    with ConnectionDetailsScreenControllerRef {
  _ConnectionDetailsScreenControllerProviderElement(super.provider);

  @override
  String get contactId =>
      (origin as ConnectionDetailsScreenControllerProvider).contactId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
