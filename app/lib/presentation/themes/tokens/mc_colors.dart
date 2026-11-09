import 'package:flutter/material.dart';

/// Mission Control colour tokens for one colour mode.
///
/// Ported from `@affinidi/design-tokens` v3.1.0: `dist/json/tokens.json`
/// (dark) and `dist/light/tokens.light.json` (light). Update both modes from
/// those files when the design language changes; CSS `#RRGGBBAA` and
/// `rgba()` values are written here as `0xAARRGGBB`.
@immutable
class McColors extends ThemeExtension<McColors> {
  const McColors._({
    required this.canvas,
    required this.panel,
    required this.panel2,
    required this.raised,
    required this.sunken,
    required this.overlay,
    required this.scrim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textFaint,
    required this.textOnAccent,
    required this.hairline,
    required this.hairlineStrong,
    required this.control,
    required this.ok,
    required this.bad,
    required this.success,
    required this.warning,
    required this.dangerText,
    required this.hoverWash,
    required this.knob,
    required this.highlightSecondary,
    required this.accentEnd,
    required this.insetTop,
  });

  static const blue = Color(0xFF3464FD);
  static const blueDeep = Color(0xFF2347BA);
  static const cyan = Color(0xFF72F5FA);
  static const ice = Color(0xFFE0F9FF);
  static const purple = Color(0xFFAE44D5);
  static const lime = Color(0xFFADDD02);
  static const orange = Color(0xFFF5AB0B);
  static const pink = Color(0xFFFB54B5);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const danger = Color(0xFFEF4444);
  static const controlHoverWash = Color(0x143464FD);

  static const dark = McColors._(
    canvas: Color(0xFF000000),
    panel: Color(0x08F4F6FB),
    panel2: Color(0x0FF4F6FB),
    raised: Color(0xFF0E0E0F),
    sunken: Color(0xFF000000),
    overlay: Color(0xBF0E0E0F),
    scrim: Color(0xA3000000),
    textPrimary: Color(0xFFF4F6FB),
    textSecondary: Color(0xFF9AA3B2),
    textTertiary: Color(0xFF747D8E),
    textFaint: Color(0x8CF4F6FB),
    textOnAccent: Color(0xFF000000),
    hairline: Color(0x1FF4F6FB),
    hairlineStrong: Color(0x33F4F6FB),
    control: Color(0x5EF4F6FB),
    ok: Color(0xFF26D07C),
    bad: Color(0xFFFF5F6D),
    success: Color(0xFF16A34A),
    warning: Color(0xFFFBBF24),
    dangerText: Color(0xFFF7766C),
    hoverWash: Color(0x0FF4F6FB),
    knob: Color(0xFF222223),
    highlightSecondary: cyan,
    accentEnd: cyan,
    insetTop: Color(0x14F4F6FB),
  );

  static const light = McColors._(
    canvas: Color(0xFFF8FAFC),
    panel: Color(0xFFF1F5F9),
    panel2: Color(0xFFEDF0F5),
    raised: Color(0xFFFFFFFF),
    sunken: Color(0xFFF1F5F9),
    overlay: Color(0xBFFFFFFF),
    scrim: Color(0x6B000717),
    textPrimary: Color(0xFF000717),
    textSecondary: Color(0xFF324155),
    textTertiary: Color(0xFF465569),
    textFaint: Color(0xFF5B6B82),
    textOnAccent: Color(0xFFFFFFFF),
    hairline: Color(0x1F000000),
    hairlineStrong: Color(0x33000000),
    control: Color(0x6E000000),
    ok: Color(0xFF009957),
    bad: Color(0xFFEB4C5D),
    success: Color(0xFF21853C),
    warning: Color(0xFF87661B),
    dangerText: Color(0xFFCA2529),
    hoverWash: Color(0xFFEDF0F5),
    knob: Color(0xFFCBD5E1),
    highlightSecondary: blueDeep,
    accentEnd: Color(0xFF008085),
    // Light panels lift with shadow instead.
    insetTop: Color(0x00000000),
  );

  final Color canvas;
  final Color panel;
  final Color panel2;
  final Color raised;
  final Color sunken;

  /// Menus and popovers; always paired with a background blur.
  final Color overlay;
  final Color scrim;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textFaint;

  /// Text on light brand fills (cyan, ice); never on blue.
  final Color textOnAccent;
  final Color hairline;
  final Color hairlineStrong;
  final Color control;
  final Color ok;
  final Color bad;
  final Color success;
  final Color warning;

  /// The only status colour allowed as copy.
  final Color dangerText;
  final Color hoverWash;
  final Color knob;
  final Color highlightSecondary;
  final Color accentEnd;

  /// The 1px lit top edge that makes a panel feel raised.
  final Color insetTop;

  /// Reserved for one accent per heading and thin top accents; never a
  /// button fill.
  LinearGradient get accentGradient =>
      LinearGradient(colors: [blue, accentEnd]);

  @override
  McColors copyWith({
    Color? canvas,
    Color? panel,
    Color? panel2,
    Color? raised,
    Color? sunken,
    Color? overlay,
    Color? scrim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textFaint,
    Color? textOnAccent,
    Color? hairline,
    Color? hairlineStrong,
    Color? control,
    Color? ok,
    Color? bad,
    Color? success,
    Color? warning,
    Color? dangerText,
    Color? hoverWash,
    Color? knob,
    Color? highlightSecondary,
    Color? accentEnd,
    Color? insetTop,
  }) {
    return McColors._(
      canvas: canvas ?? this.canvas,
      panel: panel ?? this.panel,
      panel2: panel2 ?? this.panel2,
      raised: raised ?? this.raised,
      sunken: sunken ?? this.sunken,
      overlay: overlay ?? this.overlay,
      scrim: scrim ?? this.scrim,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textFaint: textFaint ?? this.textFaint,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      hairline: hairline ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      control: control ?? this.control,
      ok: ok ?? this.ok,
      bad: bad ?? this.bad,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      dangerText: dangerText ?? this.dangerText,
      hoverWash: hoverWash ?? this.hoverWash,
      knob: knob ?? this.knob,
      highlightSecondary: highlightSecondary ?? this.highlightSecondary,
      accentEnd: accentEnd ?? this.accentEnd,
      insetTop: insetTop ?? this.insetTop,
    );
  }

  @override
  McColors lerp(McColors? other, double t) {
    if (other is! McColors) return this;
    return McColors._(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      panel2: Color.lerp(panel2, other.panel2, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      sunken: Color.lerp(sunken, other.sunken, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairlineStrong: Color.lerp(hairlineStrong, other.hairlineStrong, t)!,
      control: Color.lerp(control, other.control, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      bad: Color.lerp(bad, other.bad, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      hoverWash: Color.lerp(hoverWash, other.hoverWash, t)!,
      knob: Color.lerp(knob, other.knob, t)!,
      highlightSecondary: Color.lerp(
        highlightSecondary,
        other.highlightSecondary,
        t,
      )!,
      accentEnd: Color.lerp(accentEnd, other.accentEnd, t)!,
      insetTop: Color.lerp(insetTop, other.insetTop, t)!,
    );
  }
}
