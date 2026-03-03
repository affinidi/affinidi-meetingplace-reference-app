import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr_code_picker_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class QrCodePickerState with _$QrCodePickerState {
  factory QrCodePickerState({
    bool? isCameraAvailable,
    @Default(1.0) double baseScaleFactor,
    @Default(1.0) double scaleFactor,
  }) = _QrCodePickerState;
}
