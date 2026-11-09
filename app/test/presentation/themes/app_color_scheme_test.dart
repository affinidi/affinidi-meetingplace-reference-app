import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_color_scheme.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/tokens/mc_colors.dart';

void main() {
  group('AppColorScheme', () {
    for (final (scheme, mc, brightness) in [
      (AppColorScheme.dark, McColors.dark, Brightness.dark),
      (AppColorScheme.light, McColors.light, Brightness.light),
    ]) {
      test('maps the $brightness tokens onto Material slots', () {
        expect(scheme.brightness, brightness);
        expect(scheme.primary, McColors.blue);
        expect(scheme.onPrimary, McColors.textOnPrimary);
        expect(scheme.secondary, mc.highlightSecondary);
        expect(scheme.surface, mc.canvas);
        expect(scheme.onSurface, mc.textPrimary);
        expect(scheme.onSurfaceVariant, mc.textSecondary);
        expect(scheme.outline, mc.control);
        expect(scheme.outlineVariant, mc.hairline);
        expect(scheme.error, mc.dangerText);
      });

      test('keeps $brightness containers opaque', () {
        for (final container in [
          scheme.surfaceContainerLowest,
          scheme.surfaceContainerLow,
          scheme.surfaceContainer,
          scheme.surfaceContainerHigh,
          scheme.surfaceContainerHighest,
        ]) {
          expect(container.a, 1.0);
        }
      });
    }
  });

  group('AppCustomColors', () {
    test('keeps call surfaces dark in both modes', () {
      expect(
        AppCustomColors.light.callControlSurface,
        AppCustomColors.dark.callControlSurface,
      );
      expect(
        AppCustomColors.light.mediaSurfaceOverlay,
        AppCustomColors.dark.mediaSurfaceOverlay,
      );
    });

    test('follows the mode for status colours', () {
      expect(AppCustomColors.dark.success, McColors.dark.success);
      expect(AppCustomColors.light.success, McColors.light.success);
    });

    test('lerps between modes', () {
      final halfway = AppCustomColors.dark.lerp(AppCustomColors.light, 0.5);
      expect(
        halfway.grey900,
        Color.lerp(McColors.dark.raised, McColors.light.raised, 0.5),
      );
    });
  });
}
