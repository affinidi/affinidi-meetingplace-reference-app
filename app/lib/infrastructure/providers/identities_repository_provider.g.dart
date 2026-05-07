// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identities_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(identitiesRepository)
final identitiesRepositoryProvider = IdentitiesRepositoryProvider._();

final class IdentitiesRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<IdentitiesRepository>,
          IdentitiesRepository,
          FutureOr<IdentitiesRepository>
        >
    with
        $FutureModifier<IdentitiesRepository>,
        $FutureProvider<IdentitiesRepository> {
  IdentitiesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identitiesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identitiesRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<IdentitiesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<IdentitiesRepository> create(Ref ref) {
    return identitiesRepository(ref);
  }
}

String _$identitiesRepositoryHash() =>
    r'1b1e9f2fe33b9e9fba1529a575bfb1616fb19d29';
