import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';

class ScreensizeHelper {
  static double getRadiusForScreenWidth(BuildContext context) {
    final screenWidth = context.mediaQuery.size.width;
    return screenWidth > 1024 ? 6.0 : 2.0;
  }

  static double getConstrainedWidth(BuildContext context) {
    final screenWidth = context.mediaQuery.size.width;
    return screenWidth > 1024 ? 1024 : screenWidth;
  }

  /// Returns true if the screen is in landscape mode.
  bool isLandscape(BuildContext context) {
    return context.mediaQuery.orientation == Orientation.landscape;
  }

  bool isBigScreen(BuildContext context) {
    // iPad Air portrait width is 820 logical pixels (as of 2024 models)
    return context.mediaQuery.size.width >= 820;
  }

  bool isSmallScreen(BuildContext context) {
    final screenWidth = context.mediaQuery.size.width;
    final screenHeight = context.mediaQuery.size.height;
    final shortestSide = screenWidth < screenHeight
        ? screenWidth
        : screenHeight;

    return shortestSide < 600;
  }
}
