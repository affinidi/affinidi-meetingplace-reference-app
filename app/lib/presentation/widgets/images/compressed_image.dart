import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// A container for compressed/encoded image results.
class CompressedImage {
  CompressedImage({
    required this.succeeded,
    required this.path,
    required this.base64,
    required this.bytes,
  });
  CompressedImage.empty() : path = '', bytes = Uint8List(0), base64 = '';
  String path;
  String base64;
  Uint8List bytes;
  bool succeeded = false;
}

/// Compress and resize from a file path
Future<CompressedImage> compressAndResizeImageFromFileAsBase64({
  required XFile image,
  required int imageSize,
  required int qualityPercent,
}) async {
  final bytes = await image.readAsBytes();
  final decoded = img.decodeImage(bytes);

  if (decoded == null) return CompressedImage.empty();

  final compressedBytes = _compressAndResize(
    image: decoded,
    imageSize: imageSize,
    qualityPercent: qualityPercent,
  );
  if (compressedBytes.isEmpty) return CompressedImage.empty();

  // Save the compressed image to a file
  final compressedFile = XFile.fromData(
    Uint8List.fromList(compressedBytes),
    mimeType: 'image/jpeg',
    name: image.name.replaceFirst(
      RegExp(r'\.(jpg|jpeg|png)$'),
      '_compressed.jpg',
    ),
  );

  return CompressedImage(
    succeeded: true,
    path: compressedFile.path,
    base64: base64Encode(compressedBytes),
    bytes: compressedBytes,
  );
}

Uint8List _compressAndResize({
  required img.Image image,
  required int imageSize,
  required int qualityPercent,
}) {
  int width, height;

  if (image.width > image.height) {
    width = imageSize;
    height = (image.height / image.width * imageSize).round();
  } else {
    height = imageSize;
    width = (image.width / image.height * imageSize).round();
  }

  var resized = img.copyResize(image, width: width, height: height);

  return Uint8List.fromList(img.encodeJpg(resized, quality: qualityPercent));
}
