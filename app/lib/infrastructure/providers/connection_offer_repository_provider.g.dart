// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_offer_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectionOfferRepository)
final connectionOfferRepositoryProvider = ConnectionOfferRepositoryProvider._();

final class ConnectionOfferRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<model.ConnectionOfferRepository>,
          model.ConnectionOfferRepository,
          FutureOr<model.ConnectionOfferRepository>
        >
    with
        $FutureModifier<model.ConnectionOfferRepository>,
        $FutureProvider<model.ConnectionOfferRepository> {
  ConnectionOfferRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionOfferRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionOfferRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<model.ConnectionOfferRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<model.ConnectionOfferRepository> create(Ref ref) {
    return connectionOfferRepository(ref);
  }
}

String _$connectionOfferRepositoryHash() =>
    r'2939f01e908ed7a3854b8a4a7930a04c9b67a48e';
