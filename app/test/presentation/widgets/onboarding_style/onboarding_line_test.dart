import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_join/vtc_detail_line.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';

void main() {
  Future<void> pumpLine(WidgetTester tester, Widget line) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(body: line),
      ),
    );
  }

  void expectIconCentredOnFirstLine(WidgetTester tester, String firstLine) {
    final icon = tester.getCenter(find.byType(Icon)).dy;
    final text = tester.getCenter(find.text(firstLine)).dy;
    expect(icon, moreOrLessEquals(text, epsilon: 0.5));
  }

  testWidgets('centres the icon on the title of a line', (tester) async {
    await pumpLine(
      tester,
      const OnboardingLine(
        icon: Icons.language,
        title: 'Website',
        subtitle: 'https://chess.example',
      ),
    );

    expectIconCentredOnFirstLine(tester, 'Website');
  });

  testWidgets('centres the icon on the label of a detail', (tester) async {
    await pumpLine(
      tester,
      const VtcDetailLine(
        icon: Icons.event,
        label: 'Valid from',
        value: '10 Nov 2026',
      ),
    );

    expectIconCentredOnFirstLine(tester, 'Valid from');
  });
}
