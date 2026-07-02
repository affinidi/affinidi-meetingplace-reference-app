import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../presentation/screens/media/image_view_screen/image_view_screen.dart';
import 'attachment_plugin_cache.dart';

class ImageAttachmentWidget extends StatefulHookWidget {
  const ImageAttachmentWidget({
    super.key,
    required this.attachment,
    required this.cacheManager,
    required this.cacheKey,
    this.download,
  });

  final ChatAttachment attachment;
  final BaseCacheManager cacheManager;
  final String cacheKey;
  final Future<Uint8List> Function(ChatAttachment)? download;

  @override
  State<ImageAttachmentWidget> createState() => _ImageAttachmentWidgetState();
}

class _ImageAttachmentWidgetState extends State<ImageAttachmentWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final attachmentKey = _attachmentIdentityKey(widget.attachment);
    final downloadAvailable = widget.download != null;
    final inlineImageBytes = useMemoized(
      () => _resolveInlineImageBytes(widget.attachment),
      [attachmentKey, widget.attachment.data?.base64],
    );

    final imageFuture = useMemoized(
      () => _createImageFuture(
        attachment: widget.attachment,
        cacheManager: widget.cacheManager,
        cacheKey: widget.cacheKey,
        download: widget.download,
      ),
      [attachmentKey, widget.cacheKey, downloadAvailable],
    );

    if (widget.attachment.data?.base64 != null) {
      if (inlineImageBytes == null || inlineImageBytes.isEmpty) {
        return const _ErrorImage();
      }

      return _ResolvedImage(inlineImageBytes);
    }

    if (imageFuture == null) return const SizedBox.shrink();

    return FutureBuilder<Uint8List>(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingImage();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const _ErrorImage();
        }

        return _ResolvedImage(snapshot.data!);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

Future<Uint8List> _loadImageBytes({
  required ChatAttachment attachment,
  required BaseCacheManager cacheManager,
  required String cacheKey,
  required Future<Uint8List> Function(ChatAttachment) download,
}) async {
  return cacheManager.downloadBytes(
    cacheKey: cacheKey,
    download: () => download(attachment),
  );
}

String _attachmentIdentityKey(ChatAttachment attachment) {
  final id = attachment.id;
  if (id.isNotEmpty) return 'id:$id';

  final transportId = attachment.transportId;
  if (transportId != null && transportId.isNotEmpty) {
    return 'transport:$transportId';
  }

  final link = attachment.data?.links?.firstOrNull?.toString();
  if (link != null && link.isNotEmpty) return 'link:$link';

  final base64Data = attachment.data?.base64;
  if (base64Data != null && base64Data.isNotEmpty) {
    return 'base64:${base64Data.hashCode}';
  }

  return 'attachment:${identityHashCode(attachment)}';
}

Future<Uint8List>? _createImageFuture({
  required ChatAttachment attachment,
  required BaseCacheManager cacheManager,
  required String cacheKey,
  required Future<Uint8List> Function(ChatAttachment)? download,
}) {
  final imageDataBase64 = attachment.data?.base64;
  if (imageDataBase64 != null) return null;

  final downloadFn = download;
  if (downloadFn == null) return null;

  return _loadImageBytes(
    attachment: attachment,
    cacheManager: cacheManager,
    cacheKey: cacheKey,
    download: downloadFn,
  );
}

Uint8List? _resolveInlineImageBytes(ChatAttachment attachment) {
  final imageDataBase64 = attachment.data?.base64;
  if (imageDataBase64 == null || imageDataBase64.isEmpty) {
    return null;
  }

  try {
    return base64Decode(imageDataBase64);
  } catch (_) {
    return null;
  }
}

class _LoadingImage extends StatelessWidget {
  const _LoadingImage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      width: 200,
      child: Card(
        color: Color.fromARGB(0, 10, 10, 10),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        elevation: 5,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Color.fromARGB(255, 36, 42, 56)),
          child: Center(
            child: Icon(Icons.image_outlined, size: 36, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      width: 200,
      child: Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}

class _ResolvedImage extends StatelessWidget {
  const _ResolvedImage(this.imageBytes);

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<ImageViewScreen>(
            MaterialPageRoute(
              builder: (context) => ImageViewScreen(imageBytes: imageBytes),
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
          child: Image(fit: BoxFit.cover, image: MemoryImage(imageBytes)),
        ),
      ),
    );
  }
}
