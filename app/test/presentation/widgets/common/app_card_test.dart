import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/common/app_card.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    AppCard card, {
    ThemeData? theme,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.dark,
      home: Scaffold(body: Center(child: card)),
    ),
  );

  testWidgets('responds to taps across the whole panel', (tester) async {
    var taps = 0;
    var longPresses = 0;
    await pumpCard(
      tester,
      AppCard(
        onTap: () => taps++,
        onLongPress: () => longPresses++,
        padding: const EdgeInsets.all(16),
        child: const Text('Alice'),
      ),
    );

    await tester.tap(find.byType(AppCard));
    await tester.longPress(find.byType(AppCard));

    expect(taps, 1);
    expect(longPresses, 1);
  });

  testWidgets('stays a plain panel without callbacks', (tester) async {
    await pumpCard(tester, const AppCard(child: Text('Alice')));

    expect(find.byType(InkWell), findsNothing);
  });

  for (final (name, theme, mc) in [
    ('dark', AppTheme.dark, McColors.dark),
    ('light', AppTheme.light, McColors.light),
  ]) {
    testWidgets('draws the $name lit top edge', (tester) async {
      await pumpCard(tester, const AppCard(child: Text('Alice')), theme: theme);

      final edge = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.position == DecorationPosition.foreground,
          ),
        ),
      );
      final border = (edge.decoration as BoxDecoration).border! as Border;
      expect(border.top.color, mc.insetTop);
    });
  }

  RadialGradient? washOf(WidgetTester tester) {
    final boxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(AppCard),
        matching: find.byType(DecoratedBox),
      ),
    );
    return boxes
        .map((box) => (box.decoration as BoxDecoration).gradient)
        .whereType<RadialGradient>()
        .firstOrNull;
  }

  testWidgets('carries an accent as a top-right corner wash', (tester) async {
    const accent = Color(0xFF10B94E);
    await pumpCard(tester, const AppCard(accent: accent, child: Text('Alice')));

    final wash = washOf(tester)!;
    expect(wash.center, Alignment.topRight);
    expect(wash.colors.first, accent.withValues(alpha: 0.16));
    expect(wash.colors.last.a, 0);
  });

  testWidgets('has no wash without an accent', (tester) async {
    await pumpCard(tester, const AppCard(child: Text('Alice')));

    expect(washOf(tester), isNull);
  });
}
