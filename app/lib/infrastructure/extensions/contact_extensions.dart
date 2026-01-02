import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../domain/models/contacts/contact.dart';
import '../../domain/models/contacts/contact_status.dart';
import '../../presentation/painting/cached_base64_image.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import 'build_context_extensions.dart';

/// UI helper accessors for Contact model used by widgets:
extension ContactExtensions on Contact {
  /// Returns a color for the contact status/avatar.
  Color getStatusColor(
    BuildContext context, {
    bool asAvatar = false,
    bool forceHideBorder = false,
  }) {
    var color = context.colorScheme.surface;

    if (forceHideBorder) {
      color = Colors.transparent;
    } else {
      switch (status) {
        case ContactStatus.pendingApproval:
          color = context.customColors.warning;
          break;
        case ContactStatus.pendingInauguration:
          color = context.colorScheme.primary;
          break;
        case ContactStatus.active:
        case ContactStatus.approved:
          color = context.customColors.success;

          if (asAvatar) {
            // Hide green border if:
            // 1. There are unread messages OR
            // 2. Contact has been opened before
            if (badgeCount > 0 || hasBeenOpened) {
              color = Colors.transparent;
            }
          }
          break;
        case ContactStatus.deleted:
        case ContactStatus.error:
          color = context.colorScheme.error;
          break;
        default:
          color = Colors.transparent;
      }
    }

    return color;
  }

  /// ImageProvider for the other party profile picture or default.
  ImageProvider<Object> otherPartyImage(
          {required BaseCacheManager cacheManager}) =>
      (otherPartyCard != null && (otherPartyCard!.profilePic ?? '').isNotEmpty)
          ? CachedBase64Image(otherPartyCard!.profilePic!,
              cacheManager: cacheManager)
          : defaultProfileImage;
}
