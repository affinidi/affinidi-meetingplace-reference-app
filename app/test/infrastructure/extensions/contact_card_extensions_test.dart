import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

import '../../fakes/fake_identities.dart';

void main() {
  group('toSharedSdkContactCard', () {
    test('leaves out the identity DID, and keeps the details', () {
      final card = FakeIdentities.primaryIdentity.card;

      final shared = card.toSharedSdkContactCard();

      expect(card.did, isNotEmpty);
      expect(shared.did, isEmpty);
      expect(shared.type, card.type);
      expect(shared.contactInfo, card.toSdkContactCard().contactInfo);
    });
  });
}
