import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/common/hairline_grid.dart';

void main() {
  Future<void> pumpGrid(
    WidgetTester tester,
    HairlineGrid grid, {
    ThemeData? theme,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.dark,
      home: Scaffold(body: SingleChildScrollView(child: grid)),
    ),
  );

  List<Widget> cells(int count) => [
    for (var i = 0; i < count; i++) Text('Cell $i', key: Key('cell_$i')),
  ];

  testWidgets('lays the items out in rows of the given columns', (
    tester,
  ) async {
    await pumpGrid(tester, HairlineGrid(columns: 2, children: cells(4)));

    final first = tester.getTopLeft(find.byKey(const Key('cell_0')));
    final second = tester.getTopLeft(find.byKey(const Key('cell_1')));
    final third = tester.getTopLeft(find.byKey(const Key('cell_2')));
    expect(second.dy, first.dy);
    expect(second.dx, greaterThan(first.dx));
    expect(third.dx, first.dx);
    expect(third.dy, greaterThan(first.dy));
  });

  testWidgets('fills a short last row with empty cells', (tester) async {
    await pumpGrid(tester, HairlineGrid(columns: 2, children: cells(3)));

    // Two full rows of cells, each on the canvas.
    final cellMaterials = find.descendant(
      of: find.byType(HairlineGrid),
      matching: find.byType(Material),
    );
    expect(cellMaterials, findsNWidgets(4));
    final last = tester.getSize(cellMaterials.last);
    final first = tester.getSize(cellMaterials.first);
    expect(last, first);
  });

  testWidgets('makes every cell in a row as tall as the tallest', (
    tester,
  ) async {
    await pumpGrid(
      tester,
      const HairlineGrid(
        columns: 2,
        children: [
          SizedBox(key: Key('short'), height: 20),
          SizedBox(key: Key('tall'), height: 60),
        ],
      ),
    );

    final cellMaterials = find.descendant(
      of: find.byType(HairlineGrid),
      matching: find.byType(Material),
    );
    for (final element in cellMaterials.evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).height, 60);
    }
  });

  for (final (name, theme, mc) in [
    ('dark', AppTheme.dark, McColors.dark),
    ('light', AppTheme.light, McColors.light),
  ]) {
    testWidgets('rules the $name grid with the grid line', (tester) async {
      await pumpGrid(
        tester,
        HairlineGrid(columns: 2, children: cells(2)),
        theme: theme,
      );

      final line = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(HairlineGrid),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(line.color, mc.gridLine);
      final cell = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(HairlineGrid),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(cell.color, mc.canvas);
    });
  }
}
