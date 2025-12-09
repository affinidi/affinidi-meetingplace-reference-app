import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/navigation/routes/route_paths.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/authentication/authentication_screen/authentication_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/onboarding/onboarding_screen/onboarding_screen.dart';

import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'utils/app.dart';

void main() {
  group('When opening the app on default location', () {
    final location = RoutePaths.root;
    group('and app is locked', () {
      final isAuthenticated = false;

      group('and user is not onboarded', () {
        final alreadyOnboarded = false;
        testWidgets('it shows the lock screen', (tester) async {
          await navigateToLocation(
            tester,
            location,
            isAuthenticated: isAuthenticated,
            alreadyOnboarded: alreadyOnboarded,
          );
          await tester.pumpAndSettle();

          expect(find.byType(AuthenticationScreen), findsOneWidget);
        });
      });

      group('and user is onboarded', () {
        final alreadyOnboarded = true;
        testWidgets('it shows the lock screen', (tester) async {
          await navigateToLocation(
            tester,
            location,
            isAuthenticated: isAuthenticated,
            alreadyOnboarded: alreadyOnboarded,
          );
          await tester.pumpAndSettle();

          expect(find.byType(AuthenticationScreen), findsOneWidget);
        });
      });
    });

    group('and app is unlocked', () {
      final isAuthenticated = true;
      group('and user is not onboarded', () {
        final alreadyOnboarded = false;
        testWidgets('it shows the onboarding screen', (tester) async {
          await navigateToLocation(
            tester,
            location,
            isAuthenticated: isAuthenticated,
            alreadyOnboarded: alreadyOnboarded,
          );
          await tester.pumpAndSettle();

          expect(find.byType(OnboardingScreen), findsOneWidget);
        });
      });

      group('and user is onboarded', () {
        final alreadyOnboarded = true;

        group('and no primary identity exists', () {
          testWidgets('it shows the primary identity creation screen',
              (tester) async {
            await navigateToLocation(
              tester,
              '/',
              isAuthenticated: isAuthenticated,
              alreadyOnboarded: alreadyOnboarded,
            );
            await tester.pumpAndSettle();

            final l10n = await getL10n();
            expect(find.text(l10n.setupPrimaryIdentityTitle), findsOneWidget);
          });
        });

        group('and a primary identity already exists', () {
          testWidgets('it shows the channel screen', (tester) async {
            await navigateToLocation(tester, '/',
                isAuthenticated: isAuthenticated,
                alreadyOnboarded: alreadyOnboarded,
                identities: [
                  FakeIdentities.primaryIdentity,
                ]);
            await tester.pumpAndSettle();

            final l10n = await getL10n();
            expect(find.text(l10n.contactsPanelSubtitle), findsOneWidget);
          });
        });
      });
    });
  });

  group('When opening the app on authentication screen', () {
    final location = RoutePaths.authentication;
    final isAuthenticated = true;
    final alreadyOnboarded = true;

    testWidgets('it shows the connections screen', (tester) async {
      await navigateToLocation(tester, location,
          isAuthenticated: isAuthenticated,
          alreadyOnboarded: alreadyOnboarded,
          identities: [
            FakeIdentities.primaryIdentity,
          ]);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.contactsPanelSubtitle), findsOneWidget);
    });
  });

  group('When opening the app on onboarding screen', () {
    final location = RoutePaths.onboarding;
    final isAuthenticated = true;
    final alreadyOnboarded = true;

    testWidgets('it shows the connections screen', (tester) async {
      await navigateToLocation(tester, location,
          isAuthenticated: isAuthenticated,
          alreadyOnboarded: alreadyOnboarded,
          identities: [
            FakeIdentities.primaryIdentity,
          ]);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.contactsPanelSubtitle), findsOneWidget);
    });
  });

  group('When opening the app on channels tab', () {
    final location = RoutePaths.contacts;

    testWidgets('it shows the channels screen', (tester) async {
      await navigateToLocation(tester, location,
          isAuthenticated: true,
          alreadyOnboarded: true,
          identities: [
            FakeIdentities.primaryIdentity,
          ]);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.contactsPanelSubtitle), findsOneWidget);
    });
  });

  group('When opening the app on connections tab', () {
    final location = RoutePaths.connections;
    final isAuthenticated = true;
    final alreadyOnboarded = true;

    testWidgets('it shows the connections screen', (tester) async {
      await navigateToLocation(tester, location,
          isAuthenticated: isAuthenticated,
          alreadyOnboarded: alreadyOnboarded,
          identities: [
            FakeIdentities.primaryIdentity,
          ]);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.connectionsPanelSubtitle), findsOneWidget);
    });
  });

  group('When opening the app on identities tab', () {
    final location = RoutePaths.identities;
    final isAuthenticated = true;
    final alreadyOnboarded = true;

    testWidgets('it shows the identities screen', (tester) async {
      await navigateToLocation(tester, location,
          isAuthenticated: isAuthenticated,
          alreadyOnboarded: alreadyOnboarded,
          identities: [
            FakeIdentities.primaryIdentity,
          ]);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.identitiesPanelSubtitle), findsOneWidget);
    });
  });

  group('When opening the app on settings tab', () {
    final location = RoutePaths.settings;
    final isAuthenticated = true;
    final alreadyOnboarded = true;

    testWidgets('it shows the settings screen', (tester) async {
      await navigateToLocation(tester, location,
          isAuthenticated: isAuthenticated,
          alreadyOnboarded: alreadyOnboarded,
          identities: [
            FakeIdentities.primaryIdentity,
          ]);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.settingsScreenSubtitle), findsOneWidget);
    });
  });

  group('When opening the app on publish offer', () {
    final location =
        '/connections/publish-offer?identity-id=primary-identity-id';
    testWidgets('it shows the publish offer screen', (tester) async {
      await navigateToLocation(tester, location, identities: [
        FakeIdentities.primaryIdentity,
      ]);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.publishOffer), findsOneWidget);
    });
  });

  group('When opening the app on find offer', () {
    final location =
        '/connections/find-offer?identity-id=${FakeIdentities.primaryIdentity.id}';
    testWidgets('it shows the find offer screen', (tester) async {
      await navigateToLocation(tester, location, identities: [
        FakeIdentities.primaryIdentity,
      ]);
      await tester.pumpAndSettle();

      final l10n = await getL10n();
      expect(find.text(l10n.claimOfferTitle), findsOneWidget);
    });
  });

  group('When opening the app on chat screen', () {
    final isAuthenticated = true;
    final alreadyOnboarded = true;

    group('for an individual contact', () {
      final location = '/contacts/${FakeContacts.individualContact.id}/chat';

      testWidgets('it shows the chat screen', (tester) async {
        final meetingPlaceChatSDK = FakeChatSdk();

        await navigateToLocation(
          tester,
          location,
          isAuthenticated: isAuthenticated,
          alreadyOnboarded: alreadyOnboarded,
          identities: [FakeIdentities.primaryIdentity],
          contacts: [FakeContacts.individualContact],
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );

        await tester.pumpAndSettle();

        expect(meetingPlaceChatSDK.startChatSessionCallCount, 1);
      });
    });

    group('for a group contact', () {
      final location = '/contacts/${FakeContacts.groupContact.id}/chat';

      testWidgets('it shows the group chat screen', (tester) async {
        final meetingPlaceChatSDK = FakeChatSdk();

        await navigateToLocation(
          tester,
          location,
          isAuthenticated: isAuthenticated,
          alreadyOnboarded: alreadyOnboarded,
          identities: [FakeIdentities.primaryIdentity],
          contacts: [FakeContacts.groupContact],
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );

        await tester.pumpAndSettle();

        expect(meetingPlaceChatSDK.startChatSessionCallCount, 1);
      });
    });
  });
}
