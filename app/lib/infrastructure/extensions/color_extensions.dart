import 'package:flutter/material.dart';

/// Small Color utilities:
extension ColorExtensions on Color {
  /// Returns a copy of this color with the [lightness] applied to it.
  Color withLightness(double lightness) {
    final hls = HSLColor.fromColor(this);
    return hls.withLightness((hls.lightness - lightness).clamp(0, 1)).toColor();
  }

  /// toInt() to convert Color to ARGB int.
  int toInt() {
    final alpha = (a * 255).toInt();
    final red = (r * 255).toInt();
    final green = (g * 255).toInt();
    final blue = (b * 255).toInt();
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }
}
