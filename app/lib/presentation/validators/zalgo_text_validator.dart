import 'package:form_field_validator/form_field_validator.dart';

class ZalgoTextValidator extends TextFieldValidator {
  ZalgoTextValidator({required String errorText}) : super(errorText);

  @override
  bool isValid(String? value) {
    if (value == null || value.isEmpty) return true;

    return !RegExp(r'(.)[\u0300-\u036F]{2,}').hasMatch(value);
  }
}
