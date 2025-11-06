import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../presentation/painting/cached_base64_image.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import 'string_list_extensions.dart';

/// Defines common VCard property paths used in MeetingPlace.
enum VCardPaths {
  /// Path for the first name.
  firstName(['n', 'given']),

  /// Path for the last name.
  lastName(['n', 'surname']),

  /// Path for the work email address.
  email(['email', 'type', 'work']),

  /// Path for the mobile phone number.
  mobile(['tel', 'type', 'cell']),

  /// Path for the profile picture.
  profilePic(['photo']),

  /// Path for the MeetingPlace-specific card color.
  meetingplaceIdentityCardColor(['x-meetingplace-identity-card-color']);

  const VCardPaths(this.paths);

  /// The nested key paths used to find the field in the VCard map.
  final List<String> paths;
}

/// Utility methods for working with VCard maps.
class VCardUtils {
  /// Returns the string value at the given [pathKeys] from [values].
  ///
  /// If the path cannot be resolved, returns [defaultValue].
  static String getVcardPathValue(
    Map<dynamic, dynamic> values,
    List<String> pathKeys, {
    String defaultValue = '',
  }) {
    if (pathKeys.isEmpty) return defaultValue;

    var parentElement = values;
    for (final pathKey in pathKeys) {
      final elementAtPath = parentElement[pathKey];
      if (elementAtPath == null) {
        return defaultValue;
      }

      if ((pathKey == pathKeys.last) && elementAtPath is String) {
        return elementAtPath;
      }

      if (elementAtPath is Map<dynamic, dynamic>) {
        parentElement = elementAtPath;
      }
    }

    return defaultValue;
  }

  /// Sets the [value] at the given [pathKeys] inside [values].
  ///
  /// Creates missing intermediate maps if necessary.
  static void setVcardPathValue(
    Map<dynamic, dynamic> values,
    List<String> pathKeys,
    String value,
  ) {
    if (pathKeys.isEmpty) return;

    var parentElement = values;
    for (final pathKey in pathKeys) {
      if (pathKey == pathKeys.last) continue;

      final elementAtPath = parentElement[pathKey];
      if (elementAtPath == null) {
        var newNode = <dynamic, dynamic>{};
        parentElement[pathKey] = newNode;
        parentElement = newNode;
      } else if (elementAtPath is Map<dynamic, dynamic>) {
        parentElement = elementAtPath;
      }
    }

    parentElement[pathKeys.last] = value;
  }

  /// Returns `true` if the VCard has a profile picture.
  static bool hasProfilePic(Map<dynamic, dynamic> values) {
    final pic = getVcardPathValue(values, VCardPaths.profilePic.paths);
    return pic.isNotEmpty;
  }

  /// Returns the profile picture as a [ImageProvider].
  /// Falls back to [defaultProfileImage] if none is set.
  static ImageProvider<Object> getImage(Map<dynamic, dynamic> values,
      {required BaseCacheManager cacheManager}) {
    return hasProfilePic(values)
        ? CachedBase64Image(
            getVcardPathValue(values, VCardPaths.profilePic.paths),
            cacheManager: cacheManager)
        : defaultProfileImage;
  }

  /// Returns the full name by combining first and last names.
  static String getFullName(Map<dynamic, dynamic> values) {
    final firstName = getVcardPathValue(values, VCardPaths.firstName.paths);
    final lastName = getVcardPathValue(values, VCardPaths.lastName.paths);
    return [firstName, lastName].nonEmpty.join(' ');
  }
}

/// Extension methods on [VCard] for convenient access to fields.
extension VCardFieldsKeys on VCard {
  /// Gets or sets the first name.
  String get firstName =>
      VCardUtils.getVcardPathValue(values, VCardPaths.firstName.paths);
  set firstName(String value) =>
      VCardUtils.setVcardPathValue(values, VCardPaths.firstName.paths, value);

  /// Gets or sets the last name.
  String get lastName =>
      VCardUtils.getVcardPathValue(values, VCardPaths.lastName.paths);
  set lastName(String value) =>
      VCardUtils.setVcardPathValue(values, VCardPaths.lastName.paths, value);

  /// Gets or sets the email address.
  String get email =>
      VCardUtils.getVcardPathValue(values, VCardPaths.email.paths);
  set email(String value) =>
      VCardUtils.setVcardPathValue(values, VCardPaths.email.paths, value);

  /// Gets or sets the mobile number.
  String get mobile =>
      VCardUtils.getVcardPathValue(values, VCardPaths.mobile.paths);
  set mobile(String value) =>
      VCardUtils.setVcardPathValue(values, VCardPaths.mobile.paths, value);

  /// Gets or sets the base64-encoded profile picture string.
  String get profilePic =>
      VCardUtils.getVcardPathValue(values, VCardPaths.profilePic.paths,
          defaultValue: '');
  set profilePic(String value) =>
      VCardUtils.setVcardPathValue(values, VCardPaths.profilePic.paths, value);

  /// Gets or sets the MeetingPlace identity card color.
  String get meetingplaceIdentityCardColor => VCardUtils.getVcardPathValue(
      values, VCardPaths.meetingplaceIdentityCardColor.paths);
  set meetingplaceIdentityCardColor(String value) =>
      VCardUtils.setVcardPathValue(
          values, VCardPaths.meetingplaceIdentityCardColor.paths, value);

  /// Returns `true` if the VCard has a profile picture.
  bool get hasProfilePic => VCardUtils.hasProfilePic(values);

  /// Returns the profile picture as a ImageProvider.
  ImageProvider<Object> image({required BaseCacheManager cacheManager}) =>
      VCardUtils.getImage(values, cacheManager: cacheManager);

  /// Returns the full name (first name + last name).
  String get fullName => VCardUtils.getFullName(values);
}
