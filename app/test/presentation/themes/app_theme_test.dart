import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/rounded_input_decoration.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_radius.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_typography.dart';

void main() {
  for (final (theme, mc, brightness) in [
    (AppTheme.dark, McColors.dark, Brightness.dark),
    (AppTheme.light, McColors.light, Brightness.light),
  ]) {
    group('AppTheme $brightness', () {
      test('sets type in Affinidi Sans on the mode canvas', () {
        expect(theme.brightness, brightness);
        expect(theme.textTheme.bodyLarge?.fontFamily, McTypography.fontFamily);
        expect(theme.textTheme.bodyLarge?.color, mc.textPrimary);
        expect(theme.scaffoldBackgroundColor, mc.canvas);
      });

      test('carries the mode tokens as extensions', () {
        expect(theme.extension<McColors>(), mc);
        expect(
          theme.extension<AppCustomColors>(),
          brightness == Brightness.dark
              ? AppCustomColors.dark
              : AppCustomColors.light,
        );
      });

      test('makes the primary button a solid blue pill', () {
        final style = theme.elevatedButtonTheme.style!;
        expect(style.shape?.resolve({}), isA<StadiumBorder>());
        expect(style.backgroundColor?.resolve({}), McColors.blue);
        expect(style.foregroundColor?.resolve({}), McColors.textOnPrimary);
      });

      test('never fills the navigation selection', () {
        expect(theme.navigationBarTheme.indicatorColor, Colors.transparent);
      });

      test('draws cards as hairline panels', () {
        final shape = theme.cardTheme.shape! as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(McRadius.lg));
        expect(shape.side.color, mc.hairline);
      });

      test('marks the selected filter with a line, not ink', () {
        expect(theme.tabBarTheme.splashFactory, NoSplash.splashFactory);
        expect(theme.tabBarTheme.indicatorSize, TabBarIndicatorSize.label);
        expect(
          theme.tabBarTheme.labelStyle,
          theme.tabBarTheme.unselectedLabelStyle,
        );
      });

      test('outlines chips with a hairline and no fill', () {
        expect(theme.chipTheme.backgroundColor, Colors.transparent);
        expect(theme.chipTheme.side?.color, mc.hairlineStrong);
      });

      test('centres list tile and text button labels on their icons', () {
        expect(
          theme.listTileTheme.titleTextStyle?.leadingDistribution,
          TextLeadingDistribution.even,
        );
        expect(
          theme.textButtonTheme.style?.textStyle
              ?.resolve({})
              ?.leadingDistribution,
          TextLeadingDistribution.even,
        );
      });

      test('rounds standalone fields to the input radius', () {
        final decoration = theme
            .extension<RoundedInputDecoration>()!
            .inputDecoration;
        final border = decoration.enabledBorder! as OutlineInputBorder;
        expect(border.borderRadius, BorderRadius.circular(McRadius.sm));
        expect(border.borderSide.color, mc.hairlineStrong);
      });
    });
  }
}
