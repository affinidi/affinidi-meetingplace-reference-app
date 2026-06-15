// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_media_bytes_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Process-lifetime warm cache shared by every per-chat
/// `AttachmentCacheService` instance.

@ProviderFor(chatMediaBytesCache)
const chatMediaBytesCacheProvider = ChatMediaBytesCacheProvider._();

/// Process-lifetime warm cache shared by every per-chat
/// `AttachmentCacheService` instance.

final class ChatMediaBytesCacheProvider
    extends
        $FunctionalProvider<
          ChatMediaBytesCache,
          ChatMediaBytesCache,
          ChatMediaBytesCache
        >
    with $Provider<ChatMediaBytesCache> {
  /// Process-lifetime warm cache shared by every per-chat
  /// `AttachmentCacheService` instance.
  const ChatMediaBytesCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatMediaBytesCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatMediaBytesCacheHash();

  @$internal
  @override
  $ProviderElement<ChatMediaBytesCache> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChatMediaBytesCache create(Ref ref) {
    return chatMediaBytesCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatMediaBytesCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatMediaBytesCache>(value),
    );
  }
}

String _$chatMediaBytesCacheHash() =>
    r'b61436e8ca2f3df3f56c06169b15d5b804d597d8';
