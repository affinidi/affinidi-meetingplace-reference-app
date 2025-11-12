import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../domain/models/contact_card/contact_card.dart';
import '../../presentation/painting/cached_base64_image.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import 'vcard_extensions.dart';

/// Convenience helpers on ContactCard:
extension ContactCardExtensions on ContactCard {
  /// True when the contact card contains a non-empty profile picture.
  bool get hasProfilePic => profilePic != null && profilePic!.trim().isNotEmpty;

  /// Full display name composed from first and last name.
  String get fullName => '$firstName ${lastName ?? ''}'.trim();

  /// ImageProvider for the contact's profile picture or default placeholder
  ImageProvider<Object> image({required BaseCacheManager cacheManager}) {
    if (!hasProfilePic) {
      return defaultProfileImage;
    }
    return CachedBase64Image(profilePic!, cacheManager: cacheManager);
  }

  /// Primary mobile phone or empty string.
  String get mobilePhone => mobile ?? '';

  /// Primary email or empty string.
  String get emailAddress => email ?? '';

  /// Convert this ContactCard into an SDK VCard.
  VCard toVCard() {
    final vcard = VCard.empty();
    vcard.firstName = firstName;
    vcard.lastName = lastName ?? '';
    vcard.email = email ?? '';
    vcard.mobile = mobile ?? '';
    vcard.profilePic = profilePic ?? '';
    vcard.meetingplaceIdentityCardColor = cardColor ?? '';

    return vcard;
  }
}
