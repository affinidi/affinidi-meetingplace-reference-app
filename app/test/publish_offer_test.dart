import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';

import 'fakes/fake_identities.dart';
import 'fakes/fake_mediators.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

/// Helper function to generate switch key for a given identity
String switchKey(String switchName, String identityId) {
  return '${switchName}_switch_$identityId';
}

/// Helper function to generate text field key for a given identity
String textFieldKey(String fieldName, String identityId) {
  return '${fieldName}_field_$identityId';
}

/// Helper function to find a toggle switch by key
Finder findToggleSwitchByKey(String key) {
  return find.byKey(ValueKey(key));
}

/// Helper function to find a text field by key
Finder findTextFieldByKey(String key) {
  return find.byKey(ValueKey(key));
}

/// Helper function to verify common publish call parameters
void verifyPublishCall(
  Map<String, dynamic> publishCall,
  dynamic l10n, {
  required String offerName,
  required SDKConnectionOfferType type,
  required String offerDescription,
  String? customPhrase,
  DateTime? validUntil,
  int? maximumUsage,
  required String mediatorDid,
  required String externalRef,
}) {
  expect(publishCall['offerName'], offerName);
  expect(publishCall['type'], type);
  expect(publishCall['offerDescription'], offerDescription);
  expect(publishCall['customPhrase'], customPhrase);
  expect(publishCall['validUntil'], validUntil);
  expect(publishCall['maximumUsage'], maximumUsage);
  expect(publishCall['mediatorDid'], mediatorDid);
  expect(publishCall['externalRef'], externalRef);
}

/// Helper function to setup test with navigation
Future<void> setupPublishOfferTest(
  WidgetTester tester,
  String location,
  Identity testIdentity, {
  FakeMeetingPlaceSDK? fakeSdk,
}) async {
  await navigateToLocation(
    tester,
    location,
    identities: [testIdentity],
    mediators: FakeMediators.all,
    meetingPlaceCoreSDK: fakeSdk,
  );
  await tester.pumpAndSettle();
}

/// Helper function to tap a toggle switch by key
Future<void> tapToggleSwitchByKey(
  WidgetTester tester,
  String key, {
  bool ensureVisible = false,
}) async {
  final switchFinder = findToggleSwitchByKey(key);
  if (ensureVisible) {
    await tester.ensureVisible(switchFinder);
  }
  await tester.tap(switchFinder);
  await tester.pumpAndSettle();
}

/// Helper function to verify toggle switch state by key
void verifyToggleSwitchStateByKey(
  WidgetTester tester,
  String key,
  bool expectedValue,
) {
  final switchFinder = findToggleSwitchByKey(key);
  expect(switchFinder, findsOneWidget);
  final switchWidget = tester.widget<Switch>(switchFinder);
  expect(switchWidget.value, expectedValue);
}

/// Helper function to find and tap the publish button
Future<void> tapPublishButton(WidgetTester tester, String buttonText) async {
  final publishButton = find.widgetWithText(
    ElevatedButton,
    buttonText,
  );
  expect(publishButton, findsOneWidget);
  await tester.tap(publishButton);
  await tester.pumpAndSettle();
}

/// Helper function to verify publish button state (enabled/disabled)
void verifyPublishButtonState(
  WidgetTester tester,
  String buttonText, {
  required bool isEnabled,
}) {
  final publishButton = find.widgetWithText(
    ElevatedButton,
    buttonText,
  );
  expect(publishButton, findsOneWidget);
  final buttonWidget = tester.widget<ElevatedButton>(publishButton);
  if (isEnabled) {
    expect(buttonWidget.onPressed, isNotNull);
  } else {
    expect(buttonWidget.onPressed, isNull);
  }
}

void main() {
  group('When publishing an invitation', () {
    final testIdentity = FakeIdentities.primaryIdentity;
    final location =
        '/connections/publish-offer?identity-id=${testIdentity.id}';

    testWidgets('it uses the correct title', (tester) async {
      final l10n = await getL10n();
      await navigateToLocation(tester, location, identities: [
        testIdentity,
      ]);
      await tester.pumpAndSettle();
      expect(find.text(l10n.publishOffer), findsOneWidget);
    });

    testWidgets('it shows the primary identity card', (tester) async {
      await navigateToLocation(tester, location, identities: [
        testIdentity,
      ]);
      await tester.pumpAndSettle();

      // Verify identity picker widget exists
      expect(find.byKey(const ValueKey('publish_offer_identity_picker')),
          findsOneWidget);

      // Verify identity details are displayed
      expect(find.text(testIdentity.card.firstName), findsOneWidget);
      expect(find.text(testIdentity.card.email!), findsOneWidget);
      expect(find.text(testIdentity.card.mobile!), findsOneWidget);
    });

    testWidgets('it shows default invitation details settings', (tester) async {
      await navigateToLocation(tester, location, identities: [
        testIdentity,
      ]);
      await tester.pumpAndSettle();

      // Verify group chat toggle is disabled using key
      verifyToggleSwitchStateByKey(
          tester, switchKey('group_offer', testIdentity.id), false);

      // Verify random phrase toggle is enabled using key
      verifyToggleSwitchStateByKey(
          tester, switchKey('random_phrase', testIdentity.id), true);
    });

    testWidgets('it shows default validity and visibility settings',
        (tester) async {
      final l10n = await getL10n();

      await navigateToLocation(tester, location, identities: [
        FakeIdentities.primaryIdentity,
      ]);
      await tester.pumpAndSettle();

      // Check expiry toggle and helper text
      expect(find.text(l10n.setExpiry), findsOneWidget);
      expect(find.text(l10n.setExpiryHelperDisabled), findsOneWidget);
      verifyToggleSwitchStateByKey(
          tester, switchKey('set_expiry', testIdentity.id), false);

      // Check limit uses toggle and helper text
      expect(find.text(l10n.limitNumberOfUses), findsOneWidget);
      expect(find.text(l10n.limitUsesHelperDisabled), findsOneWidget);
      verifyToggleSwitchStateByKey(
          tester, switchKey('limit_uses', testIdentity.id), false);
    });

    testWidgets('it shows message server settings', (tester) async {
      final l10n = await getL10n();
      await navigateToLocation(
        tester,
        location,
        identities: [
          testIdentity,
        ],
        mediators: FakeMediators.all,
      );
      await tester.pumpAndSettle();

      // Check mediator section title
      expect(find.text(l10n.mediator), findsOneWidget);
      expect(find.text(l10n.mediatorHelperText), findsOneWidget);

      expect(find.text(FakeMediators.defaultMediator.mediatorName),
          findsOneWidget);

      // Check publish button
      expect(find.text(l10n.publishToMeetingPlace), findsOneWidget);
    });

    testWidgets('it publishes the invitation with default settings',
        (tester) async {
      final l10n = await getL10n();
      final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

      await setupPublishOfferTest(
        tester,
        location,
        testIdentity,
        fakeSdk: fakeMeetingPlaceCoreSDK,
      );

      // Verify publish button is enabled
      verifyPublishButtonState(tester, l10n.publishToMeetingPlace,
          isEnabled: true);

      // Tap the publish button
      await tapPublishButton(tester, l10n.publishToMeetingPlace);

      expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
      final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

      // Verify all parameters match expected default values
      expect(publishCall['offerName'],
          l10n.connectWithFirstName(testIdentity.card.firstName));
      expect(publishCall['type'], SDKConnectionOfferType.invitation);
      expect(publishCall['offerDescription'], l10n.passphraseDescription);
      expect(publishCall['customPhrase'], isNull); // Random phrase enabled
      expect(publishCall['validUntil'], isNull); // No expiry set
      expect(publishCall['maximumUsage'], isNull); // No usage limit
      expect(publishCall['mediatorDid'],
          FakeMediators.defaultMediator.mediatorDid);
      expect(publishCall['externalRef'], testIdentity.id);
    });

    group('and group chat is enabled', () {
      testWidgets('it publishes the invitation as group chat', (tester) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        // Verify initial title is "Publish Offer"
        expect(find.text(l10n.publishOffer), findsOneWidget);

        // Verify and toggle the group chat switch using key
        verifyToggleSwitchStateByKey(
            tester, switchKey('group_offer', testIdentity.id), false);
        await tapToggleSwitchByKey(
            tester, switchKey('group_offer', testIdentity.id));

        // Verify appbar title changed to "Publish Group Offer"
        expect(find.text(l10n.publishGroupOffer), findsOneWidget);
        expect(find.text(l10n.publishOffer), findsNothing);

        // Verify headline label changed to "Chat group name"
        expect(find.text(l10n.chatGroupName), findsOneWidget);

        // Tap the publish button
        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        // Verify SDK was called with group invitation type
        expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

        verifyPublishCall(
          publishCall,
          l10n,
          offerName: l10n.firstNameChatGroup(testIdentity.card.firstName),
          type: SDKConnectionOfferType.groupInvitation,
          offerDescription: l10n.passphraseDescription,
          customPhrase: null,
          validUntil: null,
          maximumUsage: null,
          mediatorDid: FakeMediators.defaultMediator.mediatorDid,
          externalRef: testIdentity.id,
        );
      });
    });

    group('and generate a random phrase is disabled', () {
      testWidgets('it disables the publish button', (tester) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        // Verify initial title is "Publish Offer"
        expect(find.text(l10n.publishOffer), findsOneWidget);

        // Verify random phrase toggle is enabled and turn it off using key
        verifyToggleSwitchStateByKey(
            tester, 'random_phrase_switch_${testIdentity.id}', true);
        await tapToggleSwitchByKey(
            tester, 'random_phrase_switch_${testIdentity.id}',
            ensureVisible: true);

        // Verify custom phrase field appears
        expect(find.text(l10n.customPhrase), findsOneWidget);

        // Verify the publish button is now disabled (no custom phrase entered)
        verifyPublishButtonState(tester, l10n.publishToMeetingPlace,
            isEnabled: false);
      });

      group('and enter a custom phrase', () {
        testWidgets('it publishes the offer with the custom phrase',
            (tester) async {
          final l10n = await getL10n();
          final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK(
            isPhraseAvailable: true,
          );
          const customPhrase = 'my-unique-custom-phrase';

          await setupPublishOfferTest(
            tester,
            location,
            testIdentity,
            fakeSdk: fakeMeetingPlaceCoreSDK,
          );

          // Turn off the random phrase switch using key
          await tapToggleSwitchByKey(
              tester, 'random_phrase_switch_${testIdentity.id}',
              ensureVisible: true);

          // Verify custom phrase label appears
          expect(find.text(l10n.customPhrase), findsOneWidget);

          // Find custom phrase field using key
          final customPhraseField = findTextFieldByKey(
              textFieldKey('custom_phrase', testIdentity.id));
          await tester.ensureVisible(customPhraseField);
          await tester.enterText(customPhraseField, customPhrase);

          // Find and scroll to the publish button
          final publishButton =
              find.widgetWithText(ElevatedButton, l10n.publishToMeetingPlace);
          await tester.ensureVisible(publishButton);
          await tester.pumpAndSettle();
          await tester.pump(Durations.extralong1);

          // Verify publish button is enabled and tap it
          verifyPublishButtonState(tester, l10n.publishToMeetingPlace,
              isEnabled: true);
          await tapPublishButton(tester, l10n.publishToMeetingPlace);

          // Verify SDK was called with the custom phrase
          expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
          final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

          expect(publishCall['offerName'],
              l10n.connectWithFirstName(testIdentity.card.firstName));
          expect(publishCall['type'], SDKConnectionOfferType.invitation);
          expect(publishCall['offerDescription'], l10n.passphraseDescription);
          expect(publishCall['customPhrase'], customPhrase);
          expect(publishCall['validUntil'], isNull);
          expect(publishCall['maximumUsage'], isNull);
          expect(publishCall['mediatorDid'],
              FakeMediators.defaultMediator.mediatorDid);
          expect(publishCall['externalRef'], testIdentity.id);
        });

        group('and switch back to random phrase', () {
          testWidgets('it publishes with random phrase after switching back',
              (tester) async {
            final l10n = await getL10n();
            final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK(
              isPhraseAvailable: true,
            );
            const customPhrase = 'my-unique-custom-phrase';

            await setupPublishOfferTest(
              tester,
              location,
              testIdentity,
              fakeSdk: fakeMeetingPlaceCoreSDK,
            );

            // Turn off the random phrase switch using key
            await tapToggleSwitchByKey(
                tester, 'random_phrase_switch_${testIdentity.id}',
                ensureVisible: true);

            // Enter custom phrase using key
            final customPhraseField = findTextFieldByKey(
                textFieldKey('custom_phrase', testIdentity.id));
            await tester.ensureVisible(customPhraseField);
            await tester.enterText(customPhraseField, customPhrase);
            await tester.pumpAndSettle();

            // Turn the random phrase switch back on using key
            await tapToggleSwitchByKey(
                tester, 'random_phrase_switch_${testIdentity.id}',
                ensureVisible: true);

            // Verify custom phrase field is no longer visible
            expect(find.text(l10n.customPhrase), findsNothing);

            // Tap publish button
            await tapPublishButton(tester, l10n.publishToMeetingPlace);

            // Verify SDK was called with null custom phrase (random phrase)
            expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
            final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

            verifyPublishCall(
              publishCall,
              l10n,
              offerName: l10n.connectWithFirstName(testIdentity.card.firstName),
              type: SDKConnectionOfferType.invitation,
              offerDescription: l10n.passphraseDescription,
              customPhrase: null,
              validUntil: null,
              maximumUsage: null,
              mediatorDid: FakeMediators.defaultMediator.mediatorDid,
              externalRef: testIdentity.id,
            );
          });
        });

        group('and phrase is not available', () {
          testWidgets('it shows cancel icon and disables the publish button',
              (tester) async {
            final l10n = await getL10n();
            final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK(
              isPhraseAvailable: false,
            );
            const customPhrase = 'already-taken-phrase';

            await setupPublishOfferTest(
              tester,
              location,
              testIdentity,
              fakeSdk: fakeMeetingPlaceCoreSDK,
            );

            // Turn off the random phrase switch using key
            await tapToggleSwitchByKey(
                tester, 'random_phrase_switch_${testIdentity.id}',
                ensureVisible: true);

            // Verify custom phrase label appears
            expect(find.text(l10n.customPhrase), findsOneWidget);

            // Find custom phrase field using key
            final customPhraseField = findTextFieldByKey(
                textFieldKey('custom_phrase', testIdentity.id));
            await tester.ensureVisible(customPhraseField);
            await tester.enterText(customPhraseField, customPhrase);

            // Wait for validation to complete
            await tester.pumpAndSettle();
            await tester.pump(Durations.extralong1);

            // Verify cancel icon is displayed
            expect(find.byIcon(Icons.cancel), findsOneWidget);

            // Verify the publish button is disabled
            verifyPublishButtonState(tester, l10n.publishToMeetingPlace,
                isEnabled: false);
          });
        });

        group('and phrase is validating', () {
          testWidgets(
              'it shows progress indicator and disables the publish button',
              (tester) async {
            final l10n = await getL10n();
            final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK(
              isPhraseAvailable: true,
            );
            const customPhrase = 'validating-phrase';

            await setupPublishOfferTest(
              tester,
              location,
              testIdentity,
              fakeSdk: fakeMeetingPlaceCoreSDK,
            );

            // Turn off the random phrase switch using key
            await tapToggleSwitchByKey(
                tester, 'random_phrase_switch_${testIdentity.id}',
                ensureVisible: true);

            // Verify custom phrase label appears
            expect(find.text(l10n.customPhrase), findsOneWidget);

            // Find custom phrase field using key
            final customPhraseField = findTextFieldByKey(
                textFieldKey('custom_phrase', testIdentity.id));
            await tester.ensureVisible(customPhraseField);

            // Enter text to trigger validation
            await tester.enterText(customPhraseField, customPhrase);

            // This catches the validating state before it completes
            await tester.pump(Durations.extralong1);

            // Verify progress indicator is displayed during validation
            expect(find.byType(CircularProgressIndicator), findsOneWidget);

            // Verify the publish button is disabled during validation
            verifyPublishButtonState(tester, l10n.publishToMeetingPlace,
                isEnabled: false);
          });
        });
      });
    });

    group('and change the headline\'s name', () {
      testWidgets('it publishes the invitation with new headline',
          (tester) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        // Find the headline text field using key
        final headlineTextField =
            findTextFieldByKey(textFieldKey('headline', testIdentity.id));
        expect(headlineTextField, findsOneWidget);

        // Clear the headline text field
        await tester.enterText(headlineTextField, '');
        await tester.pumpAndSettle();

        // Verify the publish button is disabled when headline is empty
        verifyPublishButtonState(tester, l10n.publishToMeetingPlace,
            isEnabled: false);

        // Enter a new headline
        await tester.enterText(headlineTextField, 'New Custom Headline');
        await tester.pumpAndSettle();

        // Verify the publish button is now enabled and tap it
        verifyPublishButtonState(tester, l10n.publishToMeetingPlace,
            isEnabled: true);
        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        // Verify SDK was called with updated headline
        expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

        verifyPublishCall(
          publishCall,
          l10n,
          offerName: 'New Custom Headline',
          type: SDKConnectionOfferType.invitation,
          offerDescription: l10n.passphraseDescription,
          customPhrase: null,
          validUntil: null,
          maximumUsage: null,
          mediatorDid: FakeMediators.defaultMediator.mediatorDid,
          externalRef: testIdentity.id,
        );
      });
    });

    group('and change the description', () {
      testWidgets('it publishes the invitation with new description',
          (tester) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        // Find the description text field using key
        final descriptionTextField =
            findTextFieldByKey(textFieldKey('description', testIdentity.id));
        expect(descriptionTextField, findsOneWidget);

        // Clear the description text field
        await tester.enterText(descriptionTextField, '');
        await tester.pumpAndSettle();

        // Verify the publish button is disabled when description is empty
        verifyPublishButtonState(tester, l10n.publishToMeetingPlace,
            isEnabled: false);

        // Enter a new description
        await tester.enterText(
            descriptionTextField, 'This is a custom description for my offer');
        await tester.pumpAndSettle();

        // Verify the publish button is now enabled and tap it
        verifyPublishButtonState(tester, l10n.publishToMeetingPlace,
            isEnabled: true);
        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        // Verify SDK was called with updated description
        expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

        verifyPublishCall(
          publishCall,
          l10n,
          offerName: l10n.connectWithFirstName(testIdentity.card.firstName),
          type: SDKConnectionOfferType.invitation,
          offerDescription: 'This is a custom description for my offer',
          customPhrase: null,
          validUntil: null,
          maximumUsage: null,
          mediatorDid: FakeMediators.defaultMediator.mediatorDid,
          externalRef: testIdentity.id,
        );
      });
    });

    group('and set expiry is enabled', () {
      testWidgets('it publishes the invitation with expiry date',
          (tester) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();
        const defaultExpiryDays = 3;

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        // Verify expiry switch is off and turn it on using key
        verifyToggleSwitchStateByKey(
            tester, 'set_expiry_switch_${testIdentity.id}', false);
        await tapToggleSwitchByKey(
            tester, 'set_expiry_switch_${testIdentity.id}',
            ensureVisible: true);

        // Tap the publish button
        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        // Verify SDK was called with expiry date
        expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

        expect(publishCall['offerName'],
            l10n.connectWithFirstName(testIdentity.card.firstName));
        expect(publishCall['type'], SDKConnectionOfferType.invitation);
        expect(publishCall['offerDescription'], l10n.passphraseDescription);
        expect(publishCall['customPhrase'], isNull);

        final validUntil = publishCall['validUntil'] as DateTime;
        final expectedExpiry =
            DateTime.now().add(const Duration(days: defaultExpiryDays));
        final difference = validUntil.difference(expectedExpiry).abs();
        expect(difference.inDays == 0, true);

        expect(publishCall['maximumUsage'], isNull);
        expect(publishCall['mediatorDid'],
            FakeMediators.defaultMediator.mediatorDid);
        expect(publishCall['externalRef'], testIdentity.id);
      });

        testWidgets('it publishes with the new expiry date', (tester) async {
          final l10n = await getL10n();
          final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();
          const expireAfterDays = 5;

          await setupPublishOfferTest(
            tester,
            location,
            testIdentity,
            fakeSdk: fakeMeetingPlaceCoreSDK,
          );

          // Turn on the expiry switch using key
          await tapToggleSwitchByKey(
              tester, 'set_expiry_switch_${testIdentity.id}',
              ensureVisible: true);

          // Verify the "Change" button appears for the expiry date picker
          // The FormRowPicker with Change button should now be visible
          final changeButtons = find.text(l10n.changeButton);

          // Should find at least one Change button (for expiry date picker)
          expect(changeButtons, findsWidgets);

          // Verify the expiry date helper text appears
          final expiryHelperText = find.text(l10n.selectExpiryHelperText);
          expect(expiryHelperText, findsOneWidget);

          // Tap the first Change button (for expiry date)
          await tester.tap(changeButtons.first);
          await tester.pumpAndSettle();

          final today = DateTime.now();
          final newExpiryDate =
              today.add(const Duration(days: expireAfterDays));

          final months = [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
          ];
          final targetMonthName = months[newExpiryDate.month - 1];

          if (find.textContaining(targetMonthName).evaluate().isEmpty) {
            final nextMonthButton = find.byIcon(Icons.chevron_right);
            await tester.tap(nextMonthButton);
            await tester.pumpAndSettle();
          }

          await tester.tap(find.text(newExpiryDate.day.toString()).last);
          await tester.pumpAndSettle();

          // Tap OK button on date picker
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          // Time picker should now appear - tap OK to accept default time
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          // Tap the publish button
          await tapPublishButton(tester, l10n.publishToMeetingPlace);

          // Verify SDK was called with updated expiry date
          expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
          final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

          expect(publishCall['offerName'],
              l10n.connectWithFirstName(testIdentity.card.firstName));
          expect(publishCall['type'], SDKConnectionOfferType.invitation);
          expect(publishCall['offerDescription'], l10n.passphraseDescription);
          expect(publishCall['customPhrase'], isNull);

          // Verify the expiry date matches the selected date (same day)
          final validUntil = publishCall['validUntil'] as DateTime;
          final expectedExpiry =
              DateTime.now().add(const Duration(days: expireAfterDays));
          final difference = validUntil.difference(expectedExpiry).abs();
          expect(difference.inDays == 0, true);

          expect(publishCall['maximumUsage'], isNull);
          expect(publishCall['mediatorDid'],
              FakeMediators.defaultMediator.mediatorDid);
          expect(publishCall['externalRef'], testIdentity.id);
        });

        group('and switch back to no expiry', () {
          testWidgets(
              'it publishes without expiry after changing date then switching'
              ' back', (tester) async {
            final l10n = await getL10n();
            final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

            await setupPublishOfferTest(
              tester,
              location,
              testIdentity,
              fakeSdk: fakeMeetingPlaceCoreSDK,
            );

            // Turn on the expiry switch using key
            await tapToggleSwitchByKey(
                tester, 'set_expiry_switch_${testIdentity.id}',
                ensureVisible: true);

            // Change the expiry date
            final changeButtons = find.text(l10n.changeButton);
            await tester.tap(changeButtons.first);
            await tester.pumpAndSettle();

            final newExpiryDate = DateTime.now().add(const Duration(days: 7));
            await tester.tap(find.text(newExpiryDate.day.toString()));
            await tester.pumpAndSettle();

            await tester.tap(find.text('OK'));
            await tester.pumpAndSettle();

            await tester.tap(find.text('OK'));
            await tester.pumpAndSettle();

            // Turn off the expiry switch using key
            await tapToggleSwitchByKey(
                tester, 'set_expiry_switch_${testIdentity.id}',
                ensureVisible: true);

            // Verify expiry helper text changed back to disabled
            expect(find.text(l10n.setExpiryHelperDisabled), findsOneWidget);

            // Tap publish button
            await tapPublishButton(tester, l10n.publishToMeetingPlace);

            // Verify SDK was called with null expiry date
            expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
            final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

            verifyPublishCall(
              publishCall,
              l10n,
              offerName: l10n.connectWithFirstName(testIdentity.card.firstName),
              type: SDKConnectionOfferType.invitation,
              offerDescription: l10n.passphraseDescription,
              customPhrase: null,
              validUntil: null,
              maximumUsage: null,
              mediatorDid: FakeMediators.defaultMediator.mediatorDid,
              externalRef: testIdentity.id,
            );
          });
        });
      });
    });

    group('and limit number of uses is enabled', () {
      testWidgets('it publishes with default maximum usage of 3',
          (tester) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        // Verify limit uses switch is off and turn it on using key
        verifyToggleSwitchStateByKey(
            tester, 'limit_uses_switch_${testIdentity.id}', false);
        await tapToggleSwitchByKey(
            tester, 'limit_uses_switch_${testIdentity.id}',
            ensureVisible: true);

        // Tap the publish button
        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        // Verify SDK was called with default maximum usage of 3
        expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

        verifyPublishCall(
          publishCall,
          l10n,
          offerName: l10n.connectWithFirstName(testIdentity.card.firstName),
          type: SDKConnectionOfferType.invitation,
          offerDescription: l10n.passphraseDescription,
          customPhrase: null,
          validUntil: null,
          maximumUsage: 3,
          mediatorDid: FakeMediators.defaultMediator.mediatorDid,
          externalRef: testIdentity.id,
        );
      });

      group('and change the maximum usage', () {
        testWidgets('it publishes with the new maximum usage of 5',
            (tester) async {
          final l10n = await getL10n();
          final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

          await setupPublishOfferTest(
            tester,
            location,
            testIdentity,
            fakeSdk: fakeMeetingPlaceCoreSDK,
          );

          // Turn on the limit uses switch using key
          await tapToggleSwitchByKey(
              tester, 'limit_uses_switch_${testIdentity.id}',
              ensureVisible: true);

          // Verify the usage label appears (default 3 times)
          final usageLabel = find.text(l10n.canBeUsedTimes(3));
          expect(usageLabel, findsOneWidget);

          // Find and tap the Change button for max usages
          final changeButtons = find.text(l10n.changeButton);
          expect(changeButtons, findsWidgets);
          await tester.ensureVisible(changeButtons.first);
          await tester.tap(changeButtons.first);
          await tester.pumpAndSettle();

          // Select 5 uses option in the picker
          final fiveUsesOption = find.ancestor(
            of: find.text('5'),
            matching: find.byType(ListTile),
          );
          await tester.tap(fiveUsesOption);
          await tester.pumpAndSettle();

          // Tap publish button
          await tapPublishButton(tester, l10n.publishToMeetingPlace);

          // Verify SDK was called with updated maximum usage of 5
          expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
          final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

          verifyPublishCall(
            publishCall,
            l10n,
            offerName: l10n.connectWithFirstName(testIdentity.card.firstName),
            type: SDKConnectionOfferType.invitation,
            offerDescription: l10n.passphraseDescription,
            customPhrase: null,
            validUntil: null,
            maximumUsage: 5,
            mediatorDid: FakeMediators.defaultMediator.mediatorDid,
            externalRef: testIdentity.id,
          );
        });

        group('and switch back to disabled', () {
          testWidgets(
              'it publishes with default limit after changing usage then '
              'switching back', (tester) async {
            final l10n = await getL10n();
            final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

            await setupPublishOfferTest(
              tester,
              location,
              testIdentity,
              fakeSdk: fakeMeetingPlaceCoreSDK,
            );

            // Turn on the limit uses switch using key
            await tapToggleSwitchByKey(
                tester, 'limit_uses_switch_${testIdentity.id}',
                ensureVisible: true);

            // Verify the usage label appears (default 3 times)
            final usageLabel = find.text(l10n.canBeUsedTimes(3));
            expect(usageLabel, findsOneWidget);

            // Change the maximum usage to 10
            final changeButtons = find.text(l10n.changeButton);
            expect(changeButtons, findsWidgets);
            await tester.ensureVisible(changeButtons.first);
            await tester.tap(changeButtons.first);
            await tester.pumpAndSettle();

            // Select 5 uses option in the picker
            final fiveUsesOption = find.ancestor(
              of: find.text('5'),
              matching: find.byType(ListTile),
            );
            await tester.tap(fiveUsesOption);
            await tester.pumpAndSettle();

            // Verify the updated usage label
            expect(find.text(l10n.canBeUsedTimes(5)), findsOneWidget);

            // Turn off the limit uses switch using key
            await tapToggleSwitchByKey(
                tester, 'limit_uses_switch_${testIdentity.id}',
                ensureVisible: true);

            // Verify helper text changed back to disabled
            expect(find.text(l10n.limitUsesHelperDisabled), findsOneWidget);

            // Tap publish button
            await tapPublishButton(tester, l10n.publishToMeetingPlace);

            expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
            final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

            verifyPublishCall(
              publishCall,
              l10n,
              offerName: l10n.connectWithFirstName(testIdentity.card.firstName),
              type: SDKConnectionOfferType.invitation,
              offerDescription: l10n.passphraseDescription,
              customPhrase: null,
              validUntil: null,
              maximumUsage: null,
              mediatorDid: FakeMediators.defaultMediator.mediatorDid,
              externalRef: testIdentity.id,
            );
          });
        });
      });
    });

    group('and change the mediator', () {
      testWidgets('it publishes with the new mediator', (tester) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        // Verify default mediator is shown
        expect(find.text(FakeMediators.defaultMediator.mediatorName),
            findsOneWidget);

        // Find and tap the Change button in the mediator section
        final changeButton = find.text(l10n.changeButton);
        expect(changeButton, findsOneWidget);
        await tester.ensureVisible(changeButton);
        await tester.tap(changeButton);
        await tester.pumpAndSettle();

        // Select Custom Mediator in the list
        final customMediatorOption =
            find.text(FakeMediators.customMediator.mediatorName);
        await tester.tap(customMediatorOption);
        await tester.pumpAndSettle();

        // Verify the custom mediator is now selected
        expect(find.text(FakeMediators.customMediator.mediatorName),
            findsOneWidget);

        // Tap publish button
        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        // Verify SDK was called with the custom mediator
        expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

        verifyPublishCall(
          publishCall,
          l10n,
          offerName: l10n.connectWithFirstName(testIdentity.card.firstName),
          type: SDKConnectionOfferType.invitation,
          offerDescription: l10n.passphraseDescription,
          customPhrase: null,
          validUntil: null,
          maximumUsage: null,
          mediatorDid: FakeMediators.customMediator.mediatorDid,
          externalRef: testIdentity.id,
        );
      });
    });
  });
}
