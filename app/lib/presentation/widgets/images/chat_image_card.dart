import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../screens/media/image_view_screen/image_view_screen.dart';
import '../../themes/tokens/mc_radius.dart';

/// A tappable 200×200 image card for chat attachments.
///
/// Displays the given image bytes as a cover-fit image inside a rounded,
/// elevated card. Tapping opens the image full-screen in [ImageViewScreen].
class ChatImageCard extends StatelessWidget {
  const ChatImageCard({super.key, required this._imageBytes});

  final Uint8List _imageBytes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute<void>(
              builder: (context) => ImageViewScreen(imageBytes: _imageBytes),
            ),
          );
        },
        child: Card(
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(McRadius.md),
          ),
          elevation: 0,
          child: Image.memory(_imageBytes, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
