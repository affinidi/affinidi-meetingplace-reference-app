import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_mediators.dart';
import 'fakes/fake_meeting_place_matrix_sdk.dart';
import 'utils/app.dart';

ConnectionOffer _offerForContact({int? score}) => ConnectionOffer(
  offerName: 'Test Offer',
  offerLink: FakeContacts.individualContact.offerLink,
  mnemonic: 'test-passphrase-123',
  publishOfferDid: 'did:peer:test123',
  mediatorDid: 'did:peer:mediator123',
  oobInvitationMessage:
      '{"@type":"https://didcomm.org/out-of-band/2.0/invitation"}',
  type: ConnectionOfferType.meetingPlaceInvitation,
  status: ConnectionOfferStatus.published,
  contactCard: FakeIdentities.secondaryIdentity.card.toSdkContactCard(),
  ownedByMe: false,
  createdAt: DateTime(2024, 1, 1),
  offerDescription: 'Test offer description',
  expiresAt: DateTime(2025, 12, 31),
  maximumUsage: 10,
  score: score,
  transport: ChannelTransport.didcomm,
);

Future<void> _navigateToConnectionDetails(
  WidgetTester tester, {
  required ConnectionOffer connection,
}) async {
  final fakeSdk = FakeMeetingPlaceMatrixSDK(channels: FakeChannels.allChannels);
  fakeSdk.setAllConnectionOffers([connection]);

  await navigateToLocation(
    tester,
    '/contacts/${FakeContacts.individualContact.id}/connection-details',
    identities: [FakeIdentities.primaryIdentity],
    contacts: [FakeContacts.individualContact],
    mediators: FakeMediators.all,
    meetingPlaceCoreSDK: fakeSdk,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Connection details screen — VRC trust score', () {
    testWidgets(
      'shows "Trusted by N" chip when connection has a positive score',
      (tester) async {
        final l10n = await getL10n();

        await _navigateToConnectionDetails(
          tester,
          connection: _offerForContact(score: 3),
        );

        expect(find.text(l10n.trustedBy(3)), findsOneWidget);
      },
    );

    testWidgets('hides the trust chip when connection score is null', (
      tester,
    ) async {
      await _navigateToConnectionDetails(
        tester,
        connection: _offerForContact(),
      );

      expect(find.textContaining('Trusted by'), findsNothing);
    });
  });
}
