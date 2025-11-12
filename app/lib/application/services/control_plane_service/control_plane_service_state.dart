import 'package:freezed_annotation/freezed_annotation.dart';

part 'control_plane_service_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ControlPlaneServiceState with _$ControlPlaneServiceState {
  const factory ControlPlaneServiceState({
    @Default(false) bool isProcessing,
    bool? isDeviceTokenRegistered,
  }) = _ControlPlaneServiceState;
}
