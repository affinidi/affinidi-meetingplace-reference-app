import 'package:flutter/material.dart';

/// Mission Control elevation in logical pixels.
///
/// Ported from `@affinidi/design-tokens` v3.1.0 `elevation.glow.card`: a
/// brand-tinted glow under a featured card in dark mode, which the light
/// mode replaces with a soft raised shadow. Use it sparingly, on one
/// featured card per screen.
abstract final class McElevation {
  static const _glowCardDark = [
    BoxShadow(
      color: Color(0x663464FD),
      offset: Offset(0, 30),
      blurRadius: 80,
      spreadRadius: -50,
    ),
  ];

  static const _glowCardLight = [
    BoxShadow(color: Color(0x0F0A182A), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x1A0A182A), offset: Offset(0, 1), blurRadius: 3),
  ];

  static List<BoxShadow> glowCard(Brightness brightness) =>
      brightness == Brightness.dark ? _glowCardDark : _glowCardLight;
}
