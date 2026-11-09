// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vtc_join_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives joining one community, from its scanned code to the community's
/// answer. Only a failure's code is logged; never a DID, key or document.

@ProviderFor(VtcJoinController)
const vtcJoinControllerProvider = VtcJoinControllerProvider._();

/// Drives joining one community, from its scanned code to the community's
/// answer. Only a failure's code is logged; never a DID, key or document.
final class VtcJoinControllerProvider
    extends $NotifierProvider<VtcJoinController, VtcJoinState> {
  /// Drives joining one community, from its scanned code to the community's
  /// answer. Only a failure's code is logged; never a DID, key or document.
  const VtcJoinControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vtcJoinControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vtcJoinControllerHash();

  @$internal
  @override
  VtcJoinController create() => VtcJoinController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VtcJoinState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VtcJoinState>(value),
    );
  }
}

String _$vtcJoinControllerHash() => r'728be001c2e96b71b73b6d9d5217c8d48a41d442';

/// Drives joining one community, from its scanned code to the community's
/// answer. Only a failure's code is logged; never a DID, key or document.

abstract class _$VtcJoinController extends $Notifier<VtcJoinState> {
  VtcJoinState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<VtcJoinState, VtcJoinState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VtcJoinState, VtcJoinState>,
              VtcJoinState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
