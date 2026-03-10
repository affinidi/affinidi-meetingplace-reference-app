import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../domain/models/contact_card/contact_card.dart';
import '../../infrastructure/extensions/contact_card_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../themes/app_custom_colors.dart';
import '../validators/input_validators.dart';

enum PersonaField {
  firstName,
  lastName,
  email,
  mobile;

  IconData get icon {
    switch (this) {
      case PersonaField.firstName:
        return Icons.person;
      case PersonaField.lastName:
        return Icons.badge;
      case PersonaField.email:
        return Icons.email;
      case PersonaField.mobile:
        return Icons.phone;
    }
  }

  Color iconColor(AppCustomColors customColors, ColorScheme colorScheme) {
    switch (this) {
      case PersonaField.firstName:
        return customColors.success;
      case PersonaField.lastName:
        return customColors.purple;
      case PersonaField.email:
        return customColors.warning;
      case PersonaField.mobile:
        return colorScheme.primary;
    }
  }

  String label(AppLocalizations l10n) => l10n.contactCardFieldName(name);

  String placeholder(AppLocalizations l10n) {
    switch (this) {
      case PersonaField.firstName:
        return l10n.enterFirstName;
      case PersonaField.lastName:
        return l10n.enterLastName;
      case PersonaField.email:
        return l10n.enterEmail;
      case PersonaField.mobile:
        return l10n.enterMobile;
    }
  }

  InputType get inputType {
    switch (this) {
      case PersonaField.firstName:
        return InputType.firstName;
      case PersonaField.lastName:
        return InputType.lastName;
      case PersonaField.email:
        return InputType.email;
      case PersonaField.mobile:
        return InputType.phone;
    }
  }

  MultiValidator validator(BuildContext context) {
    return InputValidators.getValidator(context, inputType);
  }

  TextInputType? get keyboardType {
    switch (this) {
      case PersonaField.firstName:
        return null;
      case PersonaField.lastName:
        return null;
      case PersonaField.email:
        return TextInputType.emailAddress;
      case PersonaField.mobile:
        return TextInputType.phone;
    }
  }

  TextCapitalization get textCapitalization {
    switch (this) {
      case PersonaField.firstName:
      case PersonaField.lastName:
        return TextCapitalization.sentences;
      case PersonaField.email:
      case PersonaField.mobile:
        return TextCapitalization.none;
    }
  }

  bool get autocorrect {
    switch (this) {
      case PersonaField.firstName:
      case PersonaField.lastName:
        return true;
      case PersonaField.email:
      case PersonaField.mobile:
        return false;
    }
  }

  bool get autofocus => this == PersonaField.firstName;

  bool get shouldValidateOnBlur => this == PersonaField.email;

  TextInputAction get textInputAction => TextInputAction.next;

  String valueFrom(ContactCard card) {
    switch (this) {
      case PersonaField.firstName:
        return card.firstName;
      case PersonaField.lastName:
        return card.lastName ?? '';
      case PersonaField.email:
        return card.email ?? '';
      case PersonaField.mobile:
        return card.mobile ?? '';
    }
  }

  String sdkValueFrom(sdk.ContactCard card) {
    switch (this) {
      case PersonaField.firstName:
        return card.firstName;
      case PersonaField.lastName:
        return card.lastName;
      case PersonaField.email:
        return card.email;
      case PersonaField.mobile:
        return card.mobile;
    }
  }

  ContactCard updateContactCard(ContactCard card, String value) {
    switch (this) {
      case PersonaField.firstName:
        return card.copyWith(firstName: value);
      case PersonaField.lastName:
        return card.copyWith(lastName: value.isEmpty ? null : value);
      case PersonaField.email:
        return card.copyWith(email: value.isEmpty ? null : value);
      case PersonaField.mobile:
        return card.copyWith(mobile: value.isEmpty ? null : value);
    }
  }
}
