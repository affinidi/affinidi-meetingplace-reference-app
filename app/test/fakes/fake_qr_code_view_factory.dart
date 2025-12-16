import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/qr_code_view_factory_provider.dart';

class FakeQrCodeViewFactory implements QrCodeViewFactory {
  @override
  Widget create(String data) {
    return Container(
      width: 200,
      height: 200,
      color: Colors.grey,
      child: const Center(
        child: Text('Fake QR Code'),
      ),
    );
  }

  @override
  Future<XFile> exportToXFile(String data) async {
    return XFile.fromData(
      Uint8List.fromList([0, 1, 2, 3]),
      mimeType: 'image/png',
      name: 'Meeting Place Invitation.png',
    );
  }
}
