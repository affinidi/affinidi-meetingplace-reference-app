import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../presentation/screens/media/image_view_screen/image_view_screen.dart';
import 'attachment_plugin_cache.dart';

class ImageAttachmentWidget extends StatefulWidget {
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
  Future<Uint8List>? _imageFuture;
  Uint8List? _resolvedImageBytes;
  late String _attachmentKey;

  Future<Uint8List> _loadImageBytes(
    ChatAttachment attachment,
    Future<Uint8List> Function(ChatAttachment) downloadFn,
  ) async {
    return downloadAndCacheAttachmentBytes(
      cacheManager: widget.cacheManager,
      cacheKey: widget.cacheKey,
      download: () => downloadFn(attachment),
    );
  }

  String _attachmentIdentityKey(ChatAttachment attachment) {
    final id = attachment.id;
    if (id != null && id.isNotEmpty) return 'id:$id';

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

  @override
  void initState() {
    super.initState();
    _attachmentKey = _attachmentIdentityKey(widget.attachment);
    _imageFuture = _createImageFuture();
  }

  @override
  void didUpdateWidget(ImageAttachmentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextAttachmentKey = _attachmentIdentityKey(widget.attachment);
    final downloadAvailabilityChanged =
        (oldWidget.download == null) != (widget.download == null);
    final cacheKeyChanged = oldWidget.cacheKey != widget.cacheKey;
    if (_attachmentKey != nextAttachmentKey ||
        downloadAvailabilityChanged ||
        cacheKeyChanged) {
      _attachmentKey = nextAttachmentKey;
      _resolvedImageBytes = null;
      _imageFuture = _createImageFuture();
    }
  }

  Future<Uint8List>? _createImageFuture() {
    final imageDataBase64 = widget.attachment.data?.base64;
    if (imageDataBase64 != null) return null;

    final downloadFn = widget.download;
    if (downloadFn == null) return null;

    return _loadImageBytes(widget.attachment, downloadFn);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final imageDataBase64 = widget.attachment.data?.base64;
    if (imageDataBase64 != null) {
      try {
        return _ResolvedImage(base64Decode(imageDataBase64));
      } catch (_) {
        return const _ErrorImage();
      }
    }

    final resolvedImageBytes = _resolvedImageBytes;
    if (resolvedImageBytes != null) {
      return _ResolvedImage(resolvedImageBytes);
    }

    final imageFuture = _imageFuture;
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

        final imageBytes = snapshot.data!;
        _resolvedImageBytes ??= imageBytes;
        return _ResolvedImage(imageBytes);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
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
