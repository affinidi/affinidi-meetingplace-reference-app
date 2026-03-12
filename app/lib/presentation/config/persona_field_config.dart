import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../domain/models/contact_card/identity_field.dart';
import '../../infrastructure/extensions/contact_card_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../themes/app_custom_colors.dart';
import '../validators/input_validators.dart';

extension IdentityFieldPresentation on IdentityField {
  IconData get icon {
    switch (iconKey) {
      case IdentityFieldIconKey.person:
        return Icons.person;
      case IdentityFieldIconKey.badge:
        return Icons.badge;
      case IdentityFieldIconKey.email:
        return Icons.email;
      case IdentityFieldIconKey.phone:
        return Icons.phone;
    }
  }

  Color iconColor(AppCustomColors customColors, ColorScheme colorScheme) {
    switch (colorKey) {
      case IdentityFieldColorKey.success:
        return customColors.success;
      case IdentityFieldColorKey.purple:
        return customColors.purple;
      case IdentityFieldColorKey.warning:
        return customColors.warning;
      case IdentityFieldColorKey.primary:
        return colorScheme.primary;
    }
  }

  String label(AppLocalizations l10n) => l10n.contactCardFieldName(key);

  String placeholder(AppLocalizations l10n) => label(l10n);

  InputType get inputType {
    switch (inputKind) {
      case IdentityFieldInputKind.firstName:
        return InputType.firstName;
      case IdentityFieldInputKind.lastName:
        return InputType.lastName;
      case IdentityFieldInputKind.email:
        return InputType.email;
      case IdentityFieldInputKind.phone:
        return InputType.phone;
    }
  }

  MultiValidator validator(BuildContext context) {
    return InputValidators.getValidator(context, inputType);
  }

  TextInputType? get keyboardType {
    switch (inputKind) {
      case IdentityFieldInputKind.firstName:
      case IdentityFieldInputKind.lastName:
        return null;
      case IdentityFieldInputKind.email:
        return TextInputType.emailAddress;
      case IdentityFieldInputKind.phone:
        return TextInputType.phone;
    }
  }

  TextCapitalization get textCapitalization {
    switch (inputKind) {
      case IdentityFieldInputKind.firstName:
      case IdentityFieldInputKind.lastName:
        return TextCapitalization.sentences;
      case IdentityFieldInputKind.email:
      case IdentityFieldInputKind.phone:
        return TextCapitalization.none;
    }
  }

  bool get autocorrect {
    switch (inputKind) {
      case IdentityFieldInputKind.firstName:
      case IdentityFieldInputKind.lastName:
        return true;
      case IdentityFieldInputKind.email:
      case IdentityFieldInputKind.phone:
        return false;
    }
  }

  TextInputAction get textInputAction => TextInputAction.next;

  String sdkValueFrom(sdk.ContactCard card) {
    return ContactCardUtils.getPathValue(card.contactInfo, contactInfoPath);
  }
}
