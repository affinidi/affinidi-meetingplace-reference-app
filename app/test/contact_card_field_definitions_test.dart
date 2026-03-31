import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card_field_definition.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card_field_definition.drift_glue.g.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

void main() {
  group('ContactCardFieldDefinitions', () {
    test('normalizes nullable editable fields to null when hydrating', () {
      final hydrated = ContactCardFieldDefinitions.applyFieldValues(
        const ContactCard(
          id: 'card-id',
          did: 'did:key:test',
          type: 'individual',
          firstName: '',
          displayName: '',
        ),
        {
          ContactCardFieldKey.firstName: 'Marco',
          ContactCardFieldKey.lastName: '',
          ContactCardFieldKey.organization: '',
          ContactCardFieldKey.website: '',
          ContactCardFieldKey.email: '',
          ContactCardFieldKey.mobile: '',
          ContactCardFieldKey.postcode: '',
        },
      );

      expect(hydrated.firstName, 'Marco');
      expect(hydrated.lastName, isNull);
      expect(hydrated.organization, isNull);
      expect(hydrated.website, isNull);
      expect(hydrated.email, isNull);
      expect(hydrated.mobile, isNull);
      expect(hydrated.postcode, isNull);
    });

    test('round-trips editable fields through sdk contact card paths', () {
      const card = ContactCard(
        id: 'card-id',
        did: 'did:key:test',
        type: 'individual',
        firstName: 'Marco',
        displayName: 'Marco Rossi',
        lastName: 'Rossi',
        organization: 'Affinidi',
        website: 'https://affinidi.com',
        email: 'marco@example.com',
        mobile: '+39000111222',
        postcode: '20121',
      );

      final sdkCard = card.toSdkContactCard();

      expect(sdkCard.firstName, card.firstName);
      expect(sdkCard.lastName, card.lastName);
      expect(
        sdkCard.valueForField(ContactCardFieldKey.organization),
        card.organization,
      );
      expect(sdkCard.valueForField(ContactCardFieldKey.website), card.website);
      expect(sdkCard.email, card.email);
      expect(sdkCard.mobile, card.mobile);
      expect(sdkCard.postcode, card.postcode);

      final hydrated = ContactCardUtils.fromSdkContactCard(
        sdk.ContactCard(
          did: sdkCard.did,
          type: sdkCard.type,
          contactInfo: Map<String, dynamic>.from(sdkCard.contactInfo),
        ),
      );

      expect(hydrated.firstName, card.firstName);
      expect(hydrated.lastName, card.lastName);
      expect(hydrated.organization, card.organization);
      expect(hydrated.website, card.website);
      expect(hydrated.email, card.email);
      expect(hydrated.mobile, card.mobile);
      expect(hydrated.postcode, card.postcode);
      expect(hydrated.displayName, card.displayName);
    });

    test('emits migration metadata for missing generated columns', () {
      expect(generatedIdentityContactCardFieldMigrations, hasLength(7));
      expect(generatedContactCardFieldMigrations, hasLength(7));

      final missingIdentitySql = missingIdentityContactCardFieldSql(const [
        'firstName',
        'lastName',
      ]);
      final missingContactSql = missingContactCardFieldSql(const [
        'firstName',
        'lastName',
        'email',
      ]);

      expect(
        missingIdentitySql,
        contains('ALTER TABLE identities_table ADD COLUMN organization TEXT'),
      );
      expect(
        missingIdentitySql,
        contains('ALTER TABLE identities_table ADD COLUMN website TEXT'),
      );
      expect(
        missingIdentitySql,
        contains('ALTER TABLE identities_table ADD COLUMN email TEXT'),
      );
      expect(
        missingIdentitySql,
        contains('ALTER TABLE identities_table ADD COLUMN mobile TEXT'),
      );
      expect(
        missingIdentitySql,
        contains('ALTER TABLE identities_table ADD COLUMN postcode TEXT'),
      );
      expect(
        missingContactSql,
        contains(
          '''ALTER TABLE contact_cards ADD COLUMN organization TEXT NOT NULL DEFAULT '\'''',
        ),
      );
      expect(
        missingContactSql,
        contains(
          '''ALTER TABLE contact_cards ADD COLUMN website TEXT NOT NULL DEFAULT '\'''',
        ),
      );
      expect(
        missingContactSql,
        contains(
          '''ALTER TABLE contact_cards ADD COLUMN mobile TEXT NOT NULL DEFAULT '\'''',
        ),
      );
      expect(
        missingContactSql,
        contains(
          '''ALTER TABLE contact_cards ADD COLUMN postcode TEXT NOT NULL DEFAULT '\'''',
        ),
      );
    });
  });
}
