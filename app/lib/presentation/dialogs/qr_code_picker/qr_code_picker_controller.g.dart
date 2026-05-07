// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_picker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(QrCodePickerController)
final qrCodePickerControllerProvider = QrCodePickerControllerProvider._();

final class QrCodePickerControllerProvider
    extends $NotifierProvider<QrCodePickerController, QrCodePickerState> {
  QrCodePickerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'qrCodePickerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$qrCodePickerControllerHash();

  @$internal
  @override
  QrCodePickerController create() => QrCodePickerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QrCodePickerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QrCodePickerState>(value),
    );
  }
}

String _$qrCodePickerControllerHash() =>
    r'0696f6439dd0255af4cfab54a10311a3983d6001';

abstract class _$QrCodePickerController extends $Notifier<QrCodePickerState> {
  QrCodePickerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<QrCodePickerState, QrCodePickerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<QrCodePickerState, QrCodePickerState>,
              QrCodePickerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
