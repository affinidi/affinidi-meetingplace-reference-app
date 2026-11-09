// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communities_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The communities the member belongs to or is applying to, as this phone
/// records them.

@ProviderFor(CommunitiesController)
const communitiesControllerProvider = CommunitiesControllerProvider._();

/// The communities the member belongs to or is applying to, as this phone
/// records them.
final class CommunitiesControllerProvider
    extends $AsyncNotifierProvider<CommunitiesController, List<VtcCommunity>> {
  /// The communities the member belongs to or is applying to, as this phone
  /// records them.
  const CommunitiesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'communitiesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$communitiesControllerHash();

  @$internal
  @override
  CommunitiesController create() => CommunitiesController();
}

String _$communitiesControllerHash() =>
    r'b5f48f2435a57adfcbd17ba1872e47324f01d857';

/// The communities the member belongs to or is applying to, as this phone
/// records them.

abstract class _$CommunitiesController
    extends $AsyncNotifier<List<VtcCommunity>> {
  FutureOr<List<VtcCommunity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<VtcCommunity>>, List<VtcCommunity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<VtcCommunity>>, List<VtcCommunity>>,
              AsyncValue<List<VtcCommunity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
