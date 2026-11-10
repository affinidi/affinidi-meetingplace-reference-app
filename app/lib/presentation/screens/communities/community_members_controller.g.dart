// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_members_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens, and they sync when the
/// member's role there changes, which the directory shows.

@ProviderFor(CommunityMembersController)
const communityMembersControllerProvider = CommunityMembersControllerFamily._();

/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens, and they sync when the
/// member's role there changes, which the directory shows.
final class CommunityMembersControllerProvider
    extends
        $AsyncNotifierProvider<CommunityMembersController, CommunityMembers> {
  /// The members of [communityDid]'s groups, read once the community is
  /// opened and kept while the app runs, so its Members tab shows them at
  /// once. The tab [sync]s them each time it opens, and they sync when the
  /// member's role there changes, which the directory shows.
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
    r'2aba4ed38dc5cb390a58eb68d07306d5b5658ee1';

/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens, and they sync when the
/// member's role there changes, which the directory shows.

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
  /// once. The tab [sync]s them each time it opens, and they sync when the
  /// member's role there changes, which the directory shows.

  CommunityMembersControllerProvider call(String communityDid) =>
      CommunityMembersControllerProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'communityMembersControllerProvider';
}

/// The members of [communityDid]'s groups, read once the community is
/// opened and kept while the app runs, so its Members tab shows them at
/// once. The tab [sync]s them each time it opens, and they sync when the
/// member's role there changes, which the directory shows.

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
