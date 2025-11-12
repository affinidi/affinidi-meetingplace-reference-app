import 'package:flutter/material.dart';

/// Extension methods on [ScrollController]
extension ScrollControllerExtensions on ScrollController {
  /// Checks if content of scrollable item is fully visible
  ///
  /// Returns false when content is fully visible and true
  /// when some scrolling is needed to view remaining content
  bool get isScrollable => hasClients && position.maxScrollExtent > 0;
}
