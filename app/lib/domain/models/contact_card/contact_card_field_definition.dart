import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/themes/app_custom_colors.dart';
import '../../../presentation/validators/max_length_validator_type.dart';
import '../../../presentation/validators/zalgo_text_validator.dart';
import 'contact_card.dart';

enum ContactCardFieldKey { firstName, lastName, email, mobile }

abstract class ContactCardFieldTags {
  static const String identityCard = 'identityCard';
  static const String searchable = 'searchable';
}

class ContactCardFieldDefinition {
  ContactCardFieldDefinition({
    required this.key,
    required this.icon,
    required this.iconColor,
    this.tags = const [],
    required this.keyboardType,
    required this.textCapitalization,
    required this.autocorrect,
    required this.autofocus,
    required this.shouldValidateOnBlur,
    required this.textInputAction,
    required this.placeholder,
    required List<FieldValidator> Function(BuildContext context) validators,
    required this.jsonPath,
    required this.nullWhenEmpty,
    required String? Function(ContactCard) valueAccessor,
    required ContactCard Function(ContactCard, String?) updateCard,
  }) : _valueAccessor = valueAccessor,
       _updateCard = updateCard,
       _validatorsBuilder = validators;

  final ContactCardFieldKey key;
  final IconData icon;
  final Color Function(AppCustomColors customColors, ColorScheme colorScheme)
  iconColor;
  final List<String> tags;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool autofocus;
  final bool shouldValidateOnBlur;
  final TextInputAction textInputAction;
  final String Function(AppLocalizations l10n) placeholder;
  final List<FieldValidator> Function(BuildContext context) _validatorsBuilder;
  final List<String> jsonPath;
  final bool nullWhenEmpty;
  final String? Function(ContactCard) _valueAccessor;
  final ContactCard Function(ContactCard, String?) _updateCard;

  bool hasTag(String tag) => tags.contains(tag);

  String get name => key.name;

  String label(AppLocalizations l10n) => l10n.contactCardFieldName(name);

  MultiValidator validator(BuildContext context) =>
      MultiValidator(_validatorsBuilder(context));

  String valueFrom(ContactCard card) => _valueAccessor(card) ?? '';

  String sdkValueFrom(sdk.ContactCard card) {
    return _sdkPathValue(card.contactInfo, jsonPath);
  }

  String? nullableValueFrom(ContactCard card) => _valueAccessor(card);

  ContactCard updateContactCard(ContactCard card, String value) {
    return _updateCard(card, _normalize(value));
  }

  ContactCard hydrateContactCard(ContactCard card, String? value) {
    return _updateCard(card, _normalize(value));
  }

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
      keyboardType: null,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: true,
      autofocus: false,
      shouldValidateOnBlur: false,
      textInputAction: TextInputAction.next,
      placeholder: (l10n) => l10n.enterFirstName,
      validators: (context) => [
        ZalgoTextValidator(errorText: context.l10n.zalgoTextDetectedError),
        MaxLengthValidator(
          MaxLengthValidatorType.medium.value,
          errorText: context.l10n.nameTooLong,
        ),
      ],
      jsonPath: const ['n', 'given'],
      nullWhenEmpty: false,
      valueAccessor: (card) => card.firstName,
      updateCard: (card, value) => card.copyWith(firstName: value ?? ''),
      tags: const [ContactCardFieldTags.searchable],
    ),
    ContactCardFieldDefinition(
      key: ContactCardFieldKey.lastName,
      icon: Icons.badge,
      iconColor: (customColors, colorScheme) => customColors.purple,
      keyboardType: null,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: true,
      autofocus: false,
      shouldValidateOnBlur: false,
      textInputAction: TextInputAction.next,
      placeholder: (l10n) => l10n.enterLastName,
      validators: (context) => [
        ZalgoTextValidator(errorText: context.l10n.zalgoTextDetectedError),
        MaxLengthValidator(
          MaxLengthValidatorType.medium.value,
          errorText: context.l10n.nameTooLong,
        ),
      ],
      jsonPath: const ['n', 'surname'],
      nullWhenEmpty: true,
      valueAccessor: (card) => card.lastName,
      updateCard: (card, value) => card.copyWith(lastName: value),
      tags: const [ContactCardFieldTags.searchable],
    ),
    ContactCardFieldDefinition(
      key: ContactCardFieldKey.email,
      icon: Icons.email,
      iconColor: (customColors, colorScheme) => customColors.warning,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      autofocus: false,
      shouldValidateOnBlur: true,
      textInputAction: TextInputAction.next,
      placeholder: (l10n) => l10n.enterEmail,
      validators: (context) => [
        EmailValidator(errorText: context.l10n.invalidEmail),
        MaxLengthValidator(
          MaxLengthValidatorType.large.value,
          errorText: context.l10n.emailTooLong,
        ),
      ],
      jsonPath: const ['email', 'type', 'work'],
      nullWhenEmpty: true,
      valueAccessor: (card) => card.email,
      updateCard: (card, value) => card.copyWith(email: value),
      tags: const [
        ContactCardFieldTags.identityCard,
        ContactCardFieldTags.searchable,
      ],
    ),
    ContactCardFieldDefinition(
      key: ContactCardFieldKey.mobile,
      icon: Icons.phone,
      iconColor: (customColors, colorScheme) => colorScheme.primary,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      autofocus: false,
      shouldValidateOnBlur: true,
      textInputAction: TextInputAction.next,
      placeholder: (l10n) => l10n.enterMobile,
      validators: (_) => [],
      jsonPath: const ['tel', 'type', 'cell'],
      nullWhenEmpty: true,
      valueAccessor: (card) => card.mobile,
      updateCard: (card, value) => card.copyWith(mobile: value),
      tags: const [
        ContactCardFieldTags.identityCard,
        ContactCardFieldTags.searchable,
      ],
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
