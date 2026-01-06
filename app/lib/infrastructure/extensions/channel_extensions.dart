import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../presentation/painting/cached_base64_image.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import 'contact_card_extensions.dart';

/// Extension to simplify image handling for channels.
extension ChannelImageExtensions on Channel {
  /// Helper to check if a profile pic string is valid.
  bool _hasProfilePic(String? profilePic) {
    return profilePic != null && profilePic.isNotEmpty;
  }

  /// Helper to get image provider from profile pic string.
  ImageProvider<Object> _getImageProvider(
    String? profilePic, {
    required BaseCacheManager cacheManager,
  }) {
    return _hasProfilePic(profilePic)
        ? CachedBase64Image(profilePic!, cacheManager: cacheManager)
        : defaultProfileImage;
  }

  /// Returns the other party's image provider from the channel.
  /// Returns [defaultProfileImage] if otherPartyCard is null or has no
  /// profile pic.
  ImageProvider<Object> otherPartyImage({
    required BaseCacheManager cacheManager,
  }) {
    return _getImageProvider(
      otherPartyContactCard?.profilePic,
      cacheManager: cacheManager,
    );
  }

  /// Returns my (local user's) image provider from the channel.
  /// Returns [defaultProfileImage] if card is null or has no profile pic.
  ImageProvider<Object> myImage({required BaseCacheManager cacheManager}) {
    return _getImageProvider(
      contactCard?.profilePic,
      cacheManager: cacheManager,
    );
  }

  /// Returns true if the other party has a profile picture.
  bool get hasOtherPartyProfilePic =>
      _hasProfilePic(otherPartyContactCard?.profilePic);

  /// Returns true if my (local user's) card has a profile picture.
  bool get hasMyProfilePic => _hasProfilePic(contactCard?.profilePic);
}
