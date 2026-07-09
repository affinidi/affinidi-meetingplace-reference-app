import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/navigation/routes/route_paths.dart';

import 'fakes/fake_connectivity.dart';
import 'fakes/fake_meeting_place_matrix_sdk.dart';
import 'fakes/fake_push_notification_messaging.dart';
import 'fakes/fake_secure_storage.dart';
import 'utils/app.dart';

void main() {
  const apnsAttemptInitialInterval = Duration(milliseconds: 500);
  group('When retrieving the push notification token', () {
    final location = RoutePaths.root;
    group('and there is no network', () {
      final fakeConnectivity = FakeConnectivity(
        initialConnectivityToReturn: [ConnectivityResult.none],
      );

      testWidgets('it shows a network error banner', (tester) async {
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceMatrixSDK();

        await navigateToLocation(
          tester,
          location,
          connectivity: fakeConnectivity,
          pushNotificationMessaging: FakePushNotificationMessaging(
            attemptsToFailGettingToken: 10,
            attemptsToFailGettingApnsToken: 1,
          ),
          meetingPlaceCoreSDK: fakeMeetingPlaceCoreSDK,
        );
        await tester.binding.delayed(apnsAttemptInitialInterval);
        await tester.pumpAndSettle();

        final l10n = await getL10n();
        expect(find.text(l10n.networkDisconnected), findsOneWidget);
        expect(fakeMeetingPlaceCoreSDK.tokenRegistrationsAttempts, 0);
      });

      group('and connectivity is restored', () {
        final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceMatrixSDK();

        testWidgets('it hides the network error banner', (tester) async {
          await navigateToLocation(
            tester,
            location,
            connectivity: fakeConnectivity,
            pushNotificationMessaging: FakePushNotificationMessaging(
              attemptsToFailGettingToken: 1,
              tokenToReturn: 'a token after restoring connectivity',
            ),
            meetingPlaceCoreSDK: fakeMeetingPlaceCoreSDK,
          );
          await tester.pumpAndSettle();

          final l10n = await getL10n();
          fakeConnectivity.emitConnectivityChange([ConnectivityResult.wifi]);
          await tester.pumpAndSettle();

          expect(find.text(l10n.networkDisconnected), findsNothing);
          expect(fakeMeetingPlaceCoreSDK.tokenRegistrationsAttempts, 1);
        });
      });
    });

    group('and there is network', () {
      final fakeConnectivity = FakeConnectivity(
        initialConnectivityToReturn: [ConnectivityResult.wifi],
      );
      testWidgets('it does not show a network error banner', (tester) async {
        await navigateToLocation(
          tester,
          location,
          isAuthenticated: true,
          pushNotificationMessaging: FakePushNotificationMessaging(),
          connectivity: fakeConnectivity,
        );
        await tester.pumpAndSettle();

        final l10n = await getL10n();
        expect(find.text(l10n.networkDisconnected), findsNothing);

        fakeConnectivity.emitConnectivityChange([ConnectivityResult.none]);
        await tester.pumpAndSettle();

        expect(find.text(l10n.networkDisconnected), findsOneWidget);
      });

      group('and connectivity is lost', () {
        testWidgets('it shows a network error banner', (tester) async {
          await navigateToLocation(
            tester,
            location,
            connectivity: fakeConnectivity,
          );
          await tester.pumpAndSettle();

          fakeConnectivity.emitConnectivityChange([ConnectivityResult.none]);
          await tester.pumpAndSettle();

          final l10n = await getL10n();

          expect(find.text(l10n.networkDisconnected), findsOneWidget);
        });
      });

      group('and it fails to retrieve a push notification token', () {
        testWidgets('it shows a network error banner', (tester) async {
          await navigateToLocation(
            tester,
            location,
            pushNotificationMessaging: FakePushNotificationMessaging(
              attemptsToFailGettingToken: 1,
            ),
            connectivity: fakeConnectivity,
          );
          await tester.pumpAndSettle();

          final l10n = await getL10n();
          expect(find.text(l10n.networkDisconnected), findsOneWidget);
        });
      });

      group('and it finds a device token', () {
        final deviceToken = 'a_device_token';

        group('and successfully registers it', () {
          final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceMatrixSDK(
            shouldFailToRegisterPushToken: false,
          );
          testWidgets('it does not show a network error banner', (
            tester,
          ) async {
            await navigateToLocation(
              tester,
              location,
              pushNotificationMessaging: FakePushNotificationMessaging(
                tokenToReturn: deviceToken,
              ),
              connectivity: fakeConnectivity,
              meetingPlaceCoreSDK: fakeMeetingPlaceCoreSDK,
            );
            await tester.pumpAndSettle();

            final l10n = await getL10n();
            expect(find.text(l10n.networkDisconnected), findsNothing);
            expect(fakeMeetingPlaceCoreSDK.tokenRegistrationsAttempts, 1);
            expect(fakeMeetingPlaceCoreSDK.lastRegisteredToken, deviceToken);
          });

          group('and connectivity is lost and retrieved again', () {
            testWidgets('it does not try to register the same token again', (
              tester,
            ) async {
              final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceMatrixSDK(
                shouldFailToRegisterPushToken: false,
              );

              await navigateToLocation(
                tester,
                location,
                pushNotificationMessaging: FakePushNotificationMessaging(
                  tokenToReturn: deviceToken,
                ),
                connectivity: fakeConnectivity,
                meetingPlaceCoreSDK: fakeMeetingPlaceCoreSDK,
              );

              await tester.pumpAndSettle();

              fakeConnectivity.emitConnectivityChange([
                ConnectivityResult.none,
              ]);
              await tester.pumpAndSettle();

              fakeConnectivity.emitConnectivityChange([
                ConnectivityResult.wifi,
              ]);
              await tester.pumpAndSettle();

              expect(fakeMeetingPlaceCoreSDK.tokenRegistrationsAttempts, 1);
              expect(fakeMeetingPlaceCoreSDK.lastRegisteredToken, deviceToken);
            });
          });
        });

        group('and it fails to register it', () {
          final shouldFailToRegisterPushToken = true;
          testWidgets('it shows a network error banner', (tester) async {
            final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceMatrixSDK(
              shouldFailToRegisterPushToken: shouldFailToRegisterPushToken,
            );

            await navigateToLocation(
              tester,
              location,
              pushNotificationMessaging: FakePushNotificationMessaging(
                tokenToReturn: deviceToken,
              ),
              connectivity: fakeConnectivity,
              meetingPlaceCoreSDK: fakeMeetingPlaceCoreSDK,
            );

            await tester.pumpAndSettle();

            final l10n = await getL10n();
            expect(find.text(l10n.networkDisconnected), findsOneWidget);
            expect(fakeMeetingPlaceCoreSDK.tokenRegistrationsAttempts, 1);
          });

          group('and user changes connectivity status', () {
            testWidgets('it attempts to register the token again', (
              tester,
            ) async {
              final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceMatrixSDK(
                shouldFailToRegisterPushToken: shouldFailToRegisterPushToken,
              );

              await navigateToLocation(
                tester,
                location,
                pushNotificationMessaging: FakePushNotificationMessaging(
                  tokenToReturn: deviceToken,
                ),
                connectivity: fakeConnectivity,
                meetingPlaceCoreSDK: fakeMeetingPlaceCoreSDK,
              );

              await tester.pumpAndSettle();
              expect(fakeMeetingPlaceCoreSDK.tokenRegistrationsAttempts, 1);

              fakeConnectivity.emitConnectivityChange([
                ConnectivityResult.none,
              ]);

              await tester.pumpAndSettle();

              fakeConnectivity.emitConnectivityChange([
                ConnectivityResult.wifi,
              ]);
              await tester.pumpAndSettle();

              expect(fakeMeetingPlaceCoreSDK.tokenRegistrationsAttempts, 2);
              expect(fakeMeetingPlaceCoreSDK.lastRegisteredToken, null);
            });
          });

          group('and multiple tokens arrive in a short period', () {
            testWidgets('it handles them synchronously', (tester) async {
              final fakeMeetingPlaceCoreSDK = FakeMeetingPlaceMatrixSDK(
                shouldFailToRegisterPushToken: false,
              );
              final savingPushTokenDuration = 100;
              final fakeSecureStorage = FakeSecureStorage(
                savingPushTokenDuration: savingPushTokenDuration,
              );
              final fakePushNotificationMessaging =
                  FakePushNotificationMessaging();

              final multipleTokens = () async {
                await navigateToLocation(
                  tester,
                  location,
                  pushNotificationMessaging: fakePushNotificationMessaging,
                  connectivity: fakeConnectivity,
                  meetingPlaceCoreSDK: fakeMeetingPlaceCoreSDK,
                  secureStorage: fakeSecureStorage,
                );
                await tester.pumpAndSettle();

                final tokenList = ['token 1', 'token 2'];
                await fakePushNotificationMessaging.emitRefreshTokens(
                  tokenList,
                );
                await tester.binding.delayed(
                  Duration(
                    milliseconds: tokenList.length * savingPushTokenDuration,
                  ),
                );
              }();

              await expectLater(multipleTokens, completes);
            });
          });
        });
      });
    });
  });
}
