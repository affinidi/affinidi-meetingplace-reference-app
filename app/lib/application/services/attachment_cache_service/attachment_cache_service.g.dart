// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_cache_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds decrypted attachment bytes for a chat, keyed by
/// [AttachmentCacheService.cacheKey].
///
/// Downloads hosted media via the [ChatService] and decodes legacy base64
/// attachments, deduplicating in-flight downloads. Owned per contact so the
/// chat screen and its widgets observe a single cache instance.

@ProviderFor(AttachmentCacheService)
const attachmentCacheServiceProvider = AttachmentCacheServiceFamily._();

/// Holds decrypted attachment bytes for a chat, keyed by
/// [AttachmentCacheService.cacheKey].
///
/// Downloads hosted media via the [ChatService] and decodes legacy base64
/// attachments, deduplicating in-flight downloads. Owned per contact so the
/// chat screen and its widgets observe a single cache instance.
final class AttachmentCacheServiceProvider
    extends $NotifierProvider<AttachmentCacheService, Map<String, Uint8List>> {
  /// Holds decrypted attachment bytes for a chat, keyed by
  /// [AttachmentCacheService.cacheKey].
  ///
  /// Downloads hosted media via the [ChatService] and decodes legacy base64
  /// attachments, deduplicating in-flight downloads. Owned per contact so the
  /// chat screen and its widgets observe a single cache instance.
  const AttachmentCacheServiceProvider._({
    required AttachmentCacheServiceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'attachmentCacheServiceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$attachmentCacheServiceHash();

  @override
  String toString() {
    return r'attachmentCacheServiceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AttachmentCacheService create() => AttachmentCacheService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Uint8List> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Uint8List>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AttachmentCacheServiceProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$attachmentCacheServiceHash() =>
    r'b1ef89132a4b4714be3f8fd85531b47b6e9083c1';

/// Holds decrypted attachment bytes for a chat, keyed by
/// [AttachmentCacheService.cacheKey].
///
/// Downloads hosted media via the [ChatService] and decodes legacy base64
/// attachments, deduplicating in-flight downloads. Owned per contact so the
/// chat screen and its widgets observe a single cache instance.

final class AttachmentCacheServiceFamily extends $Family
    with
        $ClassFamilyOverride<
          AttachmentCacheService,
          Map<String, Uint8List>,
          Map<String, Uint8List>,
          Map<String, Uint8List>,
          String
        > {
  const AttachmentCacheServiceFamily._()
    : super(
        retry: null,
        name: r'attachmentCacheServiceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Holds decrypted attachment bytes for a chat, keyed by
  /// [AttachmentCacheService.cacheKey].
  ///
  /// Downloads hosted media via the [ChatService] and decodes legacy base64
  /// attachments, deduplicating in-flight downloads. Owned per contact so the
  /// chat screen and its widgets observe a single cache instance.

  AttachmentCacheServiceProvider call(String contactId) =>
      AttachmentCacheServiceProvider._(argument: contactId, from: this);

  @override
  String toString() => r'attachmentCacheServiceProvider';
}

/// Holds decrypted attachment bytes for a chat, keyed by
/// [AttachmentCacheService.cacheKey].
///
/// Downloads hosted media via the [ChatService] and decodes legacy base64
/// attachments, deduplicating in-flight downloads. Owned per contact so the
/// chat screen and its widgets observe a single cache instance.

abstract class _$AttachmentCacheService
    extends $Notifier<Map<String, Uint8List>> {
  late final _$args = ref.$arg as String;
  String get contactId => _$args;

  Map<String, Uint8List> build(String contactId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<Map<String, Uint8List>, Map<String, Uint8List>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Uint8List>, Map<String, Uint8List>>,
              Map<String, Uint8List>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
