// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupsRepository)
final groupsRepositoryProvider = GroupsRepositoryProvider._();

final class GroupsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<model.GroupRepository>,
          model.GroupRepository,
          FutureOr<model.GroupRepository>
        >
    with
        $FutureModifier<model.GroupRepository>,
        $FutureProvider<model.GroupRepository> {
  GroupsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<model.GroupRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<model.GroupRepository> create(Ref ref) {
    return groupsRepository(ref);
  }
}

String _$groupsRepositoryHash() => r'1a216e5fe68aea3f4f9f108c028f434157ce762b';
