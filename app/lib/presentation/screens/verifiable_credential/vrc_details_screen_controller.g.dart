// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vrc_details_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VrcDetailsScreenController)
const vrcDetailsScreenControllerProvider = VrcDetailsScreenControllerFamily._();

final class VrcDetailsScreenControllerProvider
    extends
        $NotifierProvider<VrcDetailsScreenController, VrcDetailsScreenState> {
  const VrcDetailsScreenControllerProvider._({
    required VrcDetailsScreenControllerFamily super.from,
    required (String, {String? vcBlob}) super.argument,
  }) : super(
         retry: null,
         name: r'vrcDetailsScreenControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vrcDetailsScreenControllerHash();

  @override
  String toString() {
    return r'vrcDetailsScreenControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  VrcDetailsScreenController create() => VrcDetailsScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VrcDetailsScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VrcDetailsScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VrcDetailsScreenControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vrcDetailsScreenControllerHash() =>
    r'8d629bef40b7df61443593a41c471d18b463f200';

final class VrcDetailsScreenControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          VrcDetailsScreenController,
          VrcDetailsScreenState,
          VrcDetailsScreenState,
          VrcDetailsScreenState,
          (String, {String? vcBlob})
        > {
  const VrcDetailsScreenControllerFamily._()
    : super(
        retry: null,
        name: r'vrcDetailsScreenControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VrcDetailsScreenControllerProvider call(
    String credentialId, {
    String? vcBlob,
  }) => VrcDetailsScreenControllerProvider._(
    argument: (credentialId, vcBlob: vcBlob),
    from: this,
  );

  @override
  String toString() => r'vrcDetailsScreenControllerProvider';
}

abstract class _$VrcDetailsScreenController
    extends $Notifier<VrcDetailsScreenState> {
  late final _$args = ref.$arg as (String, {String? vcBlob});
  String get credentialId => _$args.$1;
  String? get vcBlob => _$args.vcBlob;

  VrcDetailsScreenState build(String credentialId, {String? vcBlob});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, vcBlob: _$args.vcBlob);
    final ref = this.ref as $Ref<VrcDetailsScreenState, VrcDetailsScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VrcDetailsScreenState, VrcDetailsScreenState>,
              VrcDetailsScreenState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
