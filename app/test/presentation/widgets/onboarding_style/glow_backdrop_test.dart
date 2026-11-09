import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';

void main() {
  Future<RadialGradient> pumpGlow(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const GlowBackdrop(child: SizedBox.expand()),
      ),
    );

    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(GlowBackdrop),
        matching: find.byType(DecoratedBox),
      ),
    );
    return (box.decoration as BoxDecoration).gradient! as RadialGradient;
  }

  testWidgets('rises from the bottom of the canvas', (tester) async {
    final glow = await pumpGlow(tester, const Size(400, 800));

    expect(glow.center, Alignment.bottomCenter);
    expect(glow.colors.last, AppTheme.dark.scaffoldBackgroundColor);
    expect(glow.radius, 2);
  });

  testWidgets('reaches further on a wide screen', (tester) async {
    final glow = await pumpGlow(tester, const Size(1280, 800));

    expect(glow.radius, 6);
  });
}
