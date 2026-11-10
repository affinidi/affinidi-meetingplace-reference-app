import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/qr/qr_code_view.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('draws the code at error correction M', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: QrCodeView(data: 'hello', size: 100)),
      ),
    );

    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.errorCorrectionLevel, QrErrorCorrectLevel.M);
  });
}
