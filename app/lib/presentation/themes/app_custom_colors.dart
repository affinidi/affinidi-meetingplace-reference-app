import 'package:flutter/material.dart';

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  const AppCustomColors({
    Color? cyan,
    Color? purple,
    Color? rose,
    Color? violet,
    Color? success,
    Color? warning,
    Color? grey900,
    Color? grey700,
    Color? whiteOverlay30,
    Color? brown,
    Color? orange,
    Color? disabledGrey,
    Color? darkGrey,
  }) : _cyan = cyan,
       _purple = purple,
       _rose = rose,
       _violet = violet,
       _success = success,
       _warning = warning,
       _grey900 = grey900,
       _grey700 = grey700,
       _whiteOverlay30 = whiteOverlay30,
       _brown = brown,
       _orange = orange,
       _disabledGrey = disabledGrey,
       _darkGrey = darkGrey;

  final Color? _cyan;
  final Color? _purple;
  final Color? _rose;
  final Color? _violet;
  final Color? _success;
  final Color? _warning;
  final Color? _grey900;
  final Color? _grey700;
  final Color? _whiteOverlay30;
  final Color? _brown;
  final Color? _orange;
  final Color? _disabledGrey;
  final Color? _darkGrey;

  Color get cyan => _cyan ?? Colors.cyan;
  Color get purple => _purple ?? Colors.purple;
  Color get rose => _rose ?? const Color.fromARGB(255, 211, 31, 130);
  Color get violet => _violet ?? const Color.fromARGB(255, 184, 31, 211);
  Color get success => _success ?? const Color(0xFF4CAF50);
  Color get warning => _warning ?? const Color.fromARGB(255, 217, 154, 6);
  Color get brown => _brown ?? Colors.brown;
  Color get orange => _orange ?? Colors.orange;
  Color get grey900 => _grey900 ?? const Color(0xFF212121);
  Color get grey700 => _grey700 ?? const Color(0xFF636363);
  Color get whiteOverlay30 =>
      _whiteOverlay30 ?? const Color.fromARGB(30, 255, 255, 255);
  Color get disabledGrey =>
      _disabledGrey ?? const Color.fromARGB(100, 180, 180, 180);
  Color get darkGrey => _darkGrey ?? const Color.fromARGB(255, 49, 49, 51);

  @override
  AppCustomColors copyWith({
    Color? cyan,
    Color? purple,
    Color? rose,
    Color? violet,
    Color? success,
    Color? warning,
    Color? grey900,
    Color? grey700,
    Color? whiteOverlay30,
    Color? brown,
    Color? orange,
    Color? disabledGrey,
    Color? darkGrey,
  }) {
    return AppCustomColors(
      cyan: cyan ?? _cyan,
      purple: purple ?? _purple,
      rose: rose ?? _rose,
      violet: violet ?? _violet,
      success: success ?? _success,
      warning: warning ?? _warning,
      grey900: grey900 ?? _grey900,
      grey700: grey700 ?? _grey700,
      whiteOverlay30: whiteOverlay30 ?? _whiteOverlay30,
      brown: brown ?? _brown,
      orange: orange ?? _orange,
      disabledGrey: disabledGrey ?? _disabledGrey,
      darkGrey: darkGrey ?? _darkGrey,
    );
  }

  @override
  AppCustomColors lerp(AppCustomColors? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      cyan: Color.lerp(_cyan, other._cyan, t),
      purple: Color.lerp(_purple, other._purple, t),
      rose: Color.lerp(_rose, other._rose, t),
      violet: Color.lerp(_violet, other._violet, t),
      success: Color.lerp(_success, other._success, t),
      warning: Color.lerp(_warning, other._warning, t),
      grey900: Color.lerp(_grey900, other._grey900, t),
      grey700: Color.lerp(_grey700, other._grey700, t),
      whiteOverlay30: Color.lerp(_whiteOverlay30, other._whiteOverlay30, t),
      brown: Color.lerp(_brown, other._brown, t),
      orange: Color.lerp(_orange, other._orange, t),
      disabledGrey: Color.lerp(_disabledGrey, other._disabledGrey, t),
      darkGrey: Color.lerp(_darkGrey, other._darkGrey, t),
    );
  }
}
