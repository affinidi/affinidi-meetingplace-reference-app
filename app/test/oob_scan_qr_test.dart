import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/exceptions/app_exception_type.dart';
import 'package:mpx_flutter_reference_app/presentation/dialogs/qr_code_picker/qr_code_picker.dart';

import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

const _mockCameras = [
  CameraDescription(
    name: 'Mock Back Camera',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 90,
  ),
];

void main() {
  group('When scanning OOB QR code', () {
    final testIdentity = FakeIdentities.primaryIdentity;
    final location = '/connections/oob-scan-qr';

    group('and rendering the screen', () {
      testWidgets('should display QR code scanner', (tester) async {
        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          cameras: _mockCameras,
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('oob_scan_qr_screen_scaffold')),
          findsOneWidget,
        );
      });
    });

    group('and scan a QR code', () {
      group('and QR code is valid', () {
        testWidgets(
          'should call acceptOobFlow with correct params when QR is detected',
          (tester) async {
            final fakeSdk = FakeMeetingPlaceSDK();
            final testQrUrl = 'https://example.com/oob?_oob=test-token';

            await navigateToLocation(
              tester,
              location,
              identities: [testIdentity],
              meetingPlaceCoreSDK: fakeSdk,
              cameras: _mockCameras,
            );
            await tester.pumpAndSettle();

            final qrCodePicker = find.byType(QrCodePicker);
            expect(qrCodePicker, findsOneWidget);

            final pickerWidget = tester.widget<QrCodePicker>(qrCodePicker);

            pickerWidget.onDetectCode!(testQrUrl);
            await tester.pump();

            expect(fakeSdk.acceptOobFlowCalls.length, equals(1));
            expect(
              fakeSdk.acceptOobFlowCalls.first['offerLink'],
              equals(testQrUrl),
            );
            expect(fakeSdk.acceptOobFlowCalls.first['contactCard'], isNotNull);

            final channel =
                fakeSdk.acceptOobFlowCalls.first['channel'] as Channel;
            fakeSdk.simulateOobAcceptConnectionEstablished(channel);
            await tester.pumpAndSettle();

            expect(
              find.byKey(const Key('oob_scan_qr_screen_scaffold')),
              findsNothing,
            );
          },
        );
      });

      group('and QR code is not a url', () {
        testWidgets('should show invalid QR-Code error message', (
          tester,
        ) async {
          final fakeSdk = FakeMeetingPlaceSDK();
          final testQrUrl = '{"key": "This is not a url"}';

          await navigateToLocation(
            tester,
            location,
            identities: [testIdentity],
            meetingPlaceCoreSDK: fakeSdk,
            cameras: _mockCameras,
          );
          await tester.pumpAndSettle();

          final qrCodePicker = find.byType(QrCodePicker);
          expect(qrCodePicker, findsOneWidget);

          final pickerWidget = tester.widget<QrCodePicker>(qrCodePicker);

          pickerWidget.onDetectCode!(testQrUrl);
          await tester.pumpAndSettle();
          final l10n = await getL10n();
          expect(
            find.text(l10n.error(AppExceptionType.invalidQrCode.name)),
            findsOneWidget,
          );
        });
      });

      group('and type is not supported', () {
        testWidgets('should show type is not supported error message', (
          tester,
        ) async {
          final errorCode = 'oob_invalid_type';
          final fakeSdk = FakeMeetingPlaceSDK(
            acceptOobFlowException: MeetingPlaceCoreSDKException(
              message: 'Oob type is not supported',
              code: errorCode,
              innerException: Object(),
            ),
          );
          final testQrUrl = 'https://example.com/oob?_oob=test-token';

          await navigateToLocation(
            tester,
            location,
            identities: [testIdentity],
            meetingPlaceCoreSDK: fakeSdk,
            cameras: _mockCameras,
          );
          await tester.pumpAndSettle();

          final qrCodePicker = find.byType(QrCodePicker);
          expect(qrCodePicker, findsOneWidget);

          final pickerWidget = tester.widget<QrCodePicker>(qrCodePicker);

          pickerWidget.onDetectCode!(testQrUrl);
          await tester.pumpAndSettle();
          final l10n = await getL10n();
          expect(find.text(l10n.error(errorCode)), findsOneWidget);
        });
      });

      group('and there is a network error', () {
        testWidgets('should show network error message', (tester) async {
          final errorCode = 'network_error';
          final fakeSdk = FakeMeetingPlaceSDK(
            acceptOobFlowException: MeetingPlaceCoreSDKException(
              message: 'Network error',
              code: errorCode,
              innerException: Object(),
            ),
          );
          final testQrUrl = 'https://example.com/oob?_oob=test-token';

          await navigateToLocation(
            tester,
            location,
            identities: [testIdentity],
            meetingPlaceCoreSDK: fakeSdk,
            cameras: _mockCameras,
          );
          await tester.pumpAndSettle();

          final qrCodePicker = find.byType(QrCodePicker);
          expect(qrCodePicker, findsOneWidget);

          final pickerWidget = tester.widget<QrCodePicker>(qrCodePicker);

          pickerWidget.onDetectCode!(testQrUrl);
          await tester.pumpAndSettle();
          final l10n = await getL10n();
          expect(find.text(l10n.error(errorCode)), findsOneWidget);
        });
      });

      group('and data is not valid', () {
        testWidgets('should show invalid QR-Code error message', (
          tester,
        ) async {
          final errorCode = 'oob_invalid_data';
          final fakeSdk = FakeMeetingPlaceSDK(
            acceptOobFlowException: MeetingPlaceCoreSDKException(
              message: 'Invalid OOB data',
              code: errorCode,
              innerException: Object(),
            ),
          );
          final testQrUrl = 'https://example.com/oob?_oob=test-token';

          await navigateToLocation(
            tester,
            location,
            identities: [testIdentity],
            meetingPlaceCoreSDK: fakeSdk,
            cameras: _mockCameras,
          );
          await tester.pumpAndSettle();

          final qrCodePicker = find.byType(QrCodePicker);
          expect(qrCodePicker, findsOneWidget);

          final pickerWidget = tester.widget<QrCodePicker>(qrCodePicker);

          pickerWidget.onDetectCode!(testQrUrl);
          await tester.pumpAndSettle();
          final l10n = await getL10n();
          expect(find.text(l10n.error(errorCode)), findsOneWidget);
        });
      });

      group('and data is not found', () {
        testWidgets('should show not found QR-Code error message', (
          tester,
        ) async {
          final errorCode = 'oob_not_found';
          final fakeSdk = FakeMeetingPlaceSDK(
            acceptOobFlowException: MeetingPlaceCoreSDKException(
              message: 'OOB offer not found',
              code: errorCode,
              innerException: Object(),
            ),
          );
          final testQrUrl = 'https://example.com/oob?_oob=test-token';

          await navigateToLocation(
            tester,
            location,
            identities: [testIdentity],
            meetingPlaceCoreSDK: fakeSdk,
            cameras: _mockCameras,
          );
          await tester.pumpAndSettle();

          final qrCodePicker = find.byType(QrCodePicker);
          expect(qrCodePicker, findsOneWidget);

          final pickerWidget = tester.widget<QrCodePicker>(qrCodePicker);

          pickerWidget.onDetectCode!(testQrUrl);
          await tester.pumpAndSettle();
          final l10n = await getL10n();
          expect(find.text(l10n.error(errorCode)), findsOneWidget);
        });
      });

      group('and there is an unexpected error', () {
        testWidgets('should show unexpected error message', (tester) async {
          final errorCode = 'generic';
          final fakeSdk = FakeMeetingPlaceSDK(
            acceptOobFlowException: MeetingPlaceCoreSDKException(
              message: 'Unexpected error',
              code: errorCode,
              innerException: Object(),
            ),
          );
          final testQrUrl = 'https://example.com/oob?_oob=test-token';

          await navigateToLocation(
            tester,
            location,
            identities: [testIdentity],
            meetingPlaceCoreSDK: fakeSdk,
            cameras: _mockCameras,
          );
          await tester.pumpAndSettle();

          final qrCodePicker = find.byType(QrCodePicker);
          expect(qrCodePicker, findsOneWidget);

          final pickerWidget = tester.widget<QrCodePicker>(qrCodePicker);

          pickerWidget.onDetectCode!(testQrUrl);
          await tester.pumpAndSettle();
          final l10n = await getL10n();
          expect(find.text(l10n.error(errorCode)), findsOneWidget);
        });

        group('and connection times out', () {
          testWidgets('should show timeout error message and stay on screen', (
            tester,
          ) async {
            final fakeSdk = FakeMeetingPlaceSDK(shouldTimeout: true);
            final testQrUrl = 'https://example.com/oob?_oob=test-token';

            await navigateToLocation(
              tester,
              location,
              identities: [testIdentity],
              meetingPlaceCoreSDK: fakeSdk,
              cameras: _mockCameras,
            );
            await tester.pumpAndSettle();

            final qrCodePicker = find.byType(QrCodePicker);
            expect(qrCodePicker, findsOneWidget);

            final pickerWidget = tester.widget<QrCodePicker>(qrCodePicker);

            pickerWidget.onDetectCode!(testQrUrl);
            await tester.pumpAndSettle();
            final l10n = await getL10n();
            expect(
              find.text(l10n.error(AppExceptionType.oobFlowTimedOut.name)),
              findsOneWidget,
            );
          });
        });

        group('and scanning multiple QR codes in sequence', () {
          testWidgets(
            '''should dispose previous subscription before accepting new QR code''',
            (tester) async {
              final fakeSdk = FakeMeetingPlaceSDK(shouldTimeout: true);
              final firstQrUrl = 'https://example.com/oob?_oob=first-token';
              final secondQrUrl = 'https://example.com/oob?_oob=second-token';

              await navigateToLocation(
                tester,
                location,
                identities: [testIdentity],
                meetingPlaceCoreSDK: fakeSdk,
                cameras: _mockCameras,
              );
              await tester.pumpAndSettle();

              final qrCodePicker = find.byType(QrCodePicker);
              expect(qrCodePicker, findsOneWidget);

              final pickerWidget = tester.widget<QrCodePicker>(qrCodePicker);

              // Scan first QR code
              pickerWidget.onDetectCode!(firstQrUrl);
              await tester.pumpAndSettle();

              expect(fakeSdk.acceptOobFlowCalls.length, equals(1));
              expect(
                fakeSdk.acceptOobFlowCalls.first['offerLink'],
                equals(firstQrUrl),
              );

              // Scan second QR code
              pickerWidget.onDetectCode!(secondQrUrl);
              await tester.pumpAndSettle();

              // Should have called acceptOobFlow twice
              expect(fakeSdk.acceptOobFlowCalls.length, equals(2));
              expect(
                fakeSdk.acceptOobFlowCalls.last['offerLink'],
                equals(secondQrUrl),
              );

              // Should have disposed the first subscription
              expect(fakeSdk.acceptOobStreamDisposals.length, equals(1));
              expect(
                fakeSdk.acceptOobStreamDisposals.first,
                equals(firstQrUrl),
              );
            },
          );
        });
      });

      group('and OOB contact exists in contacts list', () {
        testWidgets(
          'should show notification off badge icon instead of count badge',
          (tester) async {
            await navigateToLocation(
              tester,
              '/contacts',
              isAuthenticated: true,
              alreadyOnboarded: true,
              identities: [testIdentity],
              contacts: [FakeContacts.oobContact],
            );
            await tester.pumpAndSettle();

            expect(
              find.byIcon(Icons.notifications_off_outlined),
              findsOneWidget,
            );

            expect(find.text('0'), findsNothing);
          },
        );
      });
    });
  });
}
