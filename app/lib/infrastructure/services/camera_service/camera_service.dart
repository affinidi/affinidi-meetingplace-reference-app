import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../loggers/app_logger/app_logger.dart';
import '../../providers/app_logger_provider.dart';
import '../permission_service/permission_service.dart';
import 'camera_service_state.dart';

part 'camera_service.g.dart';

final availableCamerasProvider =
    Provider<Future<List<CameraDescription>> Function()>(
      (ref) => availableCameras,
    );

typedef CameraControllerFactory =
    CameraController Function(
      CameraDescription description,
      ResolutionPreset resolutionPreset, {
      bool enableAudio,
      ImageFormatGroup? imageFormatGroup,
    });

final cameraControllerFactoryProvider = Provider<CameraControllerFactory>(
  (ref) =>
      (
        description,
        resolutionPreset, {
        enableAudio = true,
        imageFormatGroup,
      }) => CameraController(
        description,
        resolutionPreset,
        enableAudio: enableAudio,
        imageFormatGroup: imageFormatGroup,
      ),
);

/// A service class for managing camera functionality in the app.
///
/// - Manages camera initialization, switching between front/back lenses,
///   and capturing images.
/// - Observes the app lifecycle to recheck camera availability when resuming.
/// - Maintains camera state via [CameraServiceState].
@Riverpod(keepAlive: true)
class CameraService extends _$CameraService with WidgetsBindingObserver {
  CameraService() : super();

  late final AppLogger _logger = ref.read(appLoggerProvider);
  static const _logKey = 'CAMSVCS';

  @override
  CameraServiceState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      state.controller?.dispose();
    });

    Future(checkCameraAvailability);

    return CameraServiceState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future(checkCameraAvailability);
    }
  }

  /// Initializes the camera with the given [cameraLensDirection].
  ///
  /// [cameraLensDirection] - The lens direction (front or back) to use.
  ///
  /// Returns an initialized [CameraController].
  Future<CameraController> initializeCamera(
    CameraLensDirection cameraLensDirection,
  ) async {
    final getCameras = ref.read(availableCamerasProvider);
    final cameras = await getCameras();
    final description = cameras.firstWhere(
      (c) => c.lensDirection == cameraLensDirection,
      orElse: () =>
          throw Exception('No camera found for $cameraLensDirection direction'),
    );

    final controllerFactory = ref.read(cameraControllerFactoryProvider);
    final controller = controllerFactory(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await controller.initialize();

    state = state.copyWith(
      controller: controller,
      cameras: cameras,
      isAvailable: cameras.isNotEmpty,
      permissionGranted: true,
    );

    return controller;
  }

  /// Toggles between the front and back cameras.
  ///
  /// If no controller is active, the method does nothing.
  Future<void> toggleCamera() async {
    if (state.cameras.isEmpty) {
      await checkCameraAvailability();
    }

    if (state.controller == null || state.cameras.isEmpty) return;

    final lens = state.controller!.description.lensDirection;
    final cameras = state.cameras;

    final newCamera = lens == CameraLensDirection.front
        ? cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.first,
          )
        : cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );
    await closeCamera();
    await initializeCamera(newCamera.lensDirection);
  }

  /// Closes and disposes the current camera controller.
  ///
  /// Sets the controller in state to `null`.
  Future<void> closeCamera() async {
    final controller = state.controller;
    state = state.copyWith(controller: null);

    await controller?.dispose();
  }

  /// Captures an image from the active camera.
  ///
  /// Returns the captured [XFile], or `null` if capture failed or
  /// if no camera is active.
  /// On iOS front camera, the image is flipped horizontally.
  Future<XFile?> captureImage() async {
    if (state.controller == null) return null;

    try {
      await state.controller!.setFlashMode(FlashMode.off);
      final file = await state.controller!.takePicture();

      if (state.controller?.description.lensDirection ==
              CameraLensDirection.front &&
          defaultTargetPlatform == TargetPlatform.iOS) {
        return await _flipImage(file);
      }

      return file;
    } catch (e, st) {
      _logger.error(
        'captureImage failed',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
      return null;
    }
  }

  /// Flips the given image file horizontally.
  ///
  /// [file] - The captured image [XFile] to be flipped.
  ///
  /// Returns the flipped [XFile], or `null` if decoding failed.
  Future<XFile?> _flipImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final original = img.decodeImage(bytes);

    if (original == null) return null;

    final flipped = img.flipHorizontal(original);

    return XFile.fromData(
      img.encodeJpg(flipped),
      mimeType: 'image/jpeg',
      name: 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  /// Ensures camera is ready by checking permission and initializing if needed.
  ///
  /// Call this when user initiates a camera action (e.g., taps "Scan QR").
  /// Requests permission if not granted, then initializes the camera.
  ///
  /// Returns `true` if camera is ready, `false` if permission denied or error.
  Future<bool> ensureCameraReady({
    CameraLensDirection direction = CameraLensDirection.back,
  }) async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS) {
      _logger.warning('Camera not available on this platform', name: _logKey);
      return false;
    }

    final permissionService = ref.read(permissionServiceProvider);
    var status = await permissionService.getCameraPermissionStatus();

    if (status.isDenied) {
      status = await permissionService.requestCameraPermission();
    }

    if (!status.isGranted) {
      _logger.warning('Camera permission not granted', name: _logKey);
      state = state.copyWith(permissionGranted: false);
      return false;
    }

    try {
      await initializeCamera(direction);
      return true;
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to initialize camera',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return false;
    }
  }

  /// Checks whether cameras are available on the device and updates the state.
  ///
  /// Does NOT request permission. Only queries hardware availability.
  /// On macOS/web, sets isAvailable to false.
  Future<void> checkCameraAvailability() async {
    // Camera plugin does not support macOS: assume camera is unavailable
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS) {
      _logger.warning('Camera not available on this platform', name: _logKey);
      state = state.copyWith(isAvailable: false);
      return;
    }

    _logger.info('checkCameraAvailability', name: _logKey);

    try {
      final getCameras = ref.read(availableCamerasProvider);
      final cameras = await getCameras();
      state = state.copyWith(isAvailable: cameras.isNotEmpty, cameras: cameras);

      _logger.info('${cameras.length} camera(s) found', name: _logKey);
    } catch (error, stackTrace) {
      _logger.error(
        'Error while detecting cameras',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      state = state.copyWith(isAvailable: false, cameras: []);
    }
  }
}
