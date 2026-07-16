// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'end_call_banner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EndCallBannerController)
const endCallBannerControllerProvider = EndCallBannerControllerProvider._();

final class EndCallBannerControllerProvider
    extends $NotifierProvider<EndCallBannerController, EndCallBannerState?> {
  const EndCallBannerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'endCallBannerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$endCallBannerControllerHash();

  @$internal
  @override
  EndCallBannerController create() => EndCallBannerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EndCallBannerState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EndCallBannerState?>(value),
    );
  }
}

String _$endCallBannerControllerHash() =>
    r'925042ca99a1af73a3d6f32c3baeb1c04c14a109';

abstract class _$EndCallBannerController
    extends $Notifier<EndCallBannerState?> {
  EndCallBannerState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<EndCallBannerState?, EndCallBannerState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EndCallBannerState?, EndCallBannerState?>,
              EndCallBannerState?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
