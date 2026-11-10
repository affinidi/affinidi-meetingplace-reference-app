// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vtc_findable_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether other members of [communityDid] can find the member, read once
/// the community is opened and kept while the app runs, so its settings
/// show it at once. The settings [sync] it each time they open.

@ProviderFor(VtcFindableController)
const vtcFindableControllerProvider = VtcFindableControllerFamily._();

/// Whether other members of [communityDid] can find the member, read once
/// the community is opened and kept while the app runs, so its settings
/// show it at once. The settings [sync] it each time they open.
final class VtcFindableControllerProvider
    extends $AsyncNotifierProvider<VtcFindableController, VtcFindable> {
  /// Whether other members of [communityDid] can find the member, read once
  /// the community is opened and kept while the app runs, so its settings
  /// show it at once. The settings [sync] it each time they open.
  const VtcFindableControllerProvider._({
    required VtcFindableControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'vtcFindableControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vtcFindableControllerHash();

  @override
  String toString() {
    return r'vtcFindableControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VtcFindableController create() => VtcFindableController();

  @override
  bool operator ==(Object other) {
    return other is VtcFindableControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vtcFindableControllerHash() =>
    r'2d8da2ed6886487ff6a7d6e476e5d10890c2e428';

/// Whether other members of [communityDid] can find the member, read once
/// the community is opened and kept while the app runs, so its settings
/// show it at once. The settings [sync] it each time they open.

final class VtcFindableControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          VtcFindableController,
          AsyncValue<VtcFindable>,
          VtcFindable,
          FutureOr<VtcFindable>,
          String
        > {
  const VtcFindableControllerFamily._()
    : super(
        retry: _noRetry,
        name: r'vtcFindableControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Whether other members of [communityDid] can find the member, read once
  /// the community is opened and kept while the app runs, so its settings
  /// show it at once. The settings [sync] it each time they open.

  VtcFindableControllerProvider call(String communityDid) =>
      VtcFindableControllerProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'vtcFindableControllerProvider';
}

/// Whether other members of [communityDid] can find the member, read once
/// the community is opened and kept while the app runs, so its settings
/// show it at once. The settings [sync] it each time they open.

abstract class _$VtcFindableController extends $AsyncNotifier<VtcFindable> {
  late final _$args = ref.$arg as String;
  String get communityDid => _$args;

  FutureOr<VtcFindable> build(String communityDid);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<VtcFindable>, VtcFindable>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VtcFindable>, VtcFindable>,
              AsyncValue<VtcFindable>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
