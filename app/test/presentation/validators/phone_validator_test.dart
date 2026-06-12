import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/presentation/validators/input_validators.dart';

void main() {
  const errorText = 'Invalid phone number';

  PhoneValidator makeValidator({
    bool? isPhoneValid,
    bool hasTouchedPhone = false,
  }) => PhoneValidator(
    errorText: errorText,
    isPhoneValid: isPhoneValid,
    hasTouchedPhone: hasTouchedPhone,
  );

  group('PhoneValidator', () {
    group('when the field has not been touched', () {
      test('returns null for empty input', () {
        expect(makeValidator().call(''), isNull);
      });

      test('returns null for non-empty input — untouched skips validation', () {
        expect(makeValidator().call('+4915112345678'), isNull);
      });

      test('returns null even when isPhoneValid is false', () {
        expect(makeValidator(isPhoneValid: false).call('+1'), isNull);
      });

      test('returns null when isPhoneValid is null', () {
        expect(makeValidator(isPhoneValid: null).call('+1'), isNull);
      });
    });

    group('when the field has been touched', () {
      test('returns null for empty input — empty is always valid', () {
        expect(makeValidator(hasTouchedPhone: true).call(''), isNull);
      });

      test('returns null when isPhoneValid is true', () {
        expect(
          makeValidator(
            isPhoneValid: true,
            hasTouchedPhone: true,
          ).call('+4915112345678'),
          isNull,
        );
      });

      test('returns errorText when isPhoneValid is false', () {
        expect(
          makeValidator(isPhoneValid: false, hasTouchedPhone: true).call('+1'),
          errorText,
        );
      });

      test('returns errorText when isPhoneValid is null', () {
        expect(
          makeValidator(
            isPhoneValid: null,
            hasTouchedPhone: true,
          ).call('+1234'),
          errorText,
        );
      });
    });
  });
}
