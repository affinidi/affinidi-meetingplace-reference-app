import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../infrastructure/media/image_picker/image_picker_provider.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../infrastructure/services/camera_service/camera_service.dart';
import '../../../../navigation/navigator.dart';
import 'media_screen.dart';
import 'media_screen_state.dart';

part 'media_screen_controller.g.dart';

@riverpod
class MediaScreenController extends _$MediaScreenController {
  late final AppLogger _logger = ref.read(appLoggerProvider);
  static const _logKey = 'MEDSCRCTRL';

  @override
  MediaScreenState build({
    required CameraLensDirection cameraLensDirection,
    required bool useCamera,
  }) {
    if (!useCamera) {
      Future(() => pickFromGallery(useChatSemantics: false));
      return MediaScreenState(isLoading: true);
    }

    ref.listen(
      cameraServiceProvider,
      (prev, next) {
        final becameAvailable =
            prev?.isAvailable != true && next.isAvailable == true;
        final permissionJustGranted =
            prev?.permissionGranted != true && next.permissionGranted == true;

        if (becameAvailable || permissionJustGranted) {
          _initializeMediaSource(
            isCameraAvailable: next.isAvailable ?? false,
            useCamera: useCamera,
            cameraLensDirection: cameraLensDirection,
          );
        }

        state = state.copyWith(
          cameraController: next.controller,
          isCameraAvailable: next.isAvailable ?? false,
          isFrontCamera: next.controller?.description.lensDirection ==
              CameraLensDirection.front,
          isLoading: false,
          permissionGranted: next.permissionGranted,
        );
      },
    );

    return MediaScreenState(isLoading: true);
  }

  Future<void> pickFromGallery({
    required bool useChatSemantics,
  }) async {
    state = state.copyWith(isLoading: true);
    final picker = ref.read(imagePickerProvider);

    final environment = ref.read(environmentProvider);
    final imageConfig = useChatSemantics
        ? environment.chatImageConfig
        : environment.profileImageConfig;

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: imageConfig.imageMaxSize.toDouble(),
      maxWidth: imageConfig.imageMaxSize.toDouble(),
      imageQuality: imageConfig.qualityPercentage,
    );

    state = state.copyWith(isLoading: false);

    if (picked != null) {
      state = state.copyWith(pickedImageBytes: await picked.readAsBytes());
    } else {
      final navigator = ref.read(navigatorProvider);
      if (state.cameraController != null) {
        await closeCamera();
      }
      navigator.pop(MediaReviewResult.empty());
    }
  }

  Future<void> captureWithCamera() async {
    final file = await ref.read(cameraServiceProvider.notifier).captureImage();
    if (file != null) {
      state = state.copyWith(pickedImageBytes: await file.readAsBytes());
    }
  }

  Future<void> toggleCamera() async {
    state = state.copyWith(isLoading: true);
    await ref.read(cameraServiceProvider.notifier).toggleCamera();
    final current = ref.read(cameraServiceProvider).controller;
    if (current != null) {
      state = state.copyWith(
        cameraController: current,
        isFrontCamera:
            current.description.lensDirection == CameraLensDirection.front,
        isCameraAvailable: true,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  Future<void> closeCamera() async {
    await ref.read(cameraServiceProvider.notifier).closeCamera();
    state = state.copyWith(cameraController: null, isCameraAvailable: false);
  }

  void _initializeMediaSource({
    required bool isCameraAvailable,
    required bool useCamera,
    required CameraLensDirection cameraLensDirection,
  }) {
    if (isCameraAvailable && useCamera) {
      unawaited(_initCamera(cameraLensDirection));
    } else {
      unawaited(
        pickFromGallery(
          useChatSemantics: false,
        ),
      );
    }
  }

  Future<void> _initCamera(CameraLensDirection direction) async {
    try {
      state = state.copyWith(isLoading: true);
      final controller = await ref
          .read(cameraServiceProvider.notifier)
          .initializeCamera(direction);

      state = state.copyWith(
        cameraController: controller,
        isCameraAvailable: true,
        isFrontCamera: direction == CameraLensDirection.front,
        isLoading: false,
      );

      ref.onDispose(controller.dispose);
    } catch (error, stackTrace) {
      _logger.error(
        'Error initializing camera',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      state = state.copyWith(
        isCameraAvailable: false,
        isLoading: false,
      );
    }
  }

  /// Retries camera initialization when permission was previously denied.
  Future<void> retryInitCamera(CameraLensDirection direction) async {
    _logger.info('Retrying camera initialization', name: _logKey);
    await _initCamera(direction);
  }

  /// Opens the app settings for the user to grant camera permission.
  Future<void> openSettings() async {
    _logger.info('Opening app settings for camera permission', name: _logKey);
    await openAppSettings();
  }
}
