import 'package:flutter/material.dart';

import 'tokens/mc_colors.dart';

/// Maps the Mission Control tokens onto Material's colour slots.
///
/// Containers are opaque so dialogs, sheets and bars never show through;
/// red is never a fill, so the error container is a faint danger wash.
class AppColorScheme {
  static final dark = _fromTokens(
    McColors.dark,
    brightness: Brightness.dark,
    primaryContainer: const Color(0xFF1C2A3B),
    inversePrimary: McColors.blueDeep,
    errorContainer: const Color(0x1FF7766C),
    containerLow: const Color(0xFF070708),
    containerHigh: const Color(0xFF161617),
    containerHighest: const Color(0xFF222223),
  );

  static final light = _fromTokens(
    McColors.light,
    brightness: Brightness.light,
    primaryContainer: const Color(0xFFE2E8F0),
    inversePrimary: McColors.cyan,
    errorContainer: const Color(0x1FCA2529),
    containerLow: McColors.light.panel,
    containerHigh: const Color(0xFFE2E8F0),
    containerHighest: const Color(0xFFCBD5E1),
  );

  static ColorScheme _fromTokens(
    McColors mc, {
    required Brightness brightness,
    required Color primaryContainer,
    required Color inversePrimary,
    required Color errorContainer,
    required Color containerLow,
    required Color containerHigh,
    required Color containerHighest,
  }) => ColorScheme(
    brightness: brightness,
    primary: McColors.blue,
    onPrimary: McColors.textOnPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: mc.textPrimary,
    inversePrimary: inversePrimary,
    secondary: mc.highlightSecondary,
    onSecondary: mc.textOnAccent,
    secondaryContainer: mc.panel2,
    onSecondaryContainer: mc.textPrimary,
    tertiary: mc.accentEnd,
    onTertiary: mc.textOnAccent,
    error: mc.dangerText,
    onError: mc.textOnAccent,
    errorContainer: errorContainer,
    onErrorContainer: mc.dangerText,
    surface: mc.canvas,
    onSurface: mc.textPrimary,
    onSurfaceVariant: mc.textSecondary,
    surfaceDim: mc.canvas,
    surfaceBright: mc.raised,
    surfaceContainerLowest: mc.sunken,
    surfaceContainerLow: containerLow,
    surfaceContainer: mc.raised,
    surfaceContainerHigh: containerHigh,
    surfaceContainerHighest: containerHighest,
    inverseSurface: mc.textPrimary,
    onInverseSurface: mc.canvas,
    outline: mc.control,
    outlineVariant: mc.hairline,
    shadow: Colors.black,
    scrim: mc.scrim,
    surfaceTint: Colors.transparent,
  );
}
