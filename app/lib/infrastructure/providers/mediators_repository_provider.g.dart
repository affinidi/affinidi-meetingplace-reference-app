// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mediators_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediatorsRepository)
final mediatorsRepositoryProvider = MediatorsRepositoryProvider._();

final class MediatorsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<MediatorsRepository>,
          MediatorsRepository,
          FutureOr<MediatorsRepository>
        >
    with
        $FutureModifier<MediatorsRepository>,
        $FutureProvider<MediatorsRepository> {
  MediatorsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediatorsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediatorsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<MediatorsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MediatorsRepository> create(Ref ref) {
    return mediatorsRepository(ref);
  }
}

String _$mediatorsRepositoryHash() =>
    r'85b22fa079e945acf870cd12ae1e781425c9a945';
