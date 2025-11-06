import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import 'build_context_extensions.dart';

/// UI helpers that map a ConnectionOffer's `type` and `status` to theme colors.
/// - getTypeColor(BuildContext) -> Color for offer type
/// - getStatusColor(BuildContext) -> Color for offer status
extension ConnectionColorExtensions on ConnectionOffer {
  Color getTypeColor(BuildContext context) {
    final customColors = context.customColors;

    switch (type) {
      case ConnectionOfferType.meetingPlaceInvitation:
      default:
        return customColors.grey900;
    }
  }

  Color getStatusColor(BuildContext context) {
    final customColors = context.customColors;
    final colorScheme = context.colorScheme;

    switch (status) {
      case ConnectionOfferStatus.published:
        return customColors.success;
      case ConnectionOfferStatus.accepted:
        return customColors.warning;
      case ConnectionOfferStatus.deleted:
        return colorScheme.error;
      case ConnectionOfferStatus.channelInaugurated:
        return colorScheme.primary;
      default:
        return customColors.grey700;
    }
  }

  String localized(BuildContext context) {
    final l10n = context.l10n;
    return l10n.connectionStatus(status.name);
  }
}
