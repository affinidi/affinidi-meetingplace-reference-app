import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/common/app_card.dart';

void main() {
  Future<void> pumpCard(WidgetTester tester, AppCard card) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
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
}
