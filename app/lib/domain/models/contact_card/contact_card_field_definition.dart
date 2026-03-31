import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../../l10n/app_localizations.dart';
import '../../../presentation/themes/app_custom_colors.dart';
import '../../../presentation/validators/input_validators.dart';
import 'contact_card.dart';

enum ContactCardFieldKey { firstName, lastName, email, mobile, postcode }

class ContactCardFieldDefinition {
  ContactCardFieldDefinition({
    required this.key,
    required this.icon,
    required this.iconColor,
    required this.inputType,
    required this.keyboardType,
    required this.textCapitalization,
    required this.autocorrect,
    required this.autofocus,
    required this.shouldValidateOnBlur,
    required this.textInputAction,
    required this.placeholder,
    required this.sdkPath,
    required this.identitiesColumnName,
    required this.contactsColumnName,
    required this.nullWhenEmpty,
    required String? Function(ContactCard) valueAccessor,
    required ContactCard Function(ContactCard, String?) updateCard,
  }) : _valueAccessor = valueAccessor,
       _updateCard = updateCard;

  final ContactCardFieldKey key;
  final IconData icon;
  final Color Function(AppCustomColors customColors, ColorScheme colorScheme)
  iconColor;
  final InputType inputType;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool autofocus;
  final bool shouldValidateOnBlur;
  final TextInputAction textInputAction;
  final String Function(AppLocalizations l10n) placeholder;
  final List<String> sdkPath;
  final String identitiesColumnName;
  final String contactsColumnName;
  final bool nullWhenEmpty;
  final String? Function(ContactCard) _valueAccessor;
  final ContactCard Function(ContactCard, String?) _updateCard;

  String get name => key.name;

  String label(AppLocalizations l10n) => l10n.contactCardFieldName(name);

  MultiValidator validator(BuildContext context) =>
      InputValidators.getValidator(context, inputType);

  String valueFrom(ContactCard card) => _valueAccessor(card) ?? '';

  String sdkValueFrom(sdk.ContactCard card) {
    return _sdkPathValue(card.contactInfo, sdkPath);
  }

  String? nullableValueFrom(ContactCard card) => _valueAccessor(card);

  ContactCard updateContactCard(ContactCard card, String value) {
    return _updateCard(card, _normalize(value));
  }

  ContactCard hydrateContactCard(ContactCard card, String? value) {
    return _updateCard(card, _normalize(value));
  }

  String valueForNonNullableStorage(ContactCard card) => valueFrom(card);

  String? _normalize(String? value) {
    if (nullWhenEmpty && (value == null || value.isEmpty)) {
      return null;
    }
    return value ?? '';
  }
}

class ContactCardFieldDefinitions {
  static final values = <ContactCardFieldDefinition>[
    ContactCardFieldDefinition(
      key: ContactCardFieldKey.firstName,
      icon: Icons.person,
      iconColor: (customColors, colorScheme) => customColors.success,
      inputType: InputType.firstName,
      keyboardType: null,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: true,
      autofocus: false,
      shouldValidateOnBlur: false,
      textInputAction: TextInputAction.next,
      placeholder: (l10n) => l10n.enterFirstName,
      sdkPath: const ['n', 'given'],
      identitiesColumnName: 'firstName',
      contactsColumnName: 'firstName',
      nullWhenEmpty: false,
      valueAccessor: _firstNameValue,
      updateCard: _updateFirstName,
    ),
    ContactCardFieldDefinition(
      key: ContactCardFieldKey.lastName,
      icon: Icons.badge,
      iconColor: (customColors, colorScheme) => customColors.purple,
      inputType: InputType.lastName,
      keyboardType: null,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: true,
      autofocus: false,
      shouldValidateOnBlur: false,
      textInputAction: TextInputAction.next,
      placeholder: (l10n) => l10n.enterLastName,
      sdkPath: const ['n', 'surname'],
      identitiesColumnName: 'lastName',
      contactsColumnName: 'lastName',
      nullWhenEmpty: true,
      valueAccessor: _lastNameValue,
      updateCard: _updateLastName,
    ),
    ContactCardFieldDefinition(
      key: ContactCardFieldKey.email,
      icon: Icons.email,
      iconColor: (customColors, colorScheme) => customColors.warning,
      inputType: InputType.email,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      autofocus: false,
      shouldValidateOnBlur: true,
      textInputAction: TextInputAction.next,
      placeholder: (l10n) => l10n.enterEmail,
      sdkPath: const ['email', 'type', 'work'],
      identitiesColumnName: 'email',
      contactsColumnName: 'email',
      nullWhenEmpty: true,
      valueAccessor: _emailValue,
      updateCard: _updateEmail,
    ),
    ContactCardFieldDefinition(
      key: ContactCardFieldKey.mobile,
      icon: Icons.phone,
      iconColor: (customColors, colorScheme) => colorScheme.primary,
      inputType: InputType.phone,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      autofocus: false,
      shouldValidateOnBlur: true,
      textInputAction: TextInputAction.next,
      placeholder: (l10n) => l10n.enterMobile,
      sdkPath: const ['tel', 'type', 'cell'],
      identitiesColumnName: 'mobile',
      contactsColumnName: 'mobile',
      nullWhenEmpty: true,
      valueAccessor: _mobileValue,
      updateCard: _updateMobile,
    ),
    ContactCardFieldDefinition(
      key: ContactCardFieldKey.postcode,
      icon: Icons.markunread_mailbox_outlined,
      iconColor: (customColors, colorScheme) => customColors.orange,
      inputType: InputType.postcode,
      keyboardType: TextInputType.streetAddress,
      textCapitalization: TextCapitalization.characters,
      autocorrect: false,
      autofocus: false,
      shouldValidateOnBlur: false,
      textInputAction: TextInputAction.next,
      placeholder: (l10n) => l10n.enterPostcode,
      sdkPath: const ['adr', 'postalCode'],
      identitiesColumnName: 'postcode',
      contactsColumnName: 'postcode',
      nullWhenEmpty: true,
      valueAccessor: _postcodeValue,
      updateCard: _updatePostcode,
    ),
  ];

  static List<ContactCardFieldDefinition> get editable => values;

  static final _byKey = {for (final field in values) field.key: field};

  static ContactCardFieldDefinition byKey(ContactCardFieldKey key) {
    final field = _byKey[key];
    if (field == null) {
      throw StateError('Missing ContactCard field definition for $key');
    }
    return field;
  }

  static Map<ContactCardFieldKey, String?> valuesFromCard(ContactCard card) {
    return {
      for (final field in values) field.key: field.nullableValueFrom(card),
    };
  }

  static Map<ContactCardFieldKey, String> nonNullableValuesFromCard(
    ContactCard card,
  ) {
    return {
      for (final field in values)
        field.key: field.valueForNonNullableStorage(card),
    };
  }

  static ContactCard applyFieldValues(
    ContactCard card,
    Map<ContactCardFieldKey, String?> fieldValues,
  ) {
    var updatedCard = card;
    for (final field in values) {
      updatedCard = field.hydrateContactCard(
        updatedCard,
        fieldValues[field.key],
      );
    }
    return updatedCard;
  }

  static ContactCardFieldDefinition get firstName =>
      byKey(ContactCardFieldKey.firstName);

  static ContactCardFieldDefinition get lastName =>
      byKey(ContactCardFieldKey.lastName);

  static ContactCardFieldDefinition get email =>
      byKey(ContactCardFieldKey.email);

  static ContactCardFieldDefinition get mobile =>
      byKey(ContactCardFieldKey.mobile);

  static ContactCardFieldDefinition get postcode =>
      byKey(ContactCardFieldKey.postcode);
}

String _sdkPathValue(Map<dynamic, dynamic> contactInfo, List<String> pathKeys) {
  if (pathKeys.isEmpty) return '';

  var parentElement = contactInfo;
  for (final pathKey in pathKeys) {
    final elementAtPath = parentElement[pathKey];
    if (elementAtPath == null) {
      return '';
    }

    if ((pathKey == pathKeys.last) && elementAtPath is String) {
      return elementAtPath;
    }

    if (elementAtPath is Map<dynamic, dynamic>) {
      parentElement = elementAtPath;
    }
  }

  return '';
}

String? _firstNameValue(ContactCard card) => card.firstName;

String? _lastNameValue(ContactCard card) => card.lastName;

String? _emailValue(ContactCard card) => card.email;

String? _mobileValue(ContactCard card) => card.mobile;

String? _postcodeValue(ContactCard card) => card.postcode;

ContactCard _updateFirstName(ContactCard card, String? value) {
  return card.copyWith(firstName: value ?? '');
}

ContactCard _updateLastName(ContactCard card, String? value) {
  return card.copyWith(lastName: value);
}

ContactCard _updateEmail(ContactCard card, String? value) {
  return card.copyWith(email: value);
}

ContactCard _updateMobile(ContactCard card, String? value) {
  return card.copyWith(mobile: value);
}

ContactCard _updatePostcode(ContactCard card, String? value) {
  return card.copyWith(postcode: value);
}
