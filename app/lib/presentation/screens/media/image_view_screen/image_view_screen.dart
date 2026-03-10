import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../navigation/navigator.dart';
import '../bottom_media_bar.dart';
import '../image_preview.dart';

class ImageViewScreen extends ConsumerStatefulWidget {
  const ImageViewScreen({super.key, required this.imageBytes});

  final Uint8List? imageBytes;

  @override
  ConsumerState<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends ConsumerState<ImageViewScreen> {
  Color _backgroundColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _analyzeImageBrightness();
  }

  Future<void> _analyzeImageBrightness() async {
    if (widget.imageBytes == null) return;

    try {
      final codec = await ui.instantiateImageCodec(widget.imageBytes!);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Sample the image at a lower resolution for performance
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return;

      final pixels = byteData.buffer.asUint8List();
      var totalBrightness = 0;
      var sampleCount = 0;

      for (var i = 0; i < pixels.length; i += 40) {
        final r = pixels[i];
        final g = pixels[i + 1];
        final b = pixels[i + 2];

        final brightness = 0.299 * r + 0.587 * g + 0.114 * b;
        totalBrightness += brightness.toInt();
        sampleCount++;
      }

      final avgBrightness = totalBrightness / sampleCount;

      if (mounted) {
        setState(() {
          _backgroundColor = avgBrightness < 128 ? Colors.white : Colors.black;
        });
      }
    } catch (e) {
      setState(() {
        _backgroundColor = Colors.black;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      bottomNavigationBar: BottomMediaBar(
        children: [
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
        ],
      ),
      body: ImagePreview(imageBytes: widget.imageBytes),
    );
  }
}
