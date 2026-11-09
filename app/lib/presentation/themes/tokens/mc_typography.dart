import 'package:flutter/material.dart';

/// Mission Control type scale in logical pixels (1rem = 16).
///
/// Ported from `@affinidi/design-tokens` v3.1.0 `font-size.*`,
/// `line-height.*` and `letter-spacing.*`. Fluid display and headline sizes
/// take the lower bound of their `clamp()`, which is what a phone renders.
/// Letter spacing is in em on the web, so it is multiplied by the size here.
///
/// The body weight is 380 on dark; the bundled static fonts stop at 400, the
/// weight the light mode uses.
abstract final class McTypography {
  static const fontFamily = 'Affinidi Sans';

  /// Flutter falls back through these for the mono voice: chips, readouts,
  /// logs.
  static const monoFamily = 'monospace';
  static const monoFamilyFallback = ['SF Mono', 'Menlo', 'Courier New'];

  static const _display = -0.035;
  static const _headline = -0.015;
  static const _title = -0.008;
  static const _body = -0.01;

  static const textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 38.4,
      height: 1,
      letterSpacing: _display * 38.4,
      fontWeight: FontWeight.w800,
    ),
    displayMedium: TextStyle(
      fontSize: 35.2,
      height: 1.03,
      letterSpacing: _display * 35.2,
      fontWeight: FontWeight.w800,
    ),
    displaySmall: TextStyle(
      fontSize: 32,
      height: 1.05,
      letterSpacing: _display * 32,
      fontWeight: FontWeight.w800,
    ),
    headlineLarge: TextStyle(
      fontSize: 30.4,
      height: 1.1,
      letterSpacing: _headline * 30.4,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      fontSize: 25.6,
      height: 1.15,
      letterSpacing: _headline * 25.6,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      fontSize: 22.4,
      height: 1.2,
      letterSpacing: _headline * 22.4,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.25,
      letterSpacing: _title * 20,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      height: 1.3,
      letterSpacing: _title * 18,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      height: 1.35,
      letterSpacing: _title * 16,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.65,
      letterSpacing: _body * 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.7,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.75,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.45,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.45,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.45,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
    ),
  );

  /// The instrument-label voice for chips, tags and readouts; uppercase the
  /// text where it is shown.
  static const monoLabel = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: monoFamilyFallback,
    fontSize: 11,
    height: 1.45,
    letterSpacing: 0.1 * 11,
  );

  /// Opens a section: uppercase, wide tracking, muted colour.
  static const eyebrow = TextStyle(
    fontSize: 12.8,
    letterSpacing: 0.18 * 12.8,
    fontWeight: FontWeight.w400,
  );

  static const code = TextStyle(
    fontFamily: monoFamily,
    fontFamilyFallback: monoFamilyFallback,
    fontSize: 13,
  );
}
