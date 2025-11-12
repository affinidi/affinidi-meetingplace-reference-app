import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'qr_code_picker_state.dart';

part 'qr_code_picker_controller.g.dart';

@riverpod
class QrCodePickerController extends _$QrCodePickerController {
  QrCodePickerController() : super();

  MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _disposing = false;

  @override
  QrCodePickerState build() {
    ref.onDispose(() {
      scannerController.dispose();
    });

    return QrCodePickerState();
  }

  void onDetect(
    BarcodeCapture capture, {
    required void Function(String barCode) onSuccess,
  }) {
    final barcode = capture.barcodes
        .firstWhereOrNull((barcode) => barcode.rawValue != null)
        ?.rawValue;
    if (barcode == null) return;

    if (!_disposing) {
      _disposing = true;

      log('QR Code found! $barcode', name: 'QrCodePickerController');
      Future(() {
        onSuccess.call(barcode);
      });
    }
  }
}
