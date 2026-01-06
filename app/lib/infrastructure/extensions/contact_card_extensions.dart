import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:uuid/uuid.dart' as uuid;

import '../../domain/models/contact_card/contact_card.dart';
import '../../presentation/painting/cached_base64_image.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import 'string_list_extensions.dart';

enum ContactCardType {
  human('human'),
  contactCard('contactCard');

  const ContactCardType(this.value);
  final String value;
}

enum ContactCardPaths {
  firstName(['n', 'given']),
  lastName(['n', 'surname']),
  email(['email', 'type', 'work']),
  mobile(['tel', 'type', 'cell']),
  profilePic(['photo']),
  meetingplaceIdentityCardColor(['x-meetingplace-identity-card-color']);

  const ContactCardPaths(this.paths);
  final List<String> paths;
}

class ContactCardUtils {
  static String getPathValue(
    Map<dynamic, dynamic> contactInfo,
    List<String> pathKeys, {
    String defaultValue = '',
  }) {
    if (pathKeys.isEmpty) return defaultValue;

    var parentElement = contactInfo;
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

  static void setPathValue(
    Map<dynamic, dynamic> contactInfo,
    List<String> pathKeys,
    String value,
  ) {
    if (pathKeys.isEmpty) return;

    var parentElement = contactInfo;
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

  static bool hasProfilePic(Map<dynamic, dynamic> contactInfo) {
    final pic = getPathValue(contactInfo, ContactCardPaths.profilePic.paths);
    return pic.isNotEmpty;
  }

  static ImageProvider<Object> getImage(
    Map<dynamic, dynamic> contactInfo, {
    required BaseCacheManager cacheManager,
  }) {
    return hasProfilePic(contactInfo)
        ? CachedBase64Image(
            getPathValue(contactInfo, ContactCardPaths.profilePic.paths),
            cacheManager: cacheManager,
          )
        : defaultProfileImage;
  }

  static String getFullName(Map<dynamic, dynamic> contactInfo) {
    final firstName =
        getPathValue(contactInfo, ContactCardPaths.firstName.paths);
    final lastName = getPathValue(contactInfo, ContactCardPaths.lastName.paths);
    return [firstName, lastName].nonEmpty.join(' ');
  }

  /// Creates a domain ContactCard from an SDK ContactCard
  static ContactCard fromSdkContactCard(sdk.ContactCard sdkCard) {
    final values = sdkCard.contactInfo;
    final firstName = getPathValue(values, ContactCardPaths.firstName.paths);
    final lastName = getPathValue(values, ContactCardPaths.lastName.paths);
    final email = getPathValue(values, ContactCardPaths.email.paths);
    final mobile = getPathValue(values, ContactCardPaths.mobile.paths);
    final profilePic = getPathValue(values, ContactCardPaths.profilePic.paths);
    final color = getPathValue(
      values,
      ContactCardPaths.meetingplaceIdentityCardColor.paths,
    );

    return ContactCard(
      id: const uuid.Uuid().v4(),
      did: sdkCard.did,
      type: sdkCard.type,
      firstName: firstName,
      displayName: getFullName(values),
      lastName: lastName.isEmpty ? null : lastName,
      email: email.isEmpty ? null : email,
      mobile: mobile.isEmpty ? null : mobile,
      profilePic: profilePic.isEmpty ? null : profilePic,
      cardColor: color.isEmpty ? null : color,
    );
  }
}

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

  /// Last name or empty string for fallback.
  String get lastNameOrEmpty => lastName ?? '';

  sdk.ContactCard toSdkContactCard() {
    return sdk.ContactCard(
      did: did,
      type: type,
      contactInfo: {
        'n': {
          'given': firstName,
          'surname': (lastName ?? ''),
        },
        'email': {
          'type': {
            'work': (email ?? ''),
          },
        },
        'tel': {
          'type': {
            'cell': (mobile ?? ''),
          },
        },
        'photo': (profilePic ?? ''),
        'x-meetingplace-identity-card-color': (cardColor ?? ''),
      },
    );
  }
}

/// Extension methods on SDK ContactCard for convenient access to fields.
extension SdkContactCardFields on sdk.ContactCard {
  String get firstName => ContactCardUtils.getPathValue(
        contactInfo,
        ContactCardPaths.firstName.paths,
      );
  set firstName(String value) => ContactCardUtils.setPathValue(
        contactInfo,
        ContactCardPaths.firstName.paths,
        value,
      );

  String get lastName => ContactCardUtils.getPathValue(
        contactInfo,
        ContactCardPaths.lastName.paths,
      );
  set lastName(String value) => ContactCardUtils.setPathValue(
        contactInfo,
        ContactCardPaths.lastName.paths,
        value,
      );

  String get email => ContactCardUtils.getPathValue(
        contactInfo,
        ContactCardPaths.email.paths,
      );
  set email(String value) => ContactCardUtils.setPathValue(
        contactInfo,
        ContactCardPaths.email.paths,
        value,
      );

  String get mobile => ContactCardUtils.getPathValue(
        contactInfo,
        ContactCardPaths.mobile.paths,
      );
  set mobile(String value) => ContactCardUtils.setPathValue(
        contactInfo,
        ContactCardPaths.mobile.paths,
        value,
      );

  String get profilePic => ContactCardUtils.getPathValue(
        contactInfo,
        ContactCardPaths.profilePic.paths,
        defaultValue: '',
      );
  set profilePic(String value) => ContactCardUtils.setPathValue(
        contactInfo,
        ContactCardPaths.profilePic.paths,
        value,
      );

  String get meetingplaceIdentityCardColor => ContactCardUtils.getPathValue(
        contactInfo,
        ContactCardPaths.meetingplaceIdentityCardColor.paths,
      );
  set meetingplaceIdentityCardColor(String value) =>
      ContactCardUtils.setPathValue(
        contactInfo,
        ContactCardPaths.meetingplaceIdentityCardColor.paths,
        value,
      );

  bool get hasProfilePic => ContactCardUtils.hasProfilePic(contactInfo);

  ImageProvider<Object> image({required BaseCacheManager cacheManager}) =>
      ContactCardUtils.getImage(contactInfo, cacheManager: cacheManager);

  String get fullName => ContactCardUtils.getFullName(contactInfo);
}
