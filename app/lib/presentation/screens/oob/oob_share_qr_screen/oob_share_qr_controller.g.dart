// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oob_share_qr_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OobShareQrController)
final oobShareQrControllerProvider = OobShareQrControllerProvider._();

final class OobShareQrControllerProvider
    extends $NotifierProvider<OobShareQrController, OobShareQrState> {
  OobShareQrControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oobShareQrControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oobShareQrControllerHash();

  @$internal
  @override
  OobShareQrController create() => OobShareQrController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OobShareQrState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OobShareQrState>(value),
    );
  }
}

String _$oobShareQrControllerHash() =>
    r'1df789bb32d1fefe1b015c4b42d6d7869f081a8b';

abstract class _$OobShareQrController extends $Notifier<OobShareQrState> {
  OobShareQrState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OobShareQrState, OobShareQrState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OobShareQrState, OobShareQrState>,
              OobShareQrState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
