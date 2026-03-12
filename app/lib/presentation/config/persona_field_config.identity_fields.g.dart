// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:drift/drift.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/identity_field.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

mixin GeneratedIdentityPersonaColumns on Table {
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get mobile => text().nullable()();
}

mixin GeneratedContactCardPersonaColumns on Table {
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get email => text()();
  TextColumn get mobile => text()();
}

Map<String, Expression> buildIdentityPersonaFieldExpressions(
  ContactCard card,
) {
  return <String, Expression>{
    'first_name': Variable<String>(firstNameField.valueFrom(card)),
    'last_name': Variable<String>(lastNameField.valueFrom(card)),
    'email': Variable<String>(emailField.valueFrom(card)),
    'mobile': Variable<String>(mobileField.valueFrom(card)),
  };
}

Map<String, Expression> buildContactCardPersonaFieldExpressions(
  ContactCard card,
) {
  return <String, Expression>{
    'first_name': Variable<String>(firstNameField.valueFrom(card)),
    'last_name': Variable<String>(lastNameField.valueFrom(card)),
    'email': Variable<String>(emailField.valueFrom(card)),
    'mobile': Variable<String>(mobileField.valueFrom(card)),
  };
}

Map<String, String> readPersonaFieldValuesFromRow(
  Map<String, Object?> data,
) {
  final values = <String, String>{};
  final firstNameValue = data['first_name'] as String?;
  if (firstNameValue != null && firstNameValue.isNotEmpty) {
    values[firstNameField.key] = firstNameValue;
  }
  final lastNameValue = data['last_name'] as String?;
  if (lastNameValue != null && lastNameValue.isNotEmpty) {
    values[lastNameField.key] = lastNameValue;
  }
  final emailValue = data['email'] as String?;
  if (emailValue != null && emailValue.isNotEmpty) {
    values[emailField.key] = emailValue;
  }
  final mobileValue = data['mobile'] as String?;
  if (mobileValue != null && mobileValue.isNotEmpty) {
    values[mobileField.key] = mobileValue;
  }
  return values;
}
