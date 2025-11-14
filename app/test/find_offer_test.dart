import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';

import 'fakes/fake_connection_offers.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_mediators.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

/// Helper function to setup test with navigation
Future<void> setupFindOfferTest(
  WidgetTester tester,
  String location,
  Identity testIdentity,
) async {
  await navigateToLocation(
    tester,
    location,
    identities: [testIdentity],
    mediators: FakeMediators.all,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('When finding an invitation', () {
    final testIdentity = FakeIdentities.primaryIdentity;
    final location = '/connections/find-offer?identity-id=${testIdentity.id}';

    testWidgets('it uses the correct title', (tester) async {
      final l10n = await getL10n();
      await setupFindOfferTest(tester, location, testIdentity);
      expect(find.text(l10n.claimOfferTitle), findsOneWidget);
    });

    testWidgets('it shows the primary identity card', (tester) async {
      await setupFindOfferTest(tester, location, testIdentity);

      // Verify identity picker widget exists
      expect(find.byKey(const ValueKey('find_offer_identity_picker')),
          findsOneWidget);

      // Verify identity details are displayed
      expect(find.text(testIdentity.card.firstName), findsOneWidget);
      expect(find.text(testIdentity.card.email!), findsOneWidget);
      expect(find.text(testIdentity.card.mobile!), findsOneWidget);
    });

    testWidgets('it shows default find offer settings', (tester) async {
      final l10n = await getL10n();
      await setupFindOfferTest(tester, location, testIdentity);

      // Verify passphrase input field exists
      expect(find.text(l10n.enterPassphrase), findsOneWidget);

      // Verify clear button (cancel icon) exists
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      // Verify search button exists
      expect(find.text(l10n.generalSearch), findsOneWidget);
    });

    testWidgets('it shows the QR code scanner button', (tester) async {
      await setupFindOfferTest(tester, location, testIdentity);

      // Verify QR code scanner icon exists
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    group('and enter a passphrase', () {
      testWidgets('it clears the passphrase when cancel button is pressed',
          (tester) async {
        await setupFindOfferTest(tester, location, testIdentity);

        // Find the passphrase text field
        final passphraseField = find.byType(TextField);
        expect(passphraseField, findsOneWidget);

        // Enter a passphrase
        await tester.enterText(passphraseField, 'test-passphrase-123');
        await tester.pumpAndSettle();

        // Verify the text was entered
        expect(find.text('test-passphrase-123'), findsOneWidget);

        // Tap the cancel button
        final cancelButton = find.byIcon(Icons.cancel);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        // Verify the text field is now empty
        expect(find.text('test-passphrase-123'), findsNothing);
      });
    });

    group('when passphrase is empty', () {
      testWidgets('it shows error snackbar when searching', (tester) async {
        final l10n = await getL10n();
        await setupFindOfferTest(tester, location, testIdentity);

        // Find and tap the search button without entering a passphrase
        final searchButton = find.text(l10n.generalSearch);
        expect(searchButton, findsOneWidget);

        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // Verify the error snackbar is displayed with the missingMnemonic error
        expect(find.text(l10n.error('missingMnemonic')), findsOneWidget);
      });
    });

    group('when SDK cannot find the offer', () {
      testWidgets('it shows error snackbar when offer not found',
          (tester) async {
        final l10n = await getL10n();

        // Setup with SDK that returns no offer (offerToFind is null)
        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          mediators: FakeMediators.all,
          meetingPlaceCoreSDK: FakeMeetingPlaceSDK(
            offerToFind: null, // No offer found
          ),
        );
        await tester.pumpAndSettle();

        // Enter a passphrase
        final passphraseField = find.byType(TextField);
        await tester.enterText(passphraseField, 'nonexistent-passphrase');
        await tester.pumpAndSettle();

        // Tap the search button
        final searchButton = find.text(l10n.generalSearch);
        await tester.tap(searchButton);

        // Wait for async operations and error handling
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Verify the error snackbar is displayed with offer not found error
        expect(find.text(l10n.error('offerNotFound')), findsOneWidget);
      });
    });

    group('when SDK successfully finds the offer', () {
      testWidgets('it navigates to accept offer screen and shows all details',
          (tester) async {
        final offer = FakeConnectionOffers.testOffer;
        final offererIdentity = FakeIdentities.secondaryIdentity;
        final l10n = await getL10n();

        // Setup with SDK that returns a valid offer
        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          mediators: FakeMediators.all,
          meetingPlaceCoreSDK: FakeMeetingPlaceSDK(
            offerToFind: offer,
          ),
        );
        await tester.pumpAndSettle();

        // Enter the matching passphrase
        final passphraseField = find.byType(TextField);
        await tester.enterText(passphraseField, offer.mnemonic);
        await tester.pumpAndSettle();

        // Tap the search button
        final searchButton = find.text(l10n.generalSearch);
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // Verify navigation to accept offer screen occurred
        expect(find.text(l10n.acceptOfferTitle), findsOneWidget);

        // Verify offerer's information is displayed
        expect(find.text(offererIdentity.card.firstName), findsWidgets);
        expect(find.text(offer.offerName), findsWidgets);

        // Verify offerer's details in the vCard section
        expect(find.text(l10n.offerDetailsHeader), findsOneWidget);
        expect(find.text(l10n.vCardFieldName('firstName')), findsWidgets);

        // Verify our identity picker section
        expect(find.text(l10n.aliasPickerTitle), findsOneWidget);
        expect(find.byKey(const ValueKey('accept_offer_identity_picker')),
            findsOneWidget);

        // Verify our identity details are shown in the picker
        expect(find.text(testIdentity.card.firstName), findsWidgets);
        expect(find.text(testIdentity.card.email!), findsWidgets);
        expect(find.text(testIdentity.card.mobile!), findsWidgets);

        // Verify action buttons are present
        expect(find.text(l10n.generalCancel), findsOneWidget);
        expect(find.text(l10n.generalConnect), findsOneWidget);
      });

      testWidgets(
          'it calls acceptOffer with correct parameters when Connect is pressed',
          (tester) async {
        final offer = FakeConnectionOffers.testOffer;
        final fakeSdk = FakeMeetingPlaceSDK(offerToFind: offer);
        final l10n = await getL10n();

        // Setup with fake SDK
        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          mediators: FakeMediators.all,
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        // Enter the matching passphrase and search
        final passphraseField = find.byType(TextField);
        await tester.enterText(passphraseField, offer.mnemonic);
        await tester.pumpAndSettle();

        final searchButton = find.text(l10n.generalSearch);
        await tester.tap(searchButton);
        await tester.pumpAndSettle();

        // Verify we're on accept offer screen
        expect(find.text(l10n.acceptOfferTitle), findsOneWidget);

        // Tap the Connect button
        final connectButton = find.text(l10n.generalConnect);
        await tester.tap(connectButton);
        await tester.pumpAndSettle();

        // Verify acceptOffer was called with correct parameters
        expect(fakeSdk.acceptOfferCalls.length, 1);

        final acceptCall = fakeSdk.acceptOfferCalls.first;
        final calledOffer = acceptCall['connectionOffer'] as ConnectionOffer;
        final calledExternalRef = acceptCall['externalRef'] as String?;

        // Verify the connection offer matches
        expect(calledOffer.mnemonic, offer.mnemonic);
        expect(calledOffer.offerName, offer.offerName);

        // Verify the identity external ref matches
        expect(calledExternalRef, testIdentity.id);
      });
    });
  });
}
