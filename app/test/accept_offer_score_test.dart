import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import 'fakes/fake_connection_offers.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_mediators.dart';
import 'fakes/fake_meeting_place_matrix_sdk.dart';
import 'utils/app.dart';

Future<void> _navigateToAcceptOffer(
  WidgetTester tester, {
  required ConnectionOffer offer,
}) async {
  final fakeSdk = FakeMeetingPlaceMatrixSDK(offerToFind: offer);
  final identity = FakeIdentities.primaryIdentity;

  await navigateToLocation(
    tester,
    '/connections/find-offer/${offer.mnemonic}/accept?identity-id=${identity.id}',
    identities: [identity],
    mediators: FakeMediators.all,
    meetingPlaceCoreSDK: fakeSdk,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Accept offer screen — VRC trust score', () {
    testWidgets('shows "Trusted by N" chip when offer has a positive score', (
      tester,
    ) async {
      final l10n = await getL10n();
      final offer = FakeConnectionOffers.testOffer.copyWith(score: 3);

      await _navigateToAcceptOffer(tester, offer: offer);

      expect(find.text(l10n.trustedBy(3)), findsOneWidget);
    });

    testWidgets('hides the trust chip when offer score is zero', (
      tester,
    ) async {
      final offer = FakeConnectionOffers.testOffer.copyWith(score: 0);

      await _navigateToAcceptOffer(tester, offer: offer);

      expect(find.textContaining('Trusted by'), findsNothing);
    });

    testWidgets('hides the trust chip when offer has no score', (tester) async {
      await _navigateToAcceptOffer(
        tester,
        offer: FakeConnectionOffers.testOffer,
      );

      expect(find.textContaining('Trusted by'), findsNothing);
    });
  });
}
