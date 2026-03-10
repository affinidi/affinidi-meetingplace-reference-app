import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({required this.imageBytes});

  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context) {
    if (imageBytes == null) {
      return Center(child: Text(context.l10n.loadImageFailed));
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
