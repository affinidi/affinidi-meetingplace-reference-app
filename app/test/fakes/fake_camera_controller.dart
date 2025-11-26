import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

import 'fake_image_picker.dart';

/// A fake implementation of CameraController for testing.
///
/// This fake controller simulates camera behavior without requiring actual
/// camera hardware. It immediately completes initialization and returns
/// mock image data when takePicture() is called.
class FakeCameraController extends CameraController {
  FakeCameraController(
    super.description,
    super.resolutionPreset, {
    super.enableAudio,
    super.imageFormatGroup,
    this.mockImageBytes,
  });

  final Uint8List? mockImageBytes;

  @override
  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));

    value = value.copyWith(
      isInitialized: true,
      previewSize: const Size(1920, 1080),
    );
  }

  @override
  Future<XFile> takePicture() async {
    if (!value.isInitialized) {
      throw CameraException(
        'Uninitialized CameraController',
        'takePicture was called on an uninitialized CameraController',
      );
    }

    // Return mock image data
    final bytes = mockImageBytes ?? FakeImagePicker.defaultImageBytes;
    return XFile.fromData(
      bytes,
      mimeType: 'image/jpeg',
      name: 'test_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    value = value.copyWith(flashMode: mode);
  }
}
