// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(channelRepository)
final channelRepositoryProvider = ChannelRepositoryProvider._();

final class ChannelRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<model.ChannelRepository>,
          model.ChannelRepository,
          FutureOr<model.ChannelRepository>
        >
    with
        $FutureModifier<model.ChannelRepository>,
        $FutureProvider<model.ChannelRepository> {
  ChannelRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'channelRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$channelRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<model.ChannelRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<model.ChannelRepository> create(Ref ref) {
    return channelRepository(ref);
  }
}

String _$channelRepositoryHash() => r'af56608bd27c22c8d4bcd44f9e2a5fcce88451eb';
