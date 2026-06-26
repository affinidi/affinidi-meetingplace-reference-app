import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({required this.imageBytes});

  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    if (imageBytes == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white70,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.loadImageFailed,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(imageBytes!, fit: BoxFit.contain),
        ),
      ],
    );
  }
}
