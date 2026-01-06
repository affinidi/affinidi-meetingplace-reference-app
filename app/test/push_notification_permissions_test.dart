import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/navigation/routes/route_paths.dart';

import 'fakes/fake_push_notification_messaging.dart';
import 'utils/app.dart';

void main() {
  group('When opening the app', () {
    final location = RoutePaths.root;
    group('and app is locked', () {
      final isAuthenticated = false;

      testWidgets('it does not request push notifications permissions',
          (tester) async {
        final pushNotificationMessaging = FakePushNotificationMessaging();

        await navigateToLocation(
          tester,
          location,
          isAuthenticated: isAuthenticated,
          pushNotificationMessaging: pushNotificationMessaging,
        );
        await tester.pumpAndSettle();

        expect(pushNotificationMessaging.permissionsRequested, isFalse);
        expect(
          pushNotificationMessaging.foregroundPresentationAlertRequested,
          isFalse,
        );
        expect(
          pushNotificationMessaging.foregroundPresentationBadgeRequested,
          isFalse,
        );
        expect(
          pushNotificationMessaging.foregroundPresentationSoundRequested,
          isFalse,
        );
      });
    });

    group('and app is not locked', () {
      final isAuthenticated = true;

      testWidgets('it requests push notifications permissions', (tester) async {
        final pushNotificationMessaging = FakePushNotificationMessaging();

        await navigateToLocation(
          tester,
          location,
          isAuthenticated: isAuthenticated,
          pushNotificationMessaging: pushNotificationMessaging,
        );
        await tester.pumpAndSettle();

        expect(pushNotificationMessaging.permissionsRequested, isTrue);
        expect(
          pushNotificationMessaging.foregroundPresentationAlertRequested,
          isFalse,
        );
        expect(
          pushNotificationMessaging.foregroundPresentationBadgeRequested,
          isFalse,
        );
        expect(
          pushNotificationMessaging.foregroundPresentationSoundRequested,
          isFalse,
        );
      });
    });
  });
}
