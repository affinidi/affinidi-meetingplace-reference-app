import 'package:flutter/material.dart';

@immutable
class QRScannerTheme extends ThemeExtension<QRScannerTheme> {
  const QRScannerTheme({
    required this.colorScheme,
    this.backgroundColor = Colors.black,
    this.whiteColor = Colors.white,
    this.white70Color = Colors.white70,
    this.defaultPadding = 20.0,
    this.iconSize = 100.0,
    this.titleFontSize = 18.0,
    this.instructionsFontSize = 16.0,
    this.debugInfoFontSize = 12.0,
    this.errorMessageFontSize = 14.0,
    this.borderRadius = 8.0,
    this.debugContainerOpacity = 0.7,
  });

  final ColorScheme colorScheme;
  final Color backgroundColor;
  final Color whiteColor;
  final Color white70Color;
  final double defaultPadding;
  final double iconSize;
  final double titleFontSize;
  final double instructionsFontSize;
  final double debugInfoFontSize;
  final double errorMessageFontSize;
  final double borderRadius;
  final double debugContainerOpacity;

  @override
  QRScannerTheme copyWith({
    ColorScheme? colorScheme,
    Color? backgroundColor,
    Color? whiteColor,
    Color? white70Color,
    double? defaultPadding,
    double? iconSize,
    double? titleFontSize,
    double? instructionsFontSize,
    double? debugInfoFontSize,
    double? errorMessageFontSize,
    double? borderRadius,
    double? debugContainerOpacity,
  }) {
    return QRScannerTheme(
      colorScheme: colorScheme ?? this.colorScheme,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      whiteColor: whiteColor ?? this.whiteColor,
      white70Color: white70Color ?? this.white70Color,
      defaultPadding: defaultPadding ?? this.defaultPadding,
      iconSize: iconSize ?? this.iconSize,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      instructionsFontSize: instructionsFontSize ?? this.instructionsFontSize,
      debugInfoFontSize: debugInfoFontSize ?? this.debugInfoFontSize,
      errorMessageFontSize: errorMessageFontSize ?? this.errorMessageFontSize,
      borderRadius: borderRadius ?? this.borderRadius,
      debugContainerOpacity:
          debugContainerOpacity ?? this.debugContainerOpacity,
    );
  }

  @override
  QRScannerTheme lerp(QRScannerTheme? other, double t) {
    if (other is! QRScannerTheme) return this;

    return QRScannerTheme(
      colorScheme: colorScheme,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      whiteColor: Color.lerp(whiteColor, other.whiteColor, t)!,
      white70Color: Color.lerp(white70Color, other.white70Color, t)!,
      defaultPadding: (defaultPadding * (1 - t)) + (other.defaultPadding * t),
      iconSize: (iconSize * (1 - t)) + (other.iconSize * t),
      titleFontSize: (titleFontSize * (1 - t)) + (other.titleFontSize * t),
      instructionsFontSize:
          (instructionsFontSize * (1 - t)) + (other.instructionsFontSize * t),
      debugInfoFontSize:
          (debugInfoFontSize * (1 - t)) + (other.debugInfoFontSize * t),
      errorMessageFontSize:
          (errorMessageFontSize * (1 - t)) + (other.errorMessageFontSize * t),
      borderRadius: (borderRadius * (1 - t)) + (other.borderRadius * t),
      debugContainerOpacity:
          (debugContainerOpacity * (1 - t)) + (other.debugContainerOpacity * t),
    );
  }
}
