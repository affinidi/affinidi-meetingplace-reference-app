// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_cache_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentCacheServiceHash() =>
    r'0487c92608dacaa18048c4cd538cfc75bebee5a5';

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

abstract class _$AttachmentCacheService
    extends BuildlessAutoDisposeNotifier<Map<String, Uint8List>> {
  late final String contactId;

  Map<String, Uint8List> build(String contactId);
}

/// Holds decrypted attachment bytes for a chat, keyed by [attachmentCacheKey].
///
/// Downloads hosted media via the [ChatService] and decodes legacy base64
/// attachments, deduplicating in-flight downloads. Owned per contact so the
/// chat screen and its widgets observe a single cache instance.
///
/// Copied from [AttachmentCacheService].
@ProviderFor(AttachmentCacheService)
const attachmentCacheServiceProvider = AttachmentCacheServiceFamily();

/// Holds decrypted attachment bytes for a chat, keyed by [attachmentCacheKey].
///
/// Downloads hosted media via the [ChatService] and decodes legacy base64
/// attachments, deduplicating in-flight downloads. Owned per contact so the
/// chat screen and its widgets observe a single cache instance.
///
/// Copied from [AttachmentCacheService].
class AttachmentCacheServiceFamily extends Family<Map<String, Uint8List>> {
  /// Holds decrypted attachment bytes for a chat, keyed by [attachmentCacheKey].
  ///
  /// Downloads hosted media via the [ChatService] and decodes legacy base64
  /// attachments, deduplicating in-flight downloads. Owned per contact so the
  /// chat screen and its widgets observe a single cache instance.
  ///
  /// Copied from [AttachmentCacheService].
  const AttachmentCacheServiceFamily();

  /// Holds decrypted attachment bytes for a chat, keyed by [attachmentCacheKey].
  ///
  /// Downloads hosted media via the [ChatService] and decodes legacy base64
  /// attachments, deduplicating in-flight downloads. Owned per contact so the
  /// chat screen and its widgets observe a single cache instance.
  ///
  /// Copied from [AttachmentCacheService].
  AttachmentCacheServiceProvider call(String contactId) {
    return AttachmentCacheServiceProvider(contactId);
  }

  @override
  AttachmentCacheServiceProvider getProviderOverride(
    covariant AttachmentCacheServiceProvider provider,
  ) {
    return call(provider.contactId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'attachmentCacheServiceProvider';
}

/// Holds decrypted attachment bytes for a chat, keyed by [attachmentCacheKey].
///
/// Downloads hosted media via the [ChatService] and decodes legacy base64
/// attachments, deduplicating in-flight downloads. Owned per contact so the
/// chat screen and its widgets observe a single cache instance.
///
/// Copied from [AttachmentCacheService].
class AttachmentCacheServiceProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AttachmentCacheService,
          Map<String, Uint8List>
        > {
  /// Holds decrypted attachment bytes for a chat, keyed by [attachmentCacheKey].
  ///
  /// Downloads hosted media via the [ChatService] and decodes legacy base64
  /// attachments, deduplicating in-flight downloads. Owned per contact so the
  /// chat screen and its widgets observe a single cache instance.
  ///
  /// Copied from [AttachmentCacheService].
  AttachmentCacheServiceProvider(String contactId)
    : this._internal(
        () => AttachmentCacheService()..contactId = contactId,
        from: attachmentCacheServiceProvider,
        name: r'attachmentCacheServiceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$attachmentCacheServiceHash,
        dependencies: AttachmentCacheServiceFamily._dependencies,
        allTransitiveDependencies:
            AttachmentCacheServiceFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  AttachmentCacheServiceProvider._internal(
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
  Map<String, Uint8List> runNotifierBuild(
    covariant AttachmentCacheService notifier,
  ) {
    return notifier.build(contactId);
  }

  @override
  Override overrideWith(AttachmentCacheService Function() create) {
    return ProviderOverride(
      origin: this,
      override: AttachmentCacheServiceProvider._internal(
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
  AutoDisposeNotifierProviderElement<
    AttachmentCacheService,
    Map<String, Uint8List>
  >
  createElement() {
    return _AttachmentCacheServiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachmentCacheServiceProvider &&
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
mixin AttachmentCacheServiceRef
    on AutoDisposeNotifierProviderRef<Map<String, Uint8List>> {
  /// The parameter `contactId` of this provider.
  String get contactId;
}

class _AttachmentCacheServiceProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AttachmentCacheService,
          Map<String, Uint8List>
        >
    with AttachmentCacheServiceRef {
  _AttachmentCacheServiceProviderElement(super.provider);

  @override
  String get contactId => (origin as AttachmentCacheServiceProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
