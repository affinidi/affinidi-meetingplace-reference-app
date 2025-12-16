import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../presentation/widgets/qr/qr_code_view.dart';

abstract class QrCodeViewFactory {
  Widget create(String data);
  Future<XFile> exportToXFile(String data);
}

class DefaultQrCodeViewFactory implements QrCodeViewFactory {
  final Map<String, QrCodeView> _instances = {};

  @override
  Widget create(String data) {
    final view = QrCodeView(data: data);
    _instances[data] = view;
    return view;
  }

  @override
  Future<XFile> exportToXFile(String data) {
    final view = _instances[data];
    if (view == null) {
      throw Exception('QrCodeView not created for data: $data');
    }
    return view.exportToXFile();
  }
}

final qrCodeViewFactoryProvider = Provider<QrCodeViewFactory>((ref) {
  return DefaultQrCodeViewFactory();
});
