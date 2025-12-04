// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../infrastructure/configuration/image_config.dart';
import '../../../widgets/images/compressed_image.dart';
import '../media_screen/media_screen.dart';

part 'media_review_controller.g.dart';

@riverpod
class MediaReviewController extends _$MediaReviewController {
  @override
  void build() {}

  /// Compress image and return review result
  Future<MediaReviewResult> submitResult({
    required Uint8List bytes,
    required bool success,
    required String message,
    required ImageConfig imageConfig,
  }) async {
    if (!success) return MediaReviewResult.empty();
    try {
      final file = XFile.fromData(
        bytes,
        name: 'image.png',
        mimeType: 'image/png',
      );

      final compressedImage = await compressAndResizeImageFromFileAsBase64(
        image: file,
        imageSize: imageConfig.imageMaxSize,
        qualityPercent: imageConfig.qualityPercentage,
      );

      print('XXX: Compressed image size: ${compressedImage.base64.length}');

      return MediaReviewResult(success, message, compressedImage);
    } catch (_) {
      return MediaReviewResult.empty();
    }
  }
}
