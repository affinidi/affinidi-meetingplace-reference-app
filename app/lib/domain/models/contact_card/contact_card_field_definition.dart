import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/map_path_extensions.dart';
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

typedef ContactCardFieldColor =
    Color Function(AppCustomColors customColors, ColorScheme colorScheme);
typedef ContactCardFieldPlaceholder = String Function(AppLocalizations l10n);
typedef ContactCardFieldValidators =
    List<FieldValidator> Function(BuildContext context);
typedef ContactCardFieldValueAccessor = String? Function(ContactCard card);
typedef ContactCardFieldUpdater =
    ContactCard Function(ContactCard card, String? value);

class ContactCardFieldDefinition {
  ContactCardFieldDefinition({
    required this.key,
    required this.icon,
    required this.iconColor,
    this.tags = const [],
    required this.keyboardType,
    required this.textCapitalization,
    required this.autocorrect,
    this.autofocus = false,
    required this.shouldValidateOnBlur,
    required this.textInputAction,
    required this.placeholder,
    required this._validators,
    required this.jsonPath,
    required this.nullWhenEmpty,
    required this._valueAccessor,
    required this._updateCard,
  });

  final ContactCardFieldKey key;
  final IconData icon;
  final ContactCardFieldColor iconColor;
  final List<String> tags;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool autofocus;
  final bool shouldValidateOnBlur;
  final TextInputAction textInputAction;
  final ContactCardFieldPlaceholder placeholder;
  final ContactCardFieldValidators _validators;
  final List<String> jsonPath;
  final bool nullWhenEmpty;
  final ContactCardFieldValueAccessor _valueAccessor;
  final ContactCardFieldUpdater _updateCard;

  bool hasTag(String tag) => tags.contains(tag);

  String get name => key.name;

  String label(AppLocalizations l10n) => l10n.contactCardFieldName(name);

  MultiValidator validator(BuildContext context) =>
      MultiValidator(_validators(context));

  String valueFrom(ContactCard card) => _valueAccessor(card) ?? '';

  String sdkValueFrom(sdk.ContactCard card) {
    return card.contactInfo.getPathValue(jsonPath);
  }

  String? nullableValueFrom(ContactCard card) => _valueAccessor(card);

  ContactCard updateContactCard(ContactCard card, String? value) {
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
  static final List<ContactCardFieldDefinition> values = List.unmodifiable([
    ContactCardFieldDefinition(
      key: ContactCardFieldKey.firstName,
      icon: Icons.person,
      iconColor: (customColors, colorScheme) => Colors.blue,
      keyboardType: null,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: true,
      autofocus: true,
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
      iconColor: (customColors, colorScheme) => Colors.blue,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
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
      iconColor: (customColors, colorScheme) => Colors.green,
      keyboardType: TextInputType.phone,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
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
  ]);

  static final _byKey = {for (final field in values) field.key: field};

  static ContactCardFieldDefinition byKey(ContactCardFieldKey key) {
    final field = _byKey[key];
    if (field == null) {
      throw AppException(
        'Missing ContactCard field definition for $key',
        code: AppExceptionType.missingContactCardFieldDefinition.name,
      );
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
      updatedCard = field.updateContactCard(
        updatedCard,
        fieldValues[field.key],
      );
    }
    return updatedCard;
  }
}
