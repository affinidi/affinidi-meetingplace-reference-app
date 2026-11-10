import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/onboarding_style/onboarding_style.dart';

void main() {
  Future<void> pumpMessage(
    WidgetTester tester, {
    required bool isError,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.dark,
        home: Scaffold(
          body: OnboardingMessage('Something went wrong', isError: isError),
        ),
      ),
    );
  }

  McColors colors(WidgetTester tester) => Theme.of(
    tester.element(find.byType(OnboardingMessage)),
  ).extension<McColors>()!;

  Iterable<BoxDecoration> decorations(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(OnboardingMessage),
          matching: find.byType(DecoratedBox),
        ),
      )
      .map((box) => box.decoration)
      .whereType<BoxDecoration>();

  group('an error', () {
    testWidgets('fills nothing and draws no box', (tester) async {
      await pumpMessage(tester, isError: true);

      for (final decoration in decorations(tester)) {
        expect(decoration.color, isNull);
        expect(decoration.border, isNull);
      }
    });

    testWidgets('sets the message in the danger text colour', (tester) async {
      await pumpMessage(tester, isError: true);

      final text = tester.widget<Text>(find.text('Something went wrong'));
      expect(text.style?.color, colors(tester).dangerText);
    });

    testWidgets('lights the bottom edge in the status colour', (tester) async {
      await pumpMessage(tester, isError: true);

      final line = find.byKey(const Key('edge_light_line'));
      final gradient =
          (tester.widget<DecoratedBox>(line).decoration as BoxDecoration)
                  .gradient!
              as LinearGradient;
      final bad = colors(tester).bad;
      expect(gradient.colors.first.a, 0, reason: 'fades in');
      expect(gradient.colors.last.a, 0, reason: 'fades out');
      expect(gradient.colors, contains(bad));
      expect(
        tester.getBottomLeft(line).dy,
        tester.getBottomLeft(find.byType(OnboardingMessage)).dy,
      );
    });

    testWidgets('lets a light rise from the edge on dark only', (tester) async {
      bool hasGlow() =>
          decorations(tester).any((d) => d.gradient is RadialGradient);

      await pumpMessage(tester, isError: true);
      expect(hasGlow(), isTrue);

      await pumpMessage(tester, isError: true, theme: AppTheme.light);
      // The app animates a change of theme.
      await tester.pumpAndSettle();
      expect(hasGlow(), isFalse);
    });
  });

  testWidgets('keeps a message that is no error in a panel', (tester) async {
    await pumpMessage(tester, isError: false);

    expect(find.byKey(const Key('edge_light_line')), findsNothing);
    expect(decorations(tester).any((d) => d.border != null), isTrue);
  });
}
