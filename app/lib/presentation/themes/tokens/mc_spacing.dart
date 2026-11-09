/// Mission Control spacing scale in logical pixels (1rem = 16).
///
/// Ported from `@affinidi/design-tokens` v3.1.0 `space.*`. Apps use the
/// tighter end ([s2]…[s4]) for control padding and rows.
abstract final class McSpacing {
  static const double hairline = 1;
  static const double s05 = 2;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 28;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s14 = 56;
  static const double s16 = 64;

  static const double focusRingWidth = 2;
  static const double accentLine = 2;
}
