// ignore_for_file: avoid_print

import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart' hide Navigator;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../navigation/navigator.dart' hide Navigator;
import '../../../widgets/images/compressed_image.dart';
import '../media_review_screen/media_review_screen.dart';
import 'media_screen_controller.dart';

class MediaReviewResult {
  MediaReviewResult.empty()
      : compressedImage = CompressedImage.empty(),
        textMessage = '',
        succeeded = false;

  MediaReviewResult(this.succeeded, this.textMessage, this.compressedImage);

  final bool succeeded;
  final CompressedImage compressedImage;
  final String textMessage;
}

class MediaScreen extends HookConsumerWidget {
  const MediaScreen({
    super.key,
    this.cameraLensDirection = CameraLensDirection.front,
    this.useCamera = true,
    this.useChatSemantics = false,
    this.messageText,
  });

  final CameraLensDirection cameraLensDirection;
  final bool useCamera;
  final bool useChatSemantics;
  final String? messageText;

  void _pickImage(WidgetRef ref, BuildContext context) async {
    final mediaScreenProvider = mediaScreenControllerProvider(
      cameraLensDirection: cameraLensDirection,
      useCamera: useCamera,
    );
    final controller = ref.read(mediaScreenProvider.notifier);

    await controller.pickFromGallery(
      useChatSemantics: useChatSemantics,
    );
  }

  void _captureImage(
    MediaScreenController controller,
    BuildContext context,
    WidgetRef ref,
  ) async {
    await controller.captureWithCamera();
  }

  void _reviewImage(
      Uint8List imageBytes, WidgetRef ref, BuildContext context) async {
    final navigator = ref.read(navigatorProvider);
    final result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<MediaReviewResult>(
      MaterialPageRoute(
        builder: (context) => MediaReviewScreen(
          useChatSemantics: useChatSemantics,
          imageBytes: imageBytes,
          messageText: messageText,
        ),
      ),
    );

    if (!context.mounted) return;

    navigator.pop(result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigator = ref.read(navigatorProvider);

    final provider = mediaScreenControllerProvider(
      cameraLensDirection: cameraLensDirection,
      useCamera: useCamera,
    );
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    useEffect(() {
      if (state.pickedImageBytes != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          _reviewImage(state.pickedImageBytes!, ref, context);
        });
      }
      return null;
    }, [state.pickedImageBytes]);

    return Scaffold(
      body: Builder(
        builder: (context) {
          final isCameraReady = state.isCameraAvailable &&
              state.cameraController != null &&
              state.cameraController!.value.isInitialized;

          if (!useCamera || !isCameraReady) {
            return const Center(child: CircularProgressIndicator());
          }

          final camController = state.cameraController!;
          final size = MediaQuery.of(context).size;

          return SizedBox(
            width: size.width,
            height: size.height,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: 100,
                child: defaultTargetPlatform == TargetPlatform.android &&
                        state.isFrontCamera
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: CameraPreview(camController),
                      )
                    : CameraPreview(camController),
              ),
            ),
          );
        },
      ),
      floatingActionButton: useCamera && state.isCameraAvailable
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Gallery
                FloatingActionButton(
                  heroTag: 1,
                  backgroundColor: Colors.purple,
                  onPressed: () => _pickImage(ref, context),
                  child: const Icon(Icons.photo_library,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),
                // Capture
                FloatingActionButton(
                  key: const Key('camera_capture_button'),
                  heroTag: 2,
                  backgroundColor: Colors.green,
                  onPressed: () => _captureImage(controller, context, ref),
                  child: const Icon(Icons.camera_alt,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Toggle camera
                FloatingActionButton(
                  heroTag: 3,
                  backgroundColor: Colors.blue,
                  onPressed: () async => controller.toggleCamera(),
                  child: const Icon(CupertinoIcons.switch_camera,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Cancel
                FloatingActionButton(
                  heroTag: 4,
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    await controller.closeCamera();
                    navigator.pop(MediaReviewResult.empty());
                  },
                  child:
                      const Icon(Icons.cancel, size: 50, color: Colors.white),
                ),
              ],
            )
          : null,
    );
  }
}
