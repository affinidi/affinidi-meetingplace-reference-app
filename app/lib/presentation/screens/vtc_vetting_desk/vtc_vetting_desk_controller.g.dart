// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vtc_vetting_desk_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the member's vetting desk for one community: shows a ticket, and
/// vets each applicant who comes with it. Only a failure's type is logged;
/// never a DID, a detail from a card or a document.

@ProviderFor(VtcVettingDeskController)
const vtcVettingDeskControllerProvider = VtcVettingDeskControllerFamily._();

/// Drives the member's vetting desk for one community: shows a ticket, and
/// vets each applicant who comes with it. Only a failure's type is logged;
/// never a DID, a detail from a card or a document.
final class VtcVettingDeskControllerProvider
    extends $NotifierProvider<VtcVettingDeskController, VtcVettingDeskState> {
  /// Drives the member's vetting desk for one community: shows a ticket, and
  /// vets each applicant who comes with it. Only a failure's type is logged;
  /// never a DID, a detail from a card or a document.
  const VtcVettingDeskControllerProvider._({
    required VtcVettingDeskControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'vtcVettingDeskControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vtcVettingDeskControllerHash();

  @override
  String toString() {
    return r'vtcVettingDeskControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VtcVettingDeskController create() => VtcVettingDeskController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VtcVettingDeskState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VtcVettingDeskState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VtcVettingDeskControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vtcVettingDeskControllerHash() =>
    r'b07b7de2292d537ddce6ca8aef66bef0857d6c21';

/// Drives the member's vetting desk for one community: shows a ticket, and
/// vets each applicant who comes with it. Only a failure's type is logged;
/// never a DID, a detail from a card or a document.

final class VtcVettingDeskControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          VtcVettingDeskController,
          VtcVettingDeskState,
          VtcVettingDeskState,
          VtcVettingDeskState,
          String
        > {
  const VtcVettingDeskControllerFamily._()
    : super(
        retry: null,
        name: r'vtcVettingDeskControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives the member's vetting desk for one community: shows a ticket, and
  /// vets each applicant who comes with it. Only a failure's type is logged;
  /// never a DID, a detail from a card or a document.

  VtcVettingDeskControllerProvider call(String communityDid) =>
      VtcVettingDeskControllerProvider._(argument: communityDid, from: this);

  @override
  String toString() => r'vtcVettingDeskControllerProvider';
}

/// Drives the member's vetting desk for one community: shows a ticket, and
/// vets each applicant who comes with it. Only a failure's type is logged;
/// never a DID, a detail from a card or a document.

abstract class _$VtcVettingDeskController
    extends $Notifier<VtcVettingDeskState> {
  late final _$args = ref.$arg as String;
  String get communityDid => _$args;

  VtcVettingDeskState build(String communityDid);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<VtcVettingDeskState, VtcVettingDeskState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VtcVettingDeskState, VtcVettingDeskState>,
              VtcVettingDeskState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
