import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FakeQrCodeView extends StatelessWidget {
  const FakeQrCodeView({
    super.key,
    required this.data,
    this.size,
  });

  final String data;
  final double? size;

  Future<XFile> exportToXFile() async {
    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/fake_qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes([0, 1, 2, 3]);

    return XFile(
      filePath,
      mimeType: 'image/png',
      name: 'Meeting Place Invitation.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? 200,
      height: size ?? 200,
      color: Colors.grey,
      child: const Center(
        child: Text('Fake QR Code'),
      ),
    );
  }
}
