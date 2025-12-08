// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// A fake ImagePicker that returns mock image data for testing.
///
/// This allows tests to simulate image picking without requiring
/// actual camera/gallery access.
class FakeImagePicker extends ImagePicker {
  FakeImagePicker({
    XFile? xFileToReturn,
    bool shouldReturnNull = false,
  })  : _xFileToReturn = xFileToReturn,
        _shouldReturnNull = shouldReturnNull;

  /// Creates a default fake image picker with a 1x1 red pixel PNG.
  factory FakeImagePicker.withDefaultImage() {
    return FakeImagePicker(xFileToReturn: XFile.fromData(defaultImageBytes));
  }

  /// A minimal 1x1 red pixel PNG image as bytes.
  /// This can be reused for testing camera and image picker functionality.
  static final Uint8List defaultImageBytes = Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    2,
    0,
    0,
    0,
    144,
    119,
    83,
    222,
    0,
    0,
    0,
    12,
    73,
    68,
    65,
    84,
    8,
    215,
    99,
    248,
    207,
    192,
    0,
    0,
    3,
    1,
    1,
    0,
    24,
    221,
    141,
    176,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130
  ]);

  final XFile? _xFileToReturn;
  final bool _shouldReturnNull;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = false,
  }) async {
    if (_shouldReturnNull) {
      return null;
    }

    return _xFileToReturn;
  }
}
