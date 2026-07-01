import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GestureDetector hit test behavior', () {
    testWidgets('HitTestBehavior.opaque captures taps on full widget area', (
      tester,
    ) async {
      var tappedCount = 0;

      final widget = MaterialApp(
        home: Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => tappedCount++,
            child: Container(color: Colors.grey[900]),
          ),
        ),
      );

      await tester.pumpWidget(widget);

      // Tap anywhere on the body — should be captured by GestureDetector
      await tester.tap(find.byType(GestureDetector));
      expect(tappedCount, equals(1));

      // Tap again
      await tester.tap(find.byType(GestureDetector));
      expect(tappedCount, equals(2));
    });

    testWidgets(
      'HitTestBehavior.opaque captures taps even with zero-size child',
      (tester) async {
        var tappedCount = 0;

        final widget = MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => tappedCount++,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        );

        await tester.pumpWidget(widget);

        // Tap center of the screen — should be captured by GestureDetector
        // with HitTestBehavior.opaque even though child is zero-size
        await tester.tap(find.byType(Scaffold));
        expect(tappedCount, equals(1));
      },
    );

    testWidgets(
      'HitTestBehavior.deferToChild (default) misses taps on zero-size child',
      (tester) async {
        var tappedCount = 0;

        final widget = MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              // No behavior set: defaults to HitTestBehavior.deferToChild
              onTap: () => tappedCount++,
              child: const SizedBox.shrink(),
            ),
          ),
        );

        await tester.pumpWidget(widget);

        // Try to tap the GestureDetector — tap will not reach it because
        // deferToChild delegates to the zero-size child which has no hit area
        await tester.tap(find.byType(GestureDetector), warnIfMissed: false);
        expect(tappedCount, equals(0));
      },
    );
  });
}
