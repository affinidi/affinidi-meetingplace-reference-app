import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/camera_service/camera_service_state.dart';

/// A fake implementation of camera service for testing purposes.
///
/// This class provides mock camera functionality without requiring actual
/// hardware or platform-specific camera access.
///
/// Unlike the real CameraService, this is a plain class that can be
/// instantiated directly in tests without Riverpod's build system.
class FakeCameraService {
  FakeCameraService({
    this.mockImageBytes,
    bool isAvailable = true,
    List<CameraDescription>? mockCameras,
  })  : _mockCameras = mockCameras ?? _defaultMockCameras,
        state = CameraServiceState(
          cameras: mockCameras ?? _defaultMockCameras,
          isAvailable: isAvailable,
        );

  /// The current state of the camera service.
  CameraServiceState state;

  /// Optional mock image bytes to return when capturing an image.
  final Uint8List? mockImageBytes;

  /// Mock cameras available for testing.
  final List<CameraDescription> _mockCameras;

  /// Default mock cameras (front and back).
  static final List<CameraDescription> _defaultMockCameras = [
    const CameraDescription(
      name: 'Mock Front Camera',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 90,
    ),
    const CameraDescription(
      name: 'Mock Back Camera',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    ),
  ];

  Future<CameraController> initializeCamera(
      CameraLensDirection cameraLensDirection) async {
    final description = _mockCameras.firstWhere(
      (c) => c.lensDirection == cameraLensDirection,
      orElse: () => throw Exception(
          'No mock camera found for $cameraLensDirection direction'),
    );

    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    state = state.copyWith(
      controller: controller,
      cameras: _mockCameras,
      isAvailable: true,
    );

    return controller;
  }

  Future<void> toggleCamera() async {
    if (state.controller == null) return;

    final lens = state.controller!.description.lensDirection;

    final newCamera = lens == CameraLensDirection.front
        ? _mockCameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => _mockCameras.first,
          )
        : _mockCameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => _mockCameras.first,
          );

    await closeCamera();
    await initializeCamera(newCamera.lensDirection);
  }

  Future<void> closeCamera() async {
    final controller = state.controller;
    state = state.copyWith(controller: null);

    // Don't actually dispose the controller as it was never initialized
    await controller?.dispose();
  }

  Future<XFile?> captureImage() async {
    if (state.controller == null) return null;

    // Return mock image data if provided
    if (mockImageBytes != null) {
      return XFile.fromData(
        mockImageBytes!,
        mimeType: 'image/png',
        name: 'mock_capture_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    }

    return null;
  }
}

/// A Riverpod Notifier wrapper for [FakeCameraService].
///
/// This wrapper allows the plain [FakeCameraService] to be used with
/// Riverpod's provider system by delegating all calls to the fake service
/// and syncing the state.
class FakeCameraServiceNotifier extends CameraService {
  FakeCameraServiceNotifier(this._fakeService);

  final FakeCameraService _fakeService;

  @override
  CameraServiceState build() {
    return _fakeService.state;
  }

  @override
  Future<CameraController> initializeCamera(
      CameraLensDirection cameraLensDirection) async {
    final controller =
        await _fakeService.initializeCamera(cameraLensDirection);
    state = _fakeService.state;
    return controller;
  }

  @override
  Future<void> toggleCamera() async {
    await _fakeService.toggleCamera();
    state = _fakeService.state;
  }

  @override
  Future<void> closeCamera() async {
    await _fakeService.closeCamera();
    state = _fakeService.state;
  }

  @override
  Future<XFile?> captureImage() async {
    return await _fakeService.captureImage();
  }
}
