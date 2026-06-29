import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../navigation/navigator.dart';
import '../frosted_media_icon_button.dart';
import '../image_preview.dart';

class ImageViewScreen extends ConsumerStatefulWidget {
  const ImageViewScreen({super.key, required this.imageBytes});

  final Uint8List? imageBytes;

  @override
  ConsumerState<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends ConsumerState<ImageViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: ImagePreview(imageBytes: widget.imageBytes)),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: FrostedMediaIconButton(
                  icon: Icons.close_rounded,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  dimension: 46,
                  backgroundColor: Colors.black.withValues(alpha: 0.48),
                  onPressed: () {
                    final navigator = ref.read(navigatorProvider);
                    navigator.pop();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
