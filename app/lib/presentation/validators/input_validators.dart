import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../presentation/validators/max_length_validator_type.dart';
import '../../presentation/validators/zalgo_text_validator.dart';

enum InputType {
  firstName,
  lastName,
  description,
  email,
  phone,
  postcode,
  alias,
  chat,
}

class InputValidators {
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
        // TODO: Use Intl Phone Number Input for validation
        return MultiValidator([]);
      case InputType.postcode:
        return MultiValidator([
          MaxLengthValidator(
            MaxLengthValidatorType.small.value,
            errorText: context.l10n.nameTooLong,
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
