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

  Finder lines() => find.descendant(
    of: find.byType(HairlineGrid),
    matching: find.byType(ColoredBox),
  );

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

  testWidgets('draws no line around a single item', (tester) async {
    await pumpGrid(tester, HairlineGrid(columns: 2, children: cells(1)));

    expect(lines(), findsNothing);
  });

  testWidgets('rules only between items, leaving empty slots blank', (
    tester,
  ) async {
    await pumpGrid(tester, HairlineGrid(columns: 2, children: cells(3)));

    // One between the first two, one under the first row; none beside the
    // third item, which has no neighbour.
    expect(lines(), findsNWidgets(2));
    final third = tester.getSize(find.byKey(const Key('cell_2')));
    final first = tester.getSize(find.byKey(const Key('cell_0')));
    expect(third.height, first.height);
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

      final line = tester.widget<ColoredBox>(lines());
      expect(line.color, mc.gridLine);
    });
  }
}
