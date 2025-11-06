import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../navigation/navigator.dart';
import '../bottom_media_bar.dart';
import '../image_preview.dart';

class ImageViewScreen extends ConsumerWidget {
  const ImageViewScreen({
    super.key,
    required this.imageBytes,
  });

  final Uint8List? imageBytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomMediaBar(children: [
        const Spacer(),
        FloatingActionButton(
          heroTag: 'close',
          backgroundColor: Colors.red,
          onPressed: () {
            final navigator = ref.read(navigatorProvider);
            navigator.pop();
          },
          child: const Icon(Icons.close, size: 35, color: Colors.white),
        ),
      ]),
      body: ImagePreview(
        imageBytes: imageBytes,
      ),
    );
  }
}
