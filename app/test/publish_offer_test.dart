import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';

import 'fakes/fake_identities.dart';
import 'fakes/fake_mediators.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

String switchKey(String switchName, String identityId) {
  return '${switchName}_switch_$identityId';
}

String textFieldKey(String fieldName, String identityId) {
  return '${fieldName}_field_$identityId';
}

Finder findToggleSwitchByKey(String key) {
  return find.byKey(ValueKey(key));
}

Finder findTextFieldByKey(String key) {
  return find.byKey(ValueKey(key));
}

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
  int? score,
}) {
  expect(publishCall['offerName'], offerName);
  expect(publishCall['type'], type);
  expect(publishCall['offerDescription'], offerDescription);
  expect(publishCall['customPhrase'], customPhrase);
  expect(publishCall['validUntil'], validUntil);
  expect(publishCall['maximumUsage'], maximumUsage);
  expect(publishCall['mediatorDid'], mediatorDid);
  expect(publishCall['externalRef'], externalRef);
  if (score != null) {
    expect(publishCall['score'], score);
  }
}

Future<void> setupPublishOfferTest(
  WidgetTester tester,
  String location,
  Identity testIdentity, {
  FakeMeetingPlaceSDK? fakeSdk,
  List<Vrc> vrcs = const [],
}) async {
  await navigateToLocation(
    tester,
    location,
    identities: [testIdentity],
    mediators: FakeMediators.all,
    meetingPlaceCoreSDK: fakeSdk,
    vrcs: vrcs,
  );
  await tester.pumpAndSettle();
}

Future<void> tapToggleSwitchByKey(WidgetTester tester, String key) async {
  final switchFinder = findToggleSwitchByKey(key);
  await tester.ensureVisible(switchFinder);
  await tester.tap(switchFinder);
  await tester.pumpAndSettle();
}

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

Future<void> tapPublishButton(WidgetTester tester, String buttonText) async {
  final publishButton = find.widgetWithText(ElevatedButton, buttonText);
  expect(publishButton, findsOneWidget);
  await tester.tap(publishButton);
  await tester.pumpAndSettle();
}

void verifyPublishButtonState(
  WidgetTester tester,
  String buttonText, {
  required bool isEnabled,
}) {
  final publishButton = find.widgetWithText(ElevatedButton, buttonText);
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
      await navigateToLocation(tester, location, identities: [testIdentity]);
      await tester.pumpAndSettle();
      expect(find.text(l10n.publishOffer), findsOneWidget);
    });

    testWidgets('it shows the primary identity card', (tester) async {
      await navigateToLocation(tester, location, identities: [testIdentity]);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('publish_offer_identity_picker')),
        findsOneWidget,
      );

      expect(find.text(testIdentity.card.firstName), findsOneWidget);
      expect(find.text(testIdentity.card.email!), findsOneWidget);
      expect(find.text(testIdentity.card.mobile!), findsOneWidget);
    });

    testWidgets('it shows default invitation details settings', (tester) async {
      await navigateToLocation(tester, location, identities: [testIdentity]);
      await tester.pumpAndSettle();

      verifyToggleSwitchStateByKey(
        tester,
        switchKey('group_offer', testIdentity.id),
        false,
      );

      verifyToggleSwitchStateByKey(
        tester,
        switchKey('random_phrase', testIdentity.id),
        true,
      );
    });

    testWidgets('it shows default validity and visibility settings', (
      tester,
    ) async {
      final l10n = await getL10n();

      await navigateToLocation(
        tester,
        location,
        identities: [FakeIdentities.primaryIdentity],
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.setExpiry), findsOneWidget);
      expect(find.text(l10n.setExpiryHelperDisabled), findsOneWidget);
      verifyToggleSwitchStateByKey(
        tester,
        switchKey('set_expiry', testIdentity.id),
        false,
      );

      expect(find.text(l10n.limitNumberOfUses), findsOneWidget);
      expect(find.text(l10n.limitUsesHelperDisabled), findsOneWidget);
      verifyToggleSwitchStateByKey(
        tester,
        switchKey('limit_uses', testIdentity.id),
        false,
      );
    });

    testWidgets('it shows message server settings', (tester) async {
      final l10n = await getL10n();
      await navigateToLocation(
        tester,
        location,
        identities: [testIdentity],
        mediators: FakeMediators.all,
      );
      await tester.pumpAndSettle();

      expect(find.text(l10n.mediator), findsOneWidget);
      expect(find.text(l10n.mediatorHelperText), findsOneWidget);

      expect(
        find.text(FakeMediators.defaultMediator.mediatorName),
        findsOneWidget,
      );

      expect(find.text(l10n.publishToMeetingPlace), findsOneWidget);
    });

    testWidgets('it publishes the invitation with default settings', (
      tester,
    ) async {
      final l10n = await getL10n();
      final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

      await setupPublishOfferTest(
        tester,
        location,
        testIdentity,
        fakeSdk: fakeMeetingPlaceCoreSDK,
      );

      verifyPublishButtonState(
        tester,
        l10n.publishToMeetingPlace,
        isEnabled: true,
      );

      await tapPublishButton(tester, l10n.publishToMeetingPlace);

      expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
      final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

      expect(
        publishCall['offerName'],
        l10n.connectWithFirstName(testIdentity.card.firstName),
      );
      expect(publishCall['type'], SDKConnectionOfferType.invitation);
      expect(publishCall['offerDescription'], l10n.passphraseDescription);
      expect(publishCall['customPhrase'], isNull); // Random phrase enabled
      expect(publishCall['validUntil'], isNull); // No expiry set
      expect(publishCall['maximumUsage'], isNull); // No usage limit
      expect(
        publishCall['mediatorDid'],
        FakeMediators.defaultMediator.mediatorDid,
      );
      expect(publishCall['externalRef'], testIdentity.id);
      expect(publishCall['score'], 0);
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

        expect(find.text(l10n.publishOffer), findsOneWidget);

        verifyToggleSwitchStateByKey(
          tester,
          switchKey('group_offer', testIdentity.id),
          false,
        );
        await tapToggleSwitchByKey(
          tester,
          switchKey('group_offer', testIdentity.id),
        );

        expect(find.text(l10n.publishGroupOffer), findsOneWidget);
        expect(find.text(l10n.publishOffer), findsNothing);

        expect(find.text(l10n.chatGroupName), findsOneWidget);

        await tapPublishButton(tester, l10n.publishToMeetingPlace);

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

        expect(find.text(l10n.publishOffer), findsOneWidget);

        verifyToggleSwitchStateByKey(
          tester,
          'random_phrase_switch_${testIdentity.id}',
          true,
        );
        await tapToggleSwitchByKey(
          tester,
          'random_phrase_switch_${testIdentity.id}',
        );

        expect(find.text(l10n.customPhrase), findsOneWidget);

        verifyPublishButtonState(
          tester,
          l10n.publishToMeetingPlace,
          isEnabled: false,
        );
      });

      group('and enter a custom phrase', () {
        testWidgets('it publishes the offer with the custom phrase', (
          tester,
        ) async {
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

          await tapToggleSwitchByKey(
            tester,
            'random_phrase_switch_${testIdentity.id}',
          );

          expect(find.text(l10n.customPhrase), findsOneWidget);

          final customPhraseField = findTextFieldByKey(
            textFieldKey('custom_phrase', testIdentity.id),
          );
          await tester.ensureVisible(customPhraseField);
          await tester.enterText(customPhraseField, customPhrase);

          final publishButton = find.widgetWithText(
            ElevatedButton,
            l10n.publishToMeetingPlace,
          );
          await tester.ensureVisible(publishButton);
          await tester.pumpAndSettle();
          await tester.pump(Durations.extralong1);

          verifyPublishButtonState(
            tester,
            l10n.publishToMeetingPlace,
            isEnabled: true,
          );
          await tapPublishButton(tester, l10n.publishToMeetingPlace);

          expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
          final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

          expect(
            publishCall['offerName'],
            l10n.connectWithFirstName(testIdentity.card.firstName),
          );
          expect(publishCall['type'], SDKConnectionOfferType.invitation);
          expect(publishCall['offerDescription'], l10n.passphraseDescription);
          expect(publishCall['customPhrase'], customPhrase);
          expect(publishCall['validUntil'], isNull);
          expect(publishCall['maximumUsage'], isNull);
          expect(
            publishCall['mediatorDid'],
            FakeMediators.defaultMediator.mediatorDid,
          );
          expect(publishCall['externalRef'], testIdentity.id);
        });

        group('and switch back to random phrase', () {
          testWidgets('it publishes with random phrase after switching back', (
            tester,
          ) async {
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

            await tapToggleSwitchByKey(
              tester,
              'random_phrase_switch_${testIdentity.id}',
            );

            final customPhraseField = findTextFieldByKey(
              textFieldKey('custom_phrase', testIdentity.id),
            );
            await tester.ensureVisible(customPhraseField);
            await tester.enterText(customPhraseField, customPhrase);
            await tester.pumpAndSettle();

            await tapToggleSwitchByKey(
              tester,
              'random_phrase_switch_${testIdentity.id}',
            );

            expect(find.text(l10n.customPhrase), findsNothing);

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

        group('and phrase is not available', () {
          testWidgets('it shows cancel icon and disables the publish button', (
            tester,
          ) async {
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

            await tapToggleSwitchByKey(
              tester,
              'random_phrase_switch_${testIdentity.id}',
            );

            expect(find.text(l10n.customPhrase), findsOneWidget);

            final customPhraseField = findTextFieldByKey(
              textFieldKey('custom_phrase', testIdentity.id),
            );
            await tester.ensureVisible(customPhraseField);
            await tester.enterText(customPhraseField, customPhrase);

            await tester.pumpAndSettle();
            await tester.pump(Durations.extralong1);

            expect(find.byIcon(Icons.cancel), findsOneWidget);

            verifyPublishButtonState(
              tester,
              l10n.publishToMeetingPlace,
              isEnabled: false,
            );
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

              await tapToggleSwitchByKey(
                tester,
                'random_phrase_switch_${testIdentity.id}',
              );

              expect(find.text(l10n.customPhrase), findsOneWidget);

              final customPhraseField = findTextFieldByKey(
                textFieldKey('custom_phrase', testIdentity.id),
              );
              await tester.ensureVisible(customPhraseField);

              await tester.enterText(customPhraseField, customPhrase);

              await tester.pump(Durations.extralong1);

              expect(find.byType(CircularProgressIndicator), findsOneWidget);

              verifyPublishButtonState(
                tester,
                l10n.publishToMeetingPlace,
                isEnabled: false,
              );
            },
          );
        });
      });
    });

    group('and change the headline\'s name', () {
      testWidgets('it publishes the invitation with new headline', (
        tester,
      ) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        final headlineTextField = findTextFieldByKey(
          textFieldKey('headline', testIdentity.id),
        );
        expect(headlineTextField, findsOneWidget);

        await tester.enterText(headlineTextField, '');
        await tester.pumpAndSettle();

        verifyPublishButtonState(
          tester,
          l10n.publishToMeetingPlace,
          isEnabled: false,
        );

        await tester.enterText(headlineTextField, 'New Custom Headline');
        await tester.pumpAndSettle();

        verifyPublishButtonState(
          tester,
          l10n.publishToMeetingPlace,
          isEnabled: true,
        );
        await tapPublishButton(tester, l10n.publishToMeetingPlace);

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
      testWidgets('it publishes the invitation with new description', (
        tester,
      ) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        final descriptionTextField = findTextFieldByKey(
          textFieldKey('description', testIdentity.id),
        );
        expect(descriptionTextField, findsOneWidget);

        await tester.enterText(descriptionTextField, '');
        await tester.pumpAndSettle();

        verifyPublishButtonState(
          tester,
          l10n.publishToMeetingPlace,
          isEnabled: false,
        );

        await tester.enterText(
          descriptionTextField,
          'This is a custom description for my offer',
        );
        await tester.pumpAndSettle();

        verifyPublishButtonState(
          tester,
          l10n.publishToMeetingPlace,
          isEnabled: true,
        );
        await tapPublishButton(tester, l10n.publishToMeetingPlace);

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
      testWidgets('it publishes the invitation with expiry date', (
        tester,
      ) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();
        const defaultExpiryDays = 3;

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        verifyToggleSwitchStateByKey(
          tester,
          'set_expiry_switch_${testIdentity.id}',
          false,
        );
        await tapToggleSwitchByKey(
          tester,
          'set_expiry_switch_${testIdentity.id}',
        );

        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

        expect(
          publishCall['offerName'],
          l10n.connectWithFirstName(testIdentity.card.firstName),
        );
        expect(publishCall['type'], SDKConnectionOfferType.invitation);
        expect(publishCall['offerDescription'], l10n.passphraseDescription);
        expect(publishCall['customPhrase'], isNull);

        final validUntil = publishCall['validUntil'] as DateTime;
        final expectedExpiry = DateTime.now().add(
          const Duration(days: defaultExpiryDays),
        );
        final difference = validUntil.difference(expectedExpiry).abs();
        expect(difference.inDays == 0, true);

        expect(publishCall['maximumUsage'], isNull);
        expect(
          publishCall['mediatorDid'],
          FakeMediators.defaultMediator.mediatorDid,
        );
        expect(publishCall['externalRef'], testIdentity.id);
      });

      group('and change the expiry date', () {
        testWidgets('it publishes with the new expiry date', (tester) async {
          await withClock(Clock.fixed(DateTime(2026, 6, 15)), () async {
            final l10n = await getL10n();
            final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();
            const expireAfterDays = 5;

            await setupPublishOfferTest(
              tester,
              location,
              testIdentity,
              fakeSdk: fakeMeetingPlaceCoreSDK,
            );

            await tapToggleSwitchByKey(
              tester,
              'set_expiry_switch_${testIdentity.id}',
            );

            final changeButtons = find.text(l10n.changeButton);

            expect(changeButtons, findsWidgets);

            final expiryHelperText = find.text(l10n.selectExpiryHelperText);
            expect(expiryHelperText, findsOneWidget);

            await tester.tap(changeButtons.first);
            await tester.pumpAndSettle();

            final today = clock.now();
            final newExpiryDate = today.add(
              const Duration(days: expireAfterDays),
            );

            await tester.tap(find.text(newExpiryDate.day.toString()).last);
            await tester.pumpAndSettle();

            await tester.tap(find.text('OK'));
            await tester.pumpAndSettle();

            await tester.tap(find.text('OK'));
            await tester.pumpAndSettle();

            await tapPublishButton(tester, l10n.publishToMeetingPlace);

            expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
            final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

            expect(
              publishCall['offerName'],
              l10n.connectWithFirstName(testIdentity.card.firstName),
            );
            expect(publishCall['type'], SDKConnectionOfferType.invitation);
            expect(publishCall['offerDescription'], l10n.passphraseDescription);
            expect(publishCall['customPhrase'], isNull);

            final validUntil = publishCall['validUntil'] as DateTime;
            final expectedExpiry = clock.now().add(
              const Duration(days: expireAfterDays),
            );
            final difference = validUntil.difference(expectedExpiry).abs();
            expect(difference.inDays == 0, true);

            expect(publishCall['maximumUsage'], isNull);
            expect(
              publishCall['mediatorDid'],
              FakeMediators.defaultMediator.mediatorDid,
            );
            expect(publishCall['externalRef'], testIdentity.id);
          });
        });

        group('and switch back to no expiry', () {
          testWidgets(
            'it publishes without expiry after changing date then switching'
            ' back',
            (tester) async {
              await withClock(Clock.fixed(DateTime(2026, 6, 15)), () async {
                final l10n = await getL10n();
                final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

                await setupPublishOfferTest(
                  tester,
                  location,
                  testIdentity,
                  fakeSdk: fakeMeetingPlaceCoreSDK,
                );

                await tapToggleSwitchByKey(
                  tester,
                  'set_expiry_switch_${testIdentity.id}',
                );

                final changeButtons = find.text(l10n.changeButton);
                await tester.tap(changeButtons.first);
                await tester.pumpAndSettle();

                final newExpiryDate = clock.now().add(const Duration(days: 7));
                await tester.tap(find.text(newExpiryDate.day.toString()));
                await tester.pumpAndSettle();

                await tester.tap(find.text('OK'));
                await tester.pumpAndSettle();

                await tester.tap(find.text('OK'));
                await tester.pumpAndSettle();

                await tapToggleSwitchByKey(
                  tester,
                  'set_expiry_switch_${testIdentity.id}',
                );

                expect(find.text(l10n.setExpiryHelperDisabled), findsOneWidget);

                await tapPublishButton(tester, l10n.publishToMeetingPlace);

                expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
                final publishCall =
                    fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

                verifyPublishCall(
                  publishCall,
                  l10n,
                  offerName: l10n.connectWithFirstName(
                    testIdentity.card.firstName,
                  ),
                  type: SDKConnectionOfferType.invitation,
                  offerDescription: l10n.passphraseDescription,
                  customPhrase: null,
                  validUntil: null,
                  maximumUsage: null,
                  mediatorDid: FakeMediators.defaultMediator.mediatorDid,
                  externalRef: testIdentity.id,
                );
              });
            },
          );
        });
      });
    });

    group('and limit number of uses is enabled', () {
      testWidgets('it publishes with default maximum usage of 3', (
        tester,
      ) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
        );

        verifyToggleSwitchStateByKey(
          tester,
          'limit_uses_switch_${testIdentity.id}',
          false,
        );
        await tapToggleSwitchByKey(
          tester,
          'limit_uses_switch_${testIdentity.id}',
        );

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
          maximumUsage: 3,
          mediatorDid: FakeMediators.defaultMediator.mediatorDid,
          externalRef: testIdentity.id,
        );
      });

      group('and change the maximum usage', () {
        testWidgets('it publishes with the new maximum usage of 5', (
          tester,
        ) async {
          final l10n = await getL10n();
          final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

          await setupPublishOfferTest(
            tester,
            location,
            testIdentity,
            fakeSdk: fakeMeetingPlaceCoreSDK,
          );

          await tapToggleSwitchByKey(
            tester,
            'limit_uses_switch_${testIdentity.id}',
          );

          final usageLabel = find.text(l10n.canBeUsedTimes(3));
          expect(usageLabel, findsOneWidget);

          final changeButtons = find.text(l10n.changeButton);
          expect(changeButtons, findsWidgets);
          await tester.ensureVisible(changeButtons.first);
          await tester.tap(changeButtons.first);
          await tester.pumpAndSettle();

          final fiveUsesOption = find.ancestor(
            of: find.text('5'),
            matching: find.byType(ListTile),
          );
          await tester.tap(fiveUsesOption);
          await tester.pumpAndSettle();

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
            maximumUsage: 5,
            mediatorDid: FakeMediators.defaultMediator.mediatorDid,
            externalRef: testIdentity.id,
          );
        });

        group('and switch back to disabled', () {
          testWidgets(
            'it publishes with default limit after changing usage then '
            'switching back',
            (tester) async {
              final l10n = await getL10n();
              final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

              await setupPublishOfferTest(
                tester,
                location,
                testIdentity,
                fakeSdk: fakeMeetingPlaceCoreSDK,
              );

              await tapToggleSwitchByKey(
                tester,
                'limit_uses_switch_${testIdentity.id}',
              );

              final usageLabel = find.text(l10n.canBeUsedTimes(3));
              expect(usageLabel, findsOneWidget);

              final changeButtons = find.text(l10n.changeButton);
              expect(changeButtons, findsWidgets);
              await tester.ensureVisible(changeButtons.first);
              await tester.tap(changeButtons.first);
              await tester.pumpAndSettle();

              final fiveUsesOption = find.ancestor(
                of: find.text('5'),
                matching: find.byType(ListTile),
              );
              await tester.tap(fiveUsesOption);
              await tester.pumpAndSettle();

              expect(find.text(l10n.canBeUsedTimes(5)), findsOneWidget);

              await tapToggleSwitchByKey(
                tester,
                'limit_uses_switch_${testIdentity.id}',
              );

              expect(find.text(l10n.limitUsesHelperDisabled), findsOneWidget);

              await tapPublishButton(tester, l10n.publishToMeetingPlace);

              expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
              final publishCall =
                  fakeMeetingPlaceCoreSDK.publishOfferCalls.first;

              verifyPublishCall(
                publishCall,
                l10n,
                offerName: l10n.connectWithFirstName(
                  testIdentity.card.firstName,
                ),
                type: SDKConnectionOfferType.invitation,
                offerDescription: l10n.passphraseDescription,
                customPhrase: null,
                validUntil: null,
                maximumUsage: null,
                mediatorDid: FakeMediators.defaultMediator.mediatorDid,
                externalRef: testIdentity.id,
              );
            },
          );
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

        expect(
          find.text(FakeMediators.defaultMediator.mediatorName),
          findsOneWidget,
        );

        final changeButton = find.text(l10n.changeButton);
        expect(changeButton, findsOneWidget);
        await tester.ensureVisible(changeButton);
        await tester.tap(changeButton);
        await tester.pumpAndSettle();

        final customMediatorOption = find.text(
          FakeMediators.customMediator.mediatorName,
        );
        await tester.tap(customMediatorOption);
        await tester.pumpAndSettle();

        expect(
          find.text(FakeMediators.customMediator.mediatorName),
          findsOneWidget,
        );

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
          mediatorDid: FakeMediators.customMediator.mediatorDid,
          externalRef: testIdentity.id,
        );
      });
    });

    group('and the user has VRCs', () {
      List<Vrc> makeVrcs(int count, {String? holderDid}) => List.generate(
        count,
        (i) => Vrc(
          id: 'vrc-$i',
          vcBlob: 'blob-$i',
          channelId: 'channel-$i',
          holderDid: holderDid ?? testIdentity.did,
          issuerDid: 'did:key:issuer-$i',
          issuedAt: DateTime(2024, 1, i + 1),
        ),
      );

      testWidgets('it passes score 1 when the user has exactly 1 VRC', (
        tester,
      ) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
          vrcs: makeVrcs(1),
        );

        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;
        expect(publishCall['score'], 1);
      });

      testWidgets('it passes the current VRC score when publishing', (
        tester,
      ) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
          vrcs: makeVrcs(3),
        );

        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;
        expect(publishCall['score'], 3);
      });

      testWidgets('it only counts VRCs belonging to the publishing identity', (
        tester,
      ) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
          vrcs: makeVrcs(3, holderDid: 'did:key:other-identity'),
        );

        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;
        expect(publishCall['score'], 0);
      });

      testWidgets('it passes the VRC score for group offers', (tester) async {
        final l10n = await getL10n();
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceSDK();

        await setupPublishOfferTest(
          tester,
          location,
          testIdentity,
          fakeSdk: fakeMeetingPlaceCoreSDK,
          vrcs: makeVrcs(3),
        );

        await tapToggleSwitchByKey(
          tester,
          switchKey('group_offer', testIdentity.id),
        );

        await tapPublishButton(tester, l10n.publishToMeetingPlace);

        expect(fakeMeetingPlaceCoreSDK.publishOfferCalls, hasLength(1));
        final publishCall = fakeMeetingPlaceCoreSDK.publishOfferCalls.first;
        expect(publishCall['type'], SDKConnectionOfferType.groupInvitation);
        expect(publishCall['score'], 3);
      });
    });
  });
}
