enum IdentityFieldIconKey { person, badge, email, phone }

enum IdentityFieldColorKey { success, purple, warning, primary }

enum IdentityFieldInputKind { firstName, lastName, email, phone }

abstract base class IdentityField {
  const IdentityField({
    required this.key,
    required this.columnName,
    required this.contactInfoPath,
    required this.requiredValue,
    this.usesInDisplayName = false,
    this.showsInIdentityCardSummary = false,
    required this.iconKey,
    required this.colorKey,
    required this.inputKind,
    this.autofocus = false,
    this.shouldValidateOnBlur = false,
  });

  final String key;
  final String columnName;
  final List<String> contactInfoPath;
  final bool requiredValue;
  final bool usesInDisplayName;
  final bool showsInIdentityCardSummary;
  final IdentityFieldIconKey iconKey;
  final IdentityFieldColorKey colorKey;
  final IdentityFieldInputKind inputKind;
  final bool autofocus;
  final bool shouldValidateOnBlur;
}

final class FirstNameIdentityField extends IdentityField {
  const FirstNameIdentityField()
    : super(
        key: 'firstName',
        columnName: 'first_name',
        contactInfoPath: const ['n', 'given'],
        requiredValue: true,
        usesInDisplayName: true,
        iconKey: IdentityFieldIconKey.person,
        colorKey: IdentityFieldColorKey.success,
        inputKind: IdentityFieldInputKind.firstName,
        autofocus: true,
      );
}

final class LastNameIdentityField extends IdentityField {
  const LastNameIdentityField()
    : super(
        key: 'lastName',
        columnName: 'last_name',
        contactInfoPath: const ['n', 'surname'],
        requiredValue: false,
        usesInDisplayName: true,
        iconKey: IdentityFieldIconKey.badge,
        colorKey: IdentityFieldColorKey.purple,
        inputKind: IdentityFieldInputKind.lastName,
      );
}

final class EmailIdentityField extends IdentityField {
  const EmailIdentityField()
    : super(
        key: 'email',
        columnName: 'email',
        contactInfoPath: const ['email', 'type', 'work'],
        requiredValue: false,
        showsInIdentityCardSummary: true,
        iconKey: IdentityFieldIconKey.email,
        colorKey: IdentityFieldColorKey.warning,
        inputKind: IdentityFieldInputKind.email,
        shouldValidateOnBlur: true,
      );
}

final class MobileIdentityField extends IdentityField {
  const MobileIdentityField()
    : super(
        key: 'mobile',
        columnName: 'mobile',
        contactInfoPath: const ['tel', 'type', 'cell'],
        requiredValue: false,
        showsInIdentityCardSummary: true,
        iconKey: IdentityFieldIconKey.phone,
        colorKey: IdentityFieldColorKey.primary,
        inputKind: IdentityFieldInputKind.phone,
      );
}

const firstNameField = FirstNameIdentityField();
const lastNameField = LastNameIdentityField();
const emailField = EmailIdentityField();
const mobileField = MobileIdentityField();

const identityFields = <IdentityField>[
  firstNameField,
  lastNameField,
  emailField,
  mobileField,
];

IdentityField? identityFieldByKey(String key) {
  for (final field in identityFields) {
    if (field.key == key) {
      return field;
    }
  }

  return null;
}
