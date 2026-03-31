import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card_field_definition.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

const _baseCard = ContactCard(
  id: 'card-id',
  did: 'did:key:test',
  type: 'individual',
  firstName: '',
  displayName: '',
);

void main() {
  group('ContactCardFieldDefinitions', () {
    test('has a definition for every contact card field key', () {
      expect(
        ContactCardFieldDefinitions.values.map((field) => field.key),
        unorderedEquals(ContactCardFieldKey.values),
      );
    });

    test('normalizes empty values according to each field definition', () {
      for (final field in ContactCardFieldDefinitions.values) {
        final hydrated = field.hydrateContactCard(_baseCard, '');

        if (field.nullWhenEmpty) {
          expect(field.nullableValueFrom(hydrated), isNull, reason: field.name);
        } else {
          expect(field.valueFrom(hydrated), '', reason: field.name);
        }
      }
    });

    test(
      'round-trips every field through the registry and sdk contact card',
      () {
        var card = _baseCard;
        final expectedValues = <ContactCardFieldKey, String>{};

        for (final field in ContactCardFieldDefinitions.values) {
          final sampleValue = 'value-${field.name}';
          card = field.updateContactCard(card, sampleValue);
          expectedValues[field.key] = field.valueFrom(card);
          expect(expectedValues[field.key], sampleValue, reason: field.name);
        }

        card = card.copyWith(displayName: card.fullName);

        final sdkCard = card.toSdkContactCard();

        for (final field in ContactCardFieldDefinitions.values) {
          expect(
            sdkCard.valueForField(field.key),
            expectedValues[field.key],
            reason: field.name,
          );
        }

        final hydrated = ContactCardUtils.fromSdkContactCard(
          sdk.ContactCard(
            did: sdkCard.did,
            type: sdkCard.type,
            contactInfo: Map<String, dynamic>.from(sdkCard.contactInfo),
          ),
        );

        for (final field in ContactCardFieldDefinitions.values) {
          expect(
            field.valueFrom(hydrated),
            expectedValues[field.key],
            reason: field.name,
          );
        }

        expect(hydrated.displayName, hydrated.fullName);
      },
    );
  });
}
