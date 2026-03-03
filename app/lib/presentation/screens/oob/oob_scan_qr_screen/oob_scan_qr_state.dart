import 'package:freezed_annotation/freezed_annotation.dart';

part 'oob_scan_qr_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class OobScanQrState with _$OobScanQrState {
  factory OobScanQrState({
    @Default(false) bool isProcessing,
    String? errorMessage,
    String? scannedCode,
  }) = _OobScanQrState;
}
