import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'camera_service.dart';

part 'camera_service_state.freezed.dart';

/// State object for the [CameraService].
///
/// Holds the list of available cameras, the current controller,
/// and availability information.
@Freezed(fromJson: false, toJson: false)
abstract class CameraServiceState with _$CameraServiceState {
  /// Creates a new [CameraServiceState].
  ///
  /// [cameras] - List of available [CameraDescription]s.
  /// Defaults to an empty list.
  ///
  /// [isAvailable] - Whether the camera service is available.
  ///
  /// [controller] - The currently active [CameraController], if any.
  factory CameraServiceState({
    @Default([]) List<CameraDescription> cameras,
    bool? isAvailable,
    CameraController? controller,
  }) = _CameraServiceState;
}
