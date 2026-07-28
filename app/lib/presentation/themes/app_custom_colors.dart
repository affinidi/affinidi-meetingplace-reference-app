import 'package:flutter/material.dart';

@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  const AppCustomColors({
    this._mention,
    this._cyan,
    this._purple,
    this._rose,
    this._violet,
    this._success,
    this._warning,
    this._grey900,
    this._grey700,
    this._whiteOverlay30,
    this._brown,
    this._orange,
    this._disabledGrey,
    this._darkGrey,
    this._searchHintText,
    this._searchFieldFill,
    this._fromMeColor,
    this._fromMeDarkColor,
    this._credentialCardGradientStart,
    this._credentialCardShadow,
    this._awaitingMemberWarningText,
    this._mediaSurfaceOverlay,
    this._mediaSurfaceBorder,
  });

  /// Color for concierge messages in chat
  static const conciergeMessageColor = Color.fromARGB(255, 53, 130, 6);
  static const grey800 = Color(0xFF404040);
  static const conciergeCardGradientStart = grey800;
  static const conciergeCardGradientEnd = Color(0xFF1F1F1F);
  static const conciergeActionOnWhite = grey800;

  static const primaryBrand10 = Color(0xFFE8EEFF);
  static const secondaryBrand90 = Color(0xFF1D2138);
  static const utilitySuccess100 = Color(0xFF00A08D);

  final Color? _mention;
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
  final Color? _searchHintText;
  final Color? _searchFieldFill;
  final Color? _fromMeColor;
  final Color? _fromMeDarkColor;
  final Color? _credentialCardGradientStart;
  final Color? _credentialCardShadow;
  final Color? _awaitingMemberWarningText;
  final Color? _mediaSurfaceOverlay;
  final Color? _mediaSurfaceBorder;

  Color get mention => _mention ?? Colors.orange;
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
  Color get searchHintText => _searchHintText ?? const Color(0xFFBDBDBD);
  Color get searchFieldFill => _searchFieldFill ?? const Color(0xFF1C1C1E);
  Color get fromMeColor =>
      _fromMeColor ?? const Color.fromARGB(255, 3, 104, 192);
  Color get fromMeDarkColor => _fromMeDarkColor ?? const Color(0xFF020B1A);
  Color get credentialCardGradientStart =>
      _credentialCardGradientStart ?? const Color(0xFF040822);
  Color get credentialCardShadow =>
      _credentialCardShadow ?? const Color.fromARGB(64, 0, 0, 0);
  Color get awaitingMemberWarningText =>
      _awaitingMemberWarningText ?? const Color(0xFFEEEEEE);
  Color get mediaSurfaceOverlay =>
      _mediaSurfaceOverlay ?? const Color.fromARGB(178, 18, 18, 20);
  Color get mediaSurfaceBorder =>
      _mediaSurfaceBorder ?? const Color.fromARGB(52, 255, 255, 255);

  @override
  AppCustomColors copyWith({
    Color? mention,
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
    Color? searchHintText,
    Color? searchFieldFill,
    Color? fromMeColor,
    Color? fromMeDarkColor,
    Color? credentialCardGradientStart,
    Color? credentialCardShadow,
    Color? awaitingMemberWarningText,
    Color? mediaSurfaceOverlay,
    Color? mediaSurfaceBorder,
  }) {
    return AppCustomColors(
      mention: mention ?? _mention,
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
      searchHintText: searchHintText ?? _searchHintText,
      searchFieldFill: searchFieldFill ?? _searchFieldFill,
      fromMeColor: fromMeColor ?? _fromMeColor,
      fromMeDarkColor: fromMeDarkColor ?? _fromMeDarkColor,
      credentialCardGradientStart:
          credentialCardGradientStart ?? _credentialCardGradientStart,
      credentialCardShadow: credentialCardShadow ?? _credentialCardShadow,
      awaitingMemberWarningText:
          awaitingMemberWarningText ?? _awaitingMemberWarningText,
      mediaSurfaceOverlay: mediaSurfaceOverlay ?? _mediaSurfaceOverlay,
      mediaSurfaceBorder: mediaSurfaceBorder ?? _mediaSurfaceBorder,
    );
  }

  @override
  AppCustomColors lerp(AppCustomColors? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      mention: Color.lerp(_mention, other._mention, t),
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
      searchHintText: Color.lerp(_searchHintText, other._searchHintText, t),
      searchFieldFill: Color.lerp(_searchFieldFill, other._searchFieldFill, t),
      fromMeColor: Color.lerp(_fromMeColor, other._fromMeColor, t),
      fromMeDarkColor: Color.lerp(_fromMeDarkColor, other._fromMeDarkColor, t),
      credentialCardGradientStart: Color.lerp(
        _credentialCardGradientStart,
        other._credentialCardGradientStart,
        t,
      ),
      credentialCardShadow: Color.lerp(
        _credentialCardShadow,
        other._credentialCardShadow,
        t,
      ),
      awaitingMemberWarningText: Color.lerp(
        _awaitingMemberWarningText,
        other._awaitingMemberWarningText,
        t,
      ),
      mediaSurfaceOverlay: Color.lerp(
        _mediaSurfaceOverlay,
        other._mediaSurfaceOverlay,
        t,
      ),
      mediaSurfaceBorder: Color.lerp(
        _mediaSurfaceBorder,
        other._mediaSurfaceBorder,
        t,
      ),
    );
  }
}
