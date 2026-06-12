// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chatRepository)
const chatRepositoryProvider = ChatRepositoryProvider._();

final class ChatRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChatRepository>,
          ChatRepository,
          FutureOr<ChatRepository>
        >
    with $FutureModifier<ChatRepository>, $FutureProvider<ChatRepository> {
  const ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ChatRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChatRepository> create(Ref ref) {
    return chatRepository(ref);
  }
}

String _$chatRepositoryHash() => r'14b2c60cf648fb2256b900ba4a845a7db02fae84';
