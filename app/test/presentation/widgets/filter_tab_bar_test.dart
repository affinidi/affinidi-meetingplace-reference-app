import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/filter_tab_bar.dart';

void main() {
  Future<List<int>> pumpFilters(WidgetTester tester) async {
    final selected = <int>[];
    final controller = TabController(length: 3, vsync: tester);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: FilterTabBar(
            controller: controller,
            labels: const ['All', 'Pending', 'Approved'],
            onSelected: selected.add,
          ),
        ),
      ),
    );
    return selected;
  }

  Color labelColor(WidgetTester tester, String label) =>
      DefaultTextStyle.of(tester.element(find.text(label))).style.color!;

  testWidgets('shows plain labels, the selected one bright', (tester) async {
    await pumpFilters(tester);

    expect(labelColor(tester, 'All'), McColors.dark.textPrimary);
    expect(labelColor(tester, 'Pending'), McColors.dark.textSecondary);
    expect(
      find.descendant(
        of: find.byType(Tab),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
  });

  testWidgets('tells which filter was chosen', (tester) async {
    final selected = await pumpFilters(tester);

    await tester.tap(find.text('Approved'));
    await tester.pumpAndSettle();

    expect(selected, [2]);
    expect(labelColor(tester, 'Approved'), McColors.dark.textPrimary);
  });

  testWidgets('starts in line with the page gutter', (tester) async {
    await pumpFilters(tester);

    expect(tester.getTopLeft(find.text('All')).dx, 16);
  });
}
