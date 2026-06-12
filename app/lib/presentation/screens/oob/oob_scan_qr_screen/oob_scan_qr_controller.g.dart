// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oob_scan_qr_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OobScanQrController)
const oobScanQrControllerProvider = OobScanQrControllerProvider._();

final class OobScanQrControllerProvider
    extends $NotifierProvider<OobScanQrController, OobScanQrState> {
  const OobScanQrControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oobScanQrControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oobScanQrControllerHash();

  @$internal
  @override
  OobScanQrController create() => OobScanQrController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OobScanQrState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OobScanQrState>(value),
    );
  }
}

String _$oobScanQrControllerHash() =>
    r'b44d3b2ad49b0378ac7187f84e8ad944410eacb0';

abstract class _$OobScanQrController extends $Notifier<OobScanQrState> {
  OobScanQrState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<OobScanQrState, OobScanQrState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OobScanQrState, OobScanQrState>,
              OobScanQrState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
