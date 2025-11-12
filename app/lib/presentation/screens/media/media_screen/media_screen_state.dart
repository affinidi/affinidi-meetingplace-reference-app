import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class MediaScreenState with _$MediaScreenState {
  MediaScreenState._();

  factory MediaScreenState({
    Uint8List? pickedImageBytes,
    @Default(false) bool isCameraAvailable,
    CameraController? cameraController,
    @Default(false) bool isFrontCamera,
  }) = _MediaScreenState;
}
