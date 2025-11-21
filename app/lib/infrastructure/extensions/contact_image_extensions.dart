import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../domain/models/contacts/contact.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import '../../presentation/widgets/images/group_image.dart';
import 'vcard_extensions.dart';

/// Extension to simplify image handling for contacts.
extension ContactImageExtensions on Contact {
  /// Returns the appropriate image provider for this contact.
  /// - For groups: returns [groupImage]
  /// - For individuals with profile pic: returns cached base64 image
  /// - For individuals without profile pic: returns [defaultProfileImage]
  ImageProvider<Object> image({required BaseCacheManager cacheManager}) {
    if (isGroup) {
      return groupImage;
    }
    return vCard.image(cacheManager: cacheManager);
  }

  /// Returns true if this contact uses the default group or profile image.
  bool get hasDefaultImage {
    if (isGroup) return true;
    return !vCard.hasProfilePic;
  }
}
