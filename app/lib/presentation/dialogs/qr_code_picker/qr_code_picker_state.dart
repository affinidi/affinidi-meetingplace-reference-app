import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr_code_picker_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class QrCodePickerState with _$QrCodePickerState {
  factory QrCodePickerState({
    bool? cameraAvailable,
  }) = _QrCodePickerState;
}
