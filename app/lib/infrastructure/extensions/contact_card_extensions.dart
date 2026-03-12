import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:uuid/uuid.dart' as uuid;

import '../../domain/models/contact_card/contact_card.dart';
import '../../domain/models/contact_card/identity_field.dart';
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

class ContactCardMetadataPaths {
  static const profilePic = ['photo'];
  static const meetingplaceIdentityCardColor = [
    'x-meetingplace-identity-card-color',
  ];
}

extension IdentityFieldContactCardValue on IdentityField {
  String valueFrom(ContactCard card) => card.personaFields[key] ?? '';

  String? nullableValueFrom(ContactCard card) {
    final value = valueFrom(card).trim();
    if (!requiredValue && value.isEmpty) {
      return null;
    }

    return value;
  }

  ContactCard updateContactCard(ContactCard card, String value) {
    final nextValues = <String, String>{...card.personaFields};
    final trimmedValue = value.trim();

    if (requiredValue || trimmedValue.isNotEmpty) {
      nextValues[key] = trimmedValue;
    } else {
      nextValues.remove(key);
    }

    return card.copyWith(personaFields: nextValues);
  }
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
        final newNode = <dynamic, dynamic>{};
        parentElement[pathKey] = newNode;
        parentElement = newNode;
      } else if (elementAtPath is Map<dynamic, dynamic>) {
        parentElement = elementAtPath;
      }
    }

    parentElement[pathKeys.last] = value;
  }

  static bool hasProfilePic(Map<dynamic, dynamic> contactInfo) {
    final pic = getPathValue(contactInfo, ContactCardMetadataPaths.profilePic);
    return pic.isNotEmpty;
  }

  static ImageProvider<Object> getImage(
    Map<dynamic, dynamic> contactInfo, {
    required BaseCacheManager cacheManager,
  }) {
    return hasProfilePic(contactInfo)
        ? CachedBase64Image(
            getPathValue(contactInfo, ContactCardMetadataPaths.profilePic),
            cacheManager: cacheManager,
          )
        : defaultProfileImage;
  }

  static String getFullName(Map<dynamic, dynamic> contactInfo) {
    final values = identityFields
        .where((field) => field.usesInDisplayName)
        .map((field) => getPathValue(contactInfo, field.contactInfoPath));
    return values.nonEmpty.join(' ');
  }

  static String fullNameFromPersonaFields(Map<String, String> personaFields) {
    final values = identityFields
        .where((field) => field.usesInDisplayName)
        .map((field) => personaFields[field.key] ?? '');
    return values.nonEmpty.join(' ');
  }

  static Map<String, String> personaFieldsFromContactInfo(
    Map<dynamic, dynamic> contactInfo,
  ) {
    final values = <String, String>{};

    for (final field in identityFields) {
      final value = getPathValue(contactInfo, field.contactInfoPath);
      if (value.isNotEmpty) {
        values[field.key] = value;
      }
    }

    return values;
  }

  static ContactCard fromSdkContactCard(sdk.ContactCard sdkCard) {
    final values = sdkCard.contactInfo;
    final personaFields = personaFieldsFromContactInfo(values);
    final profilePic = getPathValue(
      values,
      ContactCardMetadataPaths.profilePic,
    );
    final color = getPathValue(
      values,
      ContactCardMetadataPaths.meetingplaceIdentityCardColor,
    );

    return ContactCard(
      id: const uuid.Uuid().v4(),
      did: sdkCard.did,
      type: sdkCard.type,
      displayName: fullNameFromPersonaFields(personaFields),
      personaFields: personaFields,
      profilePic: profilePic.isEmpty ? null : profilePic,
      cardColor: color.isEmpty ? null : color,
    );
  }
}

extension ContactCardExtensions on ContactCard {
  bool get hasProfilePic => profilePic != null && profilePic!.trim().isNotEmpty;

  String get firstName => firstNameField.valueFrom(this);

  String? get lastName => lastNameField.nullableValueFrom(this);

  String? get email => emailField.nullableValueFrom(this);

  String? get mobile => mobileField.nullableValueFrom(this);

  String get fullName =>
      ContactCardUtils.fullNameFromPersonaFields(personaFields);

  ImageProvider<Object> image({required BaseCacheManager cacheManager}) {
    if (!hasProfilePic) {
      return defaultProfileImage;
    }
    return CachedBase64Image(profilePic!, cacheManager: cacheManager);
  }

  String get mobilePhone => mobile ?? '';

  String get emailAddress => email ?? '';

  String get lastNameOrEmpty => lastName ?? '';

  String valueFor(IdentityField field) => field.valueFrom(this);

  Iterable<IdentityField> populatedFields({
    bool includeDisplayNameFields = true,
  }) sync* {
    for (final field in identityFields) {
      if (!includeDisplayNameFields && field.usesInDisplayName) {
        continue;
      }

      if (valueFor(field).isEmpty) {
        continue;
      }

      yield field;
    }
  }

  sdk.ContactCard toSdkContactCard() {
    final contactInfo = <String, dynamic>{
      'photo': (profilePic ?? ''),
      'x-meetingplace-identity-card-color': (cardColor ?? ''),
    };

    for (final field in identityFields) {
      ContactCardUtils.setPathValue(
        contactInfo,
        field.contactInfoPath,
        field.valueFrom(this),
      );
    }

    return sdk.ContactCard(did: did, type: type, contactInfo: contactInfo);
  }
}

extension SdkContactCardFields on sdk.ContactCard {
  String get firstName => ContactCardUtils.getPathValue(
    contactInfo,
    firstNameField.contactInfoPath,
  );
  set firstName(String value) => ContactCardUtils.setPathValue(
    contactInfo,
    firstNameField.contactInfoPath,
    value,
  );

  String get lastName =>
      ContactCardUtils.getPathValue(contactInfo, lastNameField.contactInfoPath);
  set lastName(String value) => ContactCardUtils.setPathValue(
    contactInfo,
    lastNameField.contactInfoPath,
    value,
  );

  String get email =>
      ContactCardUtils.getPathValue(contactInfo, emailField.contactInfoPath);
  set email(String value) => ContactCardUtils.setPathValue(
    contactInfo,
    emailField.contactInfoPath,
    value,
  );

  String get mobile =>
      ContactCardUtils.getPathValue(contactInfo, mobileField.contactInfoPath);
  set mobile(String value) => ContactCardUtils.setPathValue(
    contactInfo,
    mobileField.contactInfoPath,
    value,
  );

  String get profilePic => ContactCardUtils.getPathValue(
    contactInfo,
    ContactCardMetadataPaths.profilePic,
    defaultValue: '',
  );
  set profilePic(String value) => ContactCardUtils.setPathValue(
    contactInfo,
    ContactCardMetadataPaths.profilePic,
    value,
  );

  String get meetingplaceIdentityCardColor => ContactCardUtils.getPathValue(
    contactInfo,
    ContactCardMetadataPaths.meetingplaceIdentityCardColor,
  );
  set meetingplaceIdentityCardColor(String value) =>
      ContactCardUtils.setPathValue(
        contactInfo,
        ContactCardMetadataPaths.meetingplaceIdentityCardColor,
        value,
      );

  bool get hasProfilePic => ContactCardUtils.hasProfilePic(contactInfo);

  ImageProvider<Object> image({required BaseCacheManager cacheManager}) =>
      ContactCardUtils.getImage(contactInfo, cacheManager: cacheManager);

  String get fullName => ContactCardUtils.getFullName(contactInfo);

  String valueFor(IdentityField field) =>
      ContactCardUtils.getPathValue(contactInfo, field.contactInfoPath);

  Iterable<IdentityField> populatedFields({
    bool includeDisplayNameFields = true,
  }) sync* {
    for (final field in identityFields) {
      if (!includeDisplayNameFields && field.usesInDisplayName) {
        continue;
      }

      if (valueFor(field).isEmpty) {
        continue;
      }

      yield field;
    }
  }
}
