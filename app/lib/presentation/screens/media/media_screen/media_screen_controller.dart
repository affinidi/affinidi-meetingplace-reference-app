// ignore_for_file: avoid_print

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/media/image_picker/image_picker_provider.dart';
import '../../../../infrastructure/services/camera_service/camera_service.dart';
import '../../../../infrastructure/services/camera_service/camera_service_state.dart';
import '../../../../navigation/navigator.dart';
import 'media_screen.dart';
import 'media_screen_state.dart';

part 'media_screen_controller.g.dart';

@riverpod
class MediaScreenController extends _$MediaScreenController {
  @override
  MediaScreenState build({
    required CameraLensDirection cameraLensDirection,
    required bool useCamera,
  }) {
    final cameraState = ref.read(cameraServiceProvider);

    if (cameraState.isAvailable != null) {
      _handleAvailability(
          cameraState.isAvailable!, useCamera, cameraLensDirection);
    } else {
      ref.listen<CameraServiceState>(
        cameraServiceProvider,
        (prev, next) {
          if (prev?.isAvailable == null && next.isAvailable != null) {
            _handleAvailability(
                next.isAvailable!, useCamera, cameraLensDirection);
          }
        },
      );
    }

    return MediaScreenState();
  }

  Future<void> pickFromGallery({
    required bool useChatSemantics,
  }) async {
    print('XXX: MediaScreenController.pickFromGallery called');
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

    print('XXX: picked $picked');
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
    await ref.read(cameraServiceProvider.notifier).toggleCamera();
    final current = ref.read(cameraServiceProvider).controller;
    if (current != null) {
      state = state.copyWith(
          cameraController: current,
          isFrontCamera:
              current.description.lensDirection == CameraLensDirection.front,
          isCameraAvailable: true);
    }
  }

  Future<void> closeCamera() async {
    await ref.read(cameraServiceProvider.notifier).closeCamera();
    state = state.copyWith(cameraController: null);
  }

  void _handleAvailability(
    bool isAvailable,
    bool useCamera,
    CameraLensDirection cameraLensDirection,
  ) {
    if (!isAvailable || !useCamera) {
      unawaited(
        pickFromGallery(
          useChatSemantics: false,
        ),
      );
    } else {
      unawaited(_initCamera(cameraLensDirection));
    }
  }

  Future<void> _initCamera(CameraLensDirection direction) async {
    try {
      final controller = await ref
          .read(cameraServiceProvider.notifier)
          .initializeCamera(direction);

      state = state.copyWith(
        cameraController: controller,
        isCameraAvailable: true,
        isFrontCamera: direction == CameraLensDirection.front,
      );

      ref.onDispose(controller.dispose);
    } catch (_) {
      state = state.copyWith(isCameraAvailable: false);
    }
  }
}
