import 'package:flutter/material.dart';

import '../../domain/models/contacts/contact_origin.dart';
import 'build_context_extensions.dart';

/// Map contact origin to a display color used in the UI.
extension ContactOriginExtensions on ContactOrigin {
  /// Return a color representing this origin.
  ///
  /// Uses the theme's primary color for common origins, falls back to blueGrey.
  Color color(BuildContext context) {
    final colorScheme = context.colorScheme;

    switch (this) {
      case ContactOrigin.directInteractive:
      case ContactOrigin.individualOfferPublished:
      case ContactOrigin.groupOfferPublished:
      case ContactOrigin.individualOfferRequested:
        return colorScheme.primary;
      default:
        return Colors.blueGrey;
    }
  }
}
