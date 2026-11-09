import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../domain/models/identity/identity.dart';
import '../../l10n/app_localizations.dart';
import 'contact_card_extensions.dart';

/// Extension methods on [Identity] for handling display properties,
/// colors, gradients, images, and identity-specific information.
extension IdentityExtensions on Identity {
  static const _placeholderCardColor = Color(0xFFB4B4B4);

  /// Returns the card color for the identity: the colour its owner chose,
  /// else the primary colour, or a neutral grey for the "add new" option.
  Color getCardColor(ColorScheme colorScheme) {
    if (card.cardColor case final value? when value.isNotEmpty) {
      return Color(int.parse(value));
    }
    return isPlaceholder ? _placeholderCardColor : colorScheme.primary;
  }

  /// Returns `true` if this identity is the "add new" identity option.
  bool get isPlaceholder => id == placeholderIdentityId;

  /// Returns a display name for the identity.
  String getDisplayName({required AppLocalizations l10n}) {
    if (isPrimary) return l10n.displayNamePrimary;
    if (isPlaceholder) return l10n.displayNameAddNew;
    return card.displayName.isNotEmpty == true ? card.displayName : '';
  }

  /// Returns a subtitle for the identity.
  String getSubtitle({required AppLocalizations l10n}) {
    if (isPrimary) return l10n.subtitlePrimary;
    if (isPlaceholder) return l10n.subtitleAddNew;
    return l10n.subtitleAlias;
  }

  /// Returns the profile image for the identity.
  ImageProvider profileImage({required BaseCacheManager cacheManager}) {
    return card.image(cacheManager: cacheManager);
  }
}
