import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_core/meeting_place_core.dart' show Identity;
import '../../l10n/app_localizations.dart';
import 'contact_card_extensions.dart';

const placeholderIdentityId = 'add-new';

/// Extension methods on [Identity] for handling display properties,
/// colors, gradients, images, and identity-specific information.
extension IdentityExtensions on Identity {
  /// Returns the card color for the identity.
  Color getCardColor(
    ColorScheme colorScheme, {
    double intensity = 1.0,
  }) {
    if (card.cardColor != null && card.cardColor!.isNotEmpty) {
      final colorValue = int.parse(card.cardColor!);
      final customColor = Color(colorValue);

      if (intensity == 1.0) {
        return customColor;
      } else {
        final red = (customColor.r * 255 * intensity).round();
        final green = (customColor.g * 255 * intensity).round();
        final blue = (customColor.b * 255 * intensity).round();
        final alpha = (customColor.a * 255).round();

        return Color.fromARGB(alpha, red, green, blue);
      }
    }

    if (isPrimary) {
      return Color.fromARGB(
          255,
          (colorScheme.primary.r * 255 * intensity).round(),
          (colorScheme.primary.g * 255 * intensity).round(),
          (colorScheme.primary.b * 255 * intensity).round());
    } else if (isPlaceholder) {
      return Color.fromARGB(255, (180 * intensity).round(),
          (180 * intensity).round(), (180 * intensity).round());
    } else {
      final defaultColor = colorScheme.primary;
      final r = (defaultColor.r * 255 * intensity).round();
      final g = (defaultColor.g * 255 * intensity).round();
      final b = (defaultColor.b * 255 * intensity).round();
      final a = (defaultColor.a * 255).round();
      return Color.fromARGB(a, r, g, b);
    }
  }

  /// Returns a linear gradient for the identity card.
  LinearGradient getLinearGradient(
    ColorScheme colorScheme, {
    Alignment center = Alignment.bottomCenter,
    double radius = 2.0,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        getCardColor(colorScheme),
        colorScheme.surface,
      ],
    );
  }

  /// Returns `true` if this identity is the "add new" identity option.
  bool get isPlaceholder => id == placeholderIdentityId;

  /// Returns a display name for the identity.
  String getDisplayName({
    required AppLocalizations l10n,
  }) {
    if (isPrimary) return l10n.displayNamePrimary;
    if (isPlaceholder) return l10n.displayNameAddNew;
    return card.displayName.isNotEmpty == true ? card.displayName : '';
  }

  /// Returns a subtitle for the identity.
  String getSubtitle({
    required AppLocalizations l10n,
  }) {
    if (isPrimary) return l10n.subtitlePrimary;
    if (isPlaceholder) return l10n.subtitleAddNew;
    return l10n.subtitleAlias;
  }

  /// Returns the profile image for the identity.
  ImageProvider profileImage({required BaseCacheManager cacheManager}) {
    return card.image(cacheManager: cacheManager);
  }
}
