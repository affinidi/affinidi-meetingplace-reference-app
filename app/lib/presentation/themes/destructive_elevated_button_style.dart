import 'package:flutter/material.dart';

@immutable
class DestructiveElevatedButtonStyle
    extends ThemeExtension<DestructiveElevatedButtonStyle> {
  DestructiveElevatedButtonStyle(this.buttonStyle);

  final ButtonStyle buttonStyle;

  @override
  ThemeExtension<DestructiveElevatedButtonStyle> copyWith({
    ButtonStyle? buttonStyle,
  }) {
    return DestructiveElevatedButtonStyle(buttonStyle ?? this.buttonStyle);
  }

  @override
  ThemeExtension<DestructiveElevatedButtonStyle> lerp(
    covariant ThemeExtension<DestructiveElevatedButtonStyle>? other,
    double t,
  ) {
    return this;
  }
}
