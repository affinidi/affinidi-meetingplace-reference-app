import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:uuid/uuid.dart' as uuid;

import '../../domain/models/contact_card/contact_card.dart';
import '../../domain/models/contact_card/contact_card_field_definition.dart';
import '../../presentation/painting/cached_base64_image.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import 'string_list_extensions.dart';

enum ContactCardType {
  individual('individual'),
  aiAgent('ai-agent');

  const ContactCardType(this.value);
  final String value;

  static ContactCardType? fromString(String value) {
    for (final type in ContactCardType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

const _profilePicPath = ['photo'];
const _meetingPlaceIdentityCardColorPath = [
  'x-meetingplace-identity-card-color',
];

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
    final pic = getPathValue(contactInfo, _profilePicPath);
    return pic.isNotEmpty;
  }

  static ImageProvider<Object> getImage(
    Map<dynamic, dynamic> contactInfo, {
    required BaseCacheManager cacheManager,
  }) {
    return hasProfilePic(contactInfo)
        ? CachedBase64Image(
            getPathValue(contactInfo, _profilePicPath),
            cacheManager: cacheManager,
          )
        : defaultProfileImage;
  }

  static String getFullName(Map<dynamic, dynamic> contactInfo) {
    final firstName = getPathValue(
      contactInfo,
      ContactCardFieldDefinitions.byKey(ContactCardFieldKey.firstName).sdkPath,
    );
    final lastName = getPathValue(
      contactInfo,
      ContactCardFieldDefinitions.byKey(ContactCardFieldKey.lastName).sdkPath,
    );
    return [firstName, lastName].nonEmpty.join(' ');
  }

  /// Creates a domain ContactCard from an SDK ContactCard
  static ContactCard fromSdkContactCard(sdk.ContactCard sdkCard) {
    final values = sdkCard.contactInfo;
    var card = ContactCard(
      id: const uuid.Uuid().v4(),
      did: sdkCard.did,
      type: sdkCard.type,
      firstName: '',
      displayName: '',
    );

    for (final field in ContactCardFieldDefinitions.editable) {
      card = field.updateContactCard(card, getPathValue(values, field.sdkPath));
    }

    final profilePic = getPathValue(values, _profilePicPath);
    final color = getPathValue(values, _meetingPlaceIdentityCardColorPath);

    return card.copyWith(
      displayName: card.fullName,
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
    final contactInfo = <String, dynamic>{};
    for (final field in ContactCardFieldDefinitions.editable) {
      ContactCardUtils.setPathValue(
        contactInfo,
        field.sdkPath,
        field.valueFrom(this),
      );
    }
    ContactCardUtils.setPathValue(
      contactInfo,
      _profilePicPath,
      profilePic ?? '',
    );
    ContactCardUtils.setPathValue(
      contactInfo,
      _meetingPlaceIdentityCardColorPath,
      cardColor ?? '',
    );

    return sdk.ContactCard(did: did, type: type, contactInfo: contactInfo);
  }
}

/// Extension methods on SDK ContactCard for convenient access to fields.
extension SdkContactCardFields on sdk.ContactCard {
  String valueForField(ContactCardFieldKey key) {
    final field = ContactCardFieldDefinitions.byKey(key);
    return ContactCardUtils.getPathValue(contactInfo, field.sdkPath);
  }

  void setValueForField(ContactCardFieldKey key, String value) {
    final field = ContactCardFieldDefinitions.byKey(key);
    ContactCardUtils.setPathValue(contactInfo, field.sdkPath, value);
  }

  String get firstName => ContactCardUtils.getPathValue(
    contactInfo,
    ContactCardFieldDefinitions.byKey(ContactCardFieldKey.firstName).sdkPath,
  );
  set firstName(String value) =>
      setValueForField(ContactCardFieldKey.firstName, value);

  String get lastName => ContactCardUtils.getPathValue(
    contactInfo,
    ContactCardFieldDefinitions.byKey(ContactCardFieldKey.lastName).sdkPath,
  );
  set lastName(String value) =>
      setValueForField(ContactCardFieldKey.lastName, value);

  String get email => valueForField(ContactCardFieldKey.email);
  set email(String value) => setValueForField(ContactCardFieldKey.email, value);

  String get mobile => valueForField(ContactCardFieldKey.mobile);
  set mobile(String value) =>
      setValueForField(ContactCardFieldKey.mobile, value);

  String get postcode => valueForField(ContactCardFieldKey.postcode);
  set postcode(String value) =>
      setValueForField(ContactCardFieldKey.postcode, value);

  String get profilePic => ContactCardUtils.getPathValue(
    contactInfo,
    _profilePicPath,
    defaultValue: '',
  );
  set profilePic(String value) =>
      ContactCardUtils.setPathValue(contactInfo, _profilePicPath, value);

  String get meetingplaceIdentityCardColor => ContactCardUtils.getPathValue(
    contactInfo,
    _meetingPlaceIdentityCardColorPath,
  );
  set meetingplaceIdentityCardColor(String value) =>
      ContactCardUtils.setPathValue(
        contactInfo,
        _meetingPlaceIdentityCardColorPath,
        value,
      );

  bool get hasProfilePic => ContactCardUtils.hasProfilePic(contactInfo);

  ImageProvider<Object> image({required BaseCacheManager cacheManager}) =>
      ContactCardUtils.getImage(contactInfo, cacheManager: cacheManager);

  String get fullName => ContactCardUtils.getFullName(contactInfo);
}
