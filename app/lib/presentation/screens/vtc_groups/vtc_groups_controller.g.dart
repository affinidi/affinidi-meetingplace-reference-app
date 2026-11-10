// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vtc_groups_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The member's groups in the community [communityDid], each with its chat:
/// created by a manager, found through the link the community publishes,
/// and joined with the group's credential. Only a failure's code is
/// logged; never a group, a member or a DID.

@ProviderFor(VtcGroupsController)
const vtcGroupsControllerProvider = VtcGroupsControllerFamily._();

/// The member's groups in the community [communityDid], each with its chat:
/// created by a manager, found through the link the community publishes,
/// and joined with the group's credential. Only a failure's code is
/// logged; never a group, a member or a DID.
final class VtcGroupsControllerProvider
    extends $NotifierProvider<VtcGroupsController, VtcGroupsState> {
  /// The member's groups in the community [communityDid], each with its chat:
  /// created by a manager, found through the link the community publishes,
  /// and joined with the group's credential. Only a failure's code is
  /// logged; never a group, a member or a DID.
  const VtcGroupsControllerProvider._({
    required VtcGroupsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vtcGroupsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vtcGroupsControllerHash();

  @override
  String toString() {
    return r'vtcGroupsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VtcGroupsController create() => VtcGroupsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VtcGroupsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VtcGroupsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VtcGroupsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vtcGroupsControllerHash() =>
    r'8f4d4b12f8be8082bf608f34337e4d4399903b00';

/// The member's groups in the community [communityDid], each with its chat:
/// created by a manager, found through the link the community publishes,
/// and joined with the group's credential. Only a failure's code is
/// logged; never a group, a member or a DID.

final class VtcGroupsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          VtcGroupsController,
          VtcGroupsState,
          VtcGroupsState,
          VtcGroupsState,
          String
        > {
  const VtcGroupsControllerFamily._()
    : super(
        retry: null,
        name: r'vtcGroupsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The member's groups in the community [communityDid], each with its chat:
  /// created by a manager, found through the link the community publishes,
  /// and joined with the group's credential. Only a failure's code is
  /// logged; never a group, a member or a DID.

  VtcGroupsControllerProvider call(String communityDid) =>
      VtcGroupsControllerProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'vtcGroupsControllerProvider';
}

/// The member's groups in the community [communityDid], each with its chat:
/// created by a manager, found through the link the community publishes,
/// and joined with the group's credential. Only a failure's code is
/// logged; never a group, a member or a DID.

abstract class _$VtcGroupsController extends $Notifier<VtcGroupsState> {
  late final _$args = ref.$arg as String;
  String get communityDid => _$args;

  VtcGroupsState build(String communityDid);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<VtcGroupsState, VtcGroupsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VtcGroupsState, VtcGroupsState>,
              VtcGroupsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
