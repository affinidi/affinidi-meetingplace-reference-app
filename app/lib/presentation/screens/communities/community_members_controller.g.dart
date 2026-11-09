// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens.

@ProviderFor(CommunityMembersController)
const communityMembersControllerProvider = CommunityMembersControllerFamily._();

/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens.
final class CommunityMembersControllerProvider
    extends
        $AsyncNotifierProvider<CommunityMembersController, CommunityMembers> {
  /// The members of [communityDid]'s groups, read once the community is
  /// opened and kept while the app runs, so its Members tab shows them at
  /// once. The tab [sync]s them each time it opens.
  const CommunityMembersControllerProvider._({
    required CommunityMembersControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'communityMembersControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$communityMembersControllerHash();

  @override
  String toString() {
    return r'communityMembersControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CommunityMembersController create() => CommunityMembersController();

  @override
  bool operator ==(Object other) {
    return other is CommunityMembersControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$communityMembersControllerHash() =>
    r'5bbc418020e315a2971a6f0cef55d9f00ba24f6b';

/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens.

final class CommunityMembersControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CommunityMembersController,
          AsyncValue<CommunityMembers>,
          CommunityMembers,
          FutureOr<CommunityMembers>,
          String
        > {
  const CommunityMembersControllerFamily._()
    : super(
        retry: null,
        name: r'communityMembersControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The members of [communityDid]'s groups, read once the community is
  /// opened and kept while the app runs, so its Members tab shows them at
  /// once. The tab [sync]s them each time it opens.

  CommunityMembersControllerProvider call(String communityDid) =>
      CommunityMembersControllerProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityMembersControllerProvider';
}

/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens.

abstract class _$CommunityMembersController
    extends $AsyncNotifier<CommunityMembers> {
  late final _$args = ref.$arg as String;
  String get communityDid => _$args;

  FutureOr<CommunityMembers> build(String communityDid);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<CommunityMembers>, CommunityMembers>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CommunityMembers>, CommunityMembers>,
              AsyncValue<CommunityMembers>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
