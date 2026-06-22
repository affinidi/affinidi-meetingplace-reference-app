import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

void main() {
  group('ContactCardExtensions.toRCardSubject', () {
    test('maps all contact fields including the profile picture', () {
      const card = ContactCard(
        id: '1',
        did: 'did:example:123',
        type: 'individual',
        firstName: 'Ada',
        displayName: 'Ada Lovelace',
        lastName: 'Lovelace',
        email: 'ada@example.com',
        mobile: '+15551234567',
        profilePic: 'data:image/png;base64,AAAA',
      );

      final subject = card.toRCardSubject();

      expect(subject.firstName, 'Ada');
      expect(subject.lastName, 'Lovelace');
      expect(subject.email, 'ada@example.com');
      expect(subject.phone, '+15551234567');
      expect(subject.profilePic, 'data:image/png;base64,AAAA');
    });

    test('leaves the profile picture null when the card has none', () {
      const card = ContactCard(
        id: '2',
        did: 'did:example:456',
        type: 'individual',
        firstName: 'Grace',
        displayName: 'Grace Hopper',
      );

      final subject = card.toRCardSubject();

      expect(subject.profilePic, isNull);
    });
  });
}
