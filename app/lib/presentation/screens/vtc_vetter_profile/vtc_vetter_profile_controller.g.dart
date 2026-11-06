// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vtc_vetter_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads and publishes the member's vetter profile for one community. Only
/// a failure's type is logged, never what the profile says.

@ProviderFor(VtcVetterProfileController)
const vtcVetterProfileControllerProvider = VtcVetterProfileControllerFamily._();

/// Reads and publishes the member's vetter profile for one community. Only
/// a failure's type is logged, never what the profile says.
final class VtcVetterProfileControllerProvider
    extends
        $NotifierProvider<VtcVetterProfileController, VtcVetterProfileState> {
  /// Reads and publishes the member's vetter profile for one community. Only
  /// a failure's type is logged, never what the profile says.
  const VtcVetterProfileControllerProvider._({
    required VtcVetterProfileControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vtcVetterProfileControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vtcVetterProfileControllerHash();

  @override
  String toString() {
    return r'vtcVetterProfileControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VtcVetterProfileController create() => VtcVetterProfileController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VtcVetterProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VtcVetterProfileState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VtcVetterProfileControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vtcVetterProfileControllerHash() =>
    r'b653df81599ddde2de74ff4affc836de8838ecf6';

/// Reads and publishes the member's vetter profile for one community. Only
/// a failure's type is logged, never what the profile says.

final class VtcVetterProfileControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          VtcVetterProfileController,
          VtcVetterProfileState,
          VtcVetterProfileState,
          VtcVetterProfileState,
          String
        > {
  const VtcVetterProfileControllerFamily._()
    : super(
        retry: null,
        name: r'vtcVetterProfileControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Reads and publishes the member's vetter profile for one community. Only
  /// a failure's type is logged, never what the profile says.

  VtcVetterProfileControllerProvider call(String communityDid) =>
      VtcVetterProfileControllerProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'vtcVetterProfileControllerProvider';
}

/// Reads and publishes the member's vetter profile for one community. Only
/// a failure's type is logged, never what the profile says.

abstract class _$VtcVetterProfileController
    extends $Notifier<VtcVetterProfileState> {
  late final _$args = ref.$arg as String;
  String get communityDid => _$args;

  VtcVetterProfileState build(String communityDid);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<VtcVetterProfileState, VtcVetterProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VtcVetterProfileState, VtcVetterProfileState>,
              VtcVetterProfileState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
