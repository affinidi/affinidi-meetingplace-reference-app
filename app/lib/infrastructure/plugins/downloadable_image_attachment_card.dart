import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../presentation/painting/cached_base64_image.dart';
import '../../presentation/screens/media/image_view_screen/image_view_screen.dart';
import '../../presentation/widgets/async_loaders/async_loading_controller.dart';
import '../../presentation/widgets/async_loaders/inline_async_loading_status.dart';

class DownloadableImageAttachmentCard extends HookConsumerWidget {
  const DownloadableImageAttachmentCard({
    super.key,
    required Attachment attachment,
    required BaseCacheManager cacheManager,
    Future<void> Function(Attachment attachment)? onDownloadAttachment,
  }) : _attachment = attachment,
       _cacheManager = cacheManager,
       _onDownloadAttachment = onDownloadAttachment;

  final Attachment _attachment;
  final BaseCacheManager _cacheManager;
  final Future<void> Function(Attachment attachment)? _onDownloadAttachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadControllerProvider = useMemoized(
      () => AsyncLoadingController.provider(
        'download_attachment_${_attachment.id ?? _attachment.hashCode}',
      ),
      [_attachment.id, _attachment.hashCode],
    );
    final imageDataBase64 = _attachment.data?.base64;

    if (imageDataBase64 != null) {
      return _Base64ImageAttachmentCard(
        imageDataBase64: imageDataBase64,
        cacheManager: _cacheManager,
      );
    }

    final hasDownloadLink = _attachment.data?.links?.isNotEmpty == true;
    if (!hasDownloadLink) return const SizedBox.shrink();

    Future<void> onDownloadPressed() async {
      final onDownloadAttachment = _onDownloadAttachment;
      if (onDownloadAttachment == null) {
        return;
      }

      await ref
          .read(downloadControllerProvider.notifier)
          .start(() => onDownloadAttachment(_attachment));
    }

    return SizedBox(
      height: 200,
      width: 200,
      child: Card(
        color: const Color.fromARGB(0, 10, 10, 10),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _BlurredAttachmentPlaceholder(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _AttachmentDownloadOverlay(
                loadingControllerProvider: downloadControllerProvider,
                onDownloadPressed: _onDownloadAttachment == null
                    ? null
                    : onDownloadPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Base64ImageAttachmentCard extends StatelessWidget {
  const _Base64ImageAttachmentCard({
    required this.imageDataBase64,
    required this.cacheManager,
  });

  final String imageDataBase64;
  final BaseCacheManager cacheManager;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<ImageViewScreen>(
            MaterialPageRoute(
              builder: (context) =>
                  ImageViewScreen(imageBytes: base64.decode(imageDataBase64)),
            ),
          );
        },
        child: Card(
          color: const Color.fromARGB(0, 10, 10, 10),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: Image(
            fit: BoxFit.cover,
            image: CachedBase64Image(
              imageDataBase64,
              cacheManager: cacheManager,
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentDownloadOverlay extends StatelessWidget {
  const _AttachmentDownloadOverlay({
    required this.loadingControllerProvider,
    required this.onDownloadPressed,
  });

  final AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
  loadingControllerProvider;
  final Future<void> Function()? onDownloadPressed;

  @override
  Widget build(BuildContext context) {
    void onRetryPressed() {
      final onDownloadPressed = this.onDownloadPressed;
      if (onDownloadPressed == null) {
        return;
      }

      unawaited(onDownloadPressed());
    }

    return InlineAsyncLoadingStatus(
      loadingControllerProvider,
      retry: onDownloadPressed == null ? null : onRetryPressed,
      child: Center(
        child: IconButton.filledTonal(
          onPressed: onDownloadPressed,
          iconSize: 28,
          icon: const Icon(Icons.download_rounded),
        ),
      ),
    );
  }
}

class _BlurredAttachmentPlaceholder extends StatelessWidget {
  const _BlurredAttachmentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF364B63),
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF92A6BB), Color(0xFF223244)],
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.8, -0.8),
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0x40FFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.85, -0.45),
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0x30000000),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.image_outlined,
                size: 84,
                color: Color(0x35FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
