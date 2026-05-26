import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/services/camera_service/camera_service.dart';
import 'qr_code_picker_state.dart';

part 'qr_code_picker_controller.g.dart';

@riverpod
class QrCodePickerController extends _$QrCodePickerController {
  QrCodePickerController() : super();

  final scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  QrCodePickerState build() {
    ref.listen(
      cameraServiceProvider.select((state) => state.isAvailable),
      (prev, next) {
        Future(() {
          state = state.copyWith(isCameraAvailable: next);
        });
      },
      fireImmediately: true,
    );

    ref.onDispose(() {
      unawaited(() async {
        await scannerController.stop();
        await scannerController.dispose();
      }());
    });

    return QrCodePickerState();
  }

  Future<void> updateScaleFactor(double scale) async {
    state = state.copyWith(scaleFactor: state.baseScaleFactor * scale);
    await scannerController.setZoomScale(state.scaleFactor);
  }

  void updateBaseScaleFactor(double scaleFactor) {
    state = state.copyWith(baseScaleFactor: scaleFactor);
  }

  Future<void> stopScanner() => scannerController.stop();
}
