import 'package:flutter/material.dart';

extension BoxConstraintsSizes on BoxConstraints {
  /// Checks if the constraints correspond to
  /// a compact screen (e.g., mobile).
  bool get isCompactScreen => maxWidth < 600;

  /// Checks if the constraints correspond to
  /// a medium screen (e.g., tablet).
  bool get isMediumScreen => maxWidth >= 600 && maxWidth < 840;

  /// Checks if the constraints correspond to
  /// an expanded screen (e.g., desktop).
  bool get isExpandedScreen => maxWidth >= 840 && maxWidth < 1200;

  /// Checks if the constraints correspond to a
  /// large screen.
  bool get isLargeScreen => maxWidth >= 1200 && maxWidth < 1600;

  /// Checks if the constraints correspond to
  /// an extra-large screen.
  bool get isExtraLargeScreen => maxWidth >= 1600;
}
