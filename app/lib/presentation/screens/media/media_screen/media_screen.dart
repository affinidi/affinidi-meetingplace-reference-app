import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart' hide Navigator;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../navigation/navigator.dart' hide Navigator;
import '../../../widgets/camera_permission_instruction.dart';
import '../../../widgets/images/compressed_image.dart';
import '../frosted_media_icon_button.dart';
import '../media_review_screen/media_review_screen.dart';
import 'media_screen_controller.dart';

class MediaReviewResult {
  MediaReviewResult.empty()
    : compressedImage = CompressedImage.empty(),
      videoBase64 = null,
      videoMimeType = null,
      videoFilename = null,
      videoByteCount = null,
      textMessage = '',
      succeeded = false;

  MediaReviewResult(this.succeeded, this.textMessage, this.compressedImage)
    : videoBase64 = null,
      videoMimeType = null,
      videoFilename = null,
      videoByteCount = null;

  MediaReviewResult.video({
    required this.textMessage,
    required this.videoBase64,
    required this.videoMimeType,
    required this.videoFilename,
    required this.videoByteCount,
  }) : succeeded = true,
       compressedImage = CompressedImage.empty();

  final bool succeeded;
  final CompressedImage compressedImage;
  final String textMessage;
  final String? videoBase64;
  final String? videoMimeType;
  final String? videoFilename;
  final int? videoByteCount;
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
      useChatSemantics: useChatSemantics,
    );
    final controller = ref.read(mediaScreenProvider.notifier);

    await controller.pickFromGallery();
  }

  void _captureImage(
    MediaScreenController controller,
    BuildContext context,
    WidgetRef ref,
  ) async {
    await controller.captureWithCamera();
  }

  void _reviewImage(
    Uint8List imageBytes,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final navigator = ref.read(navigatorProvider);
    final result = await Navigator.of(context, rootNavigator: true)
        .push<MediaReviewResult>(
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
      useChatSemantics: useChatSemantics,
    );
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    useEffect(() {
      if (!useCamera) {
        return null;
      }

      return () {
        scheduleMicrotask(() {
          unawaited(controller.closeCamera());
        });
      };
    }, [controller, useCamera]);

    useEffect(() {
      if (state.pickedImageBytes != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          _reviewImage(state.pickedImageBytes!, ref, context);
        });
      }
      return null;
    }, [state.pickedImageBytes]);

    useEffect(() {
      final maxMb = state.videoTooLargeMaxMb;
      if (maxMb != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.attachmentTooLarge(maxMb))),
          );
          navigator.pop(MediaReviewResult.empty());
        });
      }
      return null;
    }, [state.videoTooLargeMaxMb]);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Builder(
        builder: (context) {
          if (state.isLoading || !useCamera) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (!state.permissionGranted && !state.isLoading) {
            final controller = ref.read(
              mediaScreenControllerProvider(
                cameraLensDirection: cameraLensDirection,
                useCamera: true,
                useChatSemantics: useChatSemantics,
              ).notifier,
            );
            return CameraPermissionInstruction(
              onOpenSettings: controller.openSettings,
              onRetry: () => controller.retryInitCamera(cameraLensDirection),
              onCancel: () {
                navigator.pop(MediaReviewResult.empty());
                Future(controller.closeCamera);
              },
            );
          }

          if (state.cameraController == null || !state.isCameraAvailable) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final camController = state.cameraController!;
          final size = MediaQuery.of(context).size;
          final l10n = AppLocalizations.of(context);
          final closeTooltip =
              l10n?.generalClose ??
              MaterialLocalizations.of(context).closeButtonTooltip;
          final galleryTooltip = l10n?.chooseFromGallery ?? 'Gallery';
          final cameraTooltip = l10n?.generalCamera ?? 'Camera';
          final switchCameraTooltip = l10n?.generalCamera ?? 'Switch camera';

          return Stack(
            fit: StackFit.expand,
            children: [
              SizedBox(
                width: size.width,
                height: size.height,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: 100,
                    child:
                        defaultTargetPlatform == TargetPlatform.android &&
                            state.isFrontCamera
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi),
                            child: CameraPreview(camController),
                          )
                        : CameraPreview(camController),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FrostedMediaIconButton(
                      tooltip: closeTooltip,
                      icon: Icons.close_rounded,
                      onPressed: () {
                        navigator.pop(MediaReviewResult.empty());
                        Future(controller.closeCamera);
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FrostedMediaIconButton(
                          tooltip: galleryTooltip,
                          icon: Icons.photo_library_rounded,
                          onPressed: () => _pickImage(ref, context),
                        ),
                        _CameraCaptureButton(
                          tooltip: cameraTooltip,
                          onPressed: () =>
                              _captureImage(controller, context, ref),
                        ),
                        FrostedMediaIconButton(
                          tooltip: switchCameraTooltip,
                          icon: CupertinoIcons.switch_camera,
                          onPressed: () async => controller.toggleCamera(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CameraCaptureButton extends StatelessWidget {
  const _CameraCaptureButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        child: GestureDetector(
          key: const Key('camera_capture_button'),
          onTap: onPressed,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: Colors.white.withValues(alpha: 0.22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
