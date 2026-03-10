import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class QrCodeView extends StatelessWidget {
  QrCodeView({super.key, required this.data, this.size});

  final String data;
  final double? size;
  final GlobalKey _qrKey = GlobalKey();

  /// Exports the QR code as an XFile (image file)
  Future<XFile> exportToXFile() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return XFile(
        filePath,
        mimeType: 'image/png',
        name: 'Meeting Place Invitation.png',
      );
    } catch (e) {
      throw Exception('Failed to export QR code: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _qrKey,
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size ?? context.qrScannerTheme.iconSize * 3,
        gapless: true,
        dataModuleStyle: QrDataModuleStyle(
          color: context.colorScheme.primary,
          dataModuleShape: QrDataModuleShape.circle,
        ),
        eyeStyle: QrEyeStyle(
          color: context.colorScheme.primary,
          eyeShape: QrEyeShape.circle,
        ),
      ),
    );
  }
}
