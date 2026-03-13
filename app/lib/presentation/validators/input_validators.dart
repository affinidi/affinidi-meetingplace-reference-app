import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../presentation/validators/max_length_validator_type.dart';
import '../../presentation/validators/zalgo_text_validator.dart';

enum InputType { firstName, lastName, description, email, phone, alias, chat }

class InputValidators {
  static String defaultPhoneIsoCode([BuildContext? context]) {
    final locales = <Locale?>[
      if (context != null) Localizations.maybeLocaleOf(context),
      ...WidgetsBinding.instance.platformDispatcher.locales,
    ];

    for (final locale in locales) {
      final countryCode = locale?.countryCode;
      if (countryCode != null && countryCode.length == 2) {
        return countryCode.toUpperCase();
      }
    }

    return 'US';
  }

  static Future<String?> normalizePhoneNumber(
    String value, {
    String? isoCode,
  }) async {
    final trimmedValue = value.trim();

    if (trimmedValue.isEmpty) {
      return null;
    }

    try {
      final normalizedPhoneNumber =
          await PhoneNumber.getRegionInfoFromPhoneNumber(
            trimmedValue,
            (isoCode?.trim().isNotEmpty ?? false)
                ? isoCode!.trim().toUpperCase()
                : defaultPhoneIsoCode(),
          );

      return normalizedPhoneNumber.phoneNumber;
    } on Exception {
      return null;
    }
  }

  static String? phoneValidationError(
    BuildContext context, {
    required String? value,
    required bool isPhoneNumberValid,
    required bool isValidationPending,
  }) {
    final baseValidationError = getValidator(
      context,
      InputType.phone,
    ).call(value);

    if (baseValidationError != null) {
      return baseValidationError;
    }

    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (isValidationPending || !isPhoneNumberValid) {
      return context.l10n.invalidMobileNumber;
    }

    return null;
  }

  static MultiValidator getValidator(
    BuildContext context,
    InputType inputType,
  ) {
    switch (inputType) {
      case InputType.firstName:
        return MultiValidator([
          ZalgoTextValidator(errorText: context.l10n.zalgoTextDetectedError),
          MaxLengthValidator(
            MaxLengthValidatorType.medium.value,
            errorText: context.l10n.nameTooLong,
          ),
        ]);
      case InputType.lastName:
        return MultiValidator([
          ZalgoTextValidator(errorText: context.l10n.zalgoTextDetectedError),
          MaxLengthValidator(
            MaxLengthValidatorType.medium.value,
            errorText: context.l10n.nameTooLong,
          ),
        ]);
      case InputType.description:
        return MultiValidator([
          ZalgoTextValidator(errorText: context.l10n.zalgoTextDetectedError),
          MaxLengthValidator(
            MaxLengthValidatorType.large.value,
            errorText: context.l10n.descriptionTooLong,
          ),
        ]);
      case InputType.email:
        return MultiValidator([
          EmailValidator(errorText: context.l10n.invalidEmail),
          MaxLengthValidator(
            MaxLengthValidatorType.large.value,
            errorText: context.l10n.emailTooLong,
          ),
        ]);
      case InputType.phone:
        return MultiValidator([
          MaxLengthValidator(
            MaxLengthValidatorType.medium.value,
            errorText: context.l10n.mobileTooLong,
          ),
        ]);
      case InputType.alias:
        return MultiValidator([
          ZalgoTextValidator(errorText: context.l10n.zalgoTextDetectedError),
          MaxLengthValidator(
            MaxLengthValidatorType.small.value,
            errorText: context.l10n.aliasTooLong,
          ),
        ]);
      case InputType.chat:
        return MultiValidator([
          ZalgoTextValidator(errorText: context.l10n.zalgoTextDetectedError),
          MaxLengthValidator(
            MaxLengthValidatorType.extraLong.value,
            errorText: context.l10n.chatTooLong,
          ),
        ]);
    }
  }
}
