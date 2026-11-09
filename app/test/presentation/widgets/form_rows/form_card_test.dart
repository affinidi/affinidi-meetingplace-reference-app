import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/common/app_card.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/form_rows/form_card.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/form_rows/form_row_text_field.dart';

void main() {
  testWidgets('keeps a hint off the bottom edge', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          // As on a screen: in a scroll view, the card wraps its rows.
          body: SingleChildScrollView(
            child: FormCard(
              title: 'Alias',
              child: FormRowTextField(
                color: Colors.blue,
                label: 'Alias',
                controller: controller,
                hint: 'Shown to people you connect with',
              ),
            ),
          ),
        ),
      ),
    );

    final card = tester.getRect(find.byType(AppCard));
    final hint = tester.getRect(find.text('Shown to people you connect with'));
    // The hint's own 4px plus the panel's 12px inset.
    expect(card.bottom - hint.bottom, greaterThanOrEqualTo(16));
  });
}
