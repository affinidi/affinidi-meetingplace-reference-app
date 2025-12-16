import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import 'fakes/fake_identities.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'fakes/fake_qr_code_view_factory.dart';
import 'fakes/fake_share_service.dart';
import 'utils/app.dart';

void main() {
  group('When sharing OOB QR code', () {
    final testIdentity = FakeIdentities.primaryIdentity;
    final location = '/connections/oob-share-qr';

    group('and rendering the screen', () {
      testWidgets('should display the screen title and QR instructions',
          (tester) async {
        final l10n = await getL10n();
        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
        );
        await tester.pumpAndSettle();

        expect(find.text(l10n.oobQrPresentInvitationMessage), findsOneWidget);
      });

      testWidgets('should display cancel button', (tester) async {
        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      });

      testWidgets('should display share CTA when QR is generated',
          (tester) async {
        final l10n = await getL10n();
        final fakeSdk = FakeMeetingPlaceSDK();

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        await tester.pumpAndSettle();

        expect(find.text(l10n.shareSheetCTA_QRCode), findsOneWidget);
      });
    });

    group('and is initialized', () {
      testWidgets('should call createOobFlow on initialization',
          (tester) async {
        final fakeSdk = FakeMeetingPlaceSDK();

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        expect(fakeSdk.createOobFlowCalls.length, greaterThan(0));
      });

      testWidgets('should pass correct vCard to createOobFlow', (tester) async {
        final fakeSdk = FakeMeetingPlaceSDK();

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        final calls = fakeSdk.createOobFlowCalls;
        expect(calls.isNotEmpty, true);
        expect(calls.first['vCard'], isNotNull);
      });

      testWidgets('should display QR code after successful OOB creation',
          (tester) async {
        final fakeSdk = FakeMeetingPlaceSDK();

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        final l10n = await getL10n();
        expect(find.text(l10n.generatingQrCode), findsNothing);
      });
    });

    group('and handling connection flow', () {
      testWidgets(
          'should navigate back with channel when connection established',
          (tester) async {
        final fakeSdk = FakeMeetingPlaceSDK();
        final fakeChannel = Channel(
          offerLink: 'test-offer-link',
          publishOfferDid: 'test-publish-did',
          mediatorDid: 'test-mediator-did',
          status: ChannelStatus.inaugurated,
          outboundMessageId: 'test-message-id',
          acceptOfferDid: 'test-accept-did',
          permanentChannelDid: 'test-permanent-did',
          type: ChannelType.oob,
          vCard: VCard(values: {}),
        );

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        fakeSdk.simulateOobConnectionEstablished(fakeChannel);
        await tester.pumpAndSettle();
      });
    });

    group('and user interacts with the screen', () {
      testWidgets('should cancel flow when cancel button tapped',
          (tester) async {
        final fakeSdk = FakeMeetingPlaceSDK();

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        final cancelButton = find.byIcon(Icons.cancel_outlined);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
      });

      testWidgets(
          'should call ShareService with correct params when share'
          ' CTA is tapped', (tester) async {
        final l10n = await getL10n();
        final fakeSdk = FakeMeetingPlaceSDK();
        final fakeShareService = FakeShareService();
        final fakeQrCodeViewFactory = FakeQrCodeViewFactory();

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
          shareService: fakeShareService,
          qrCodeViewFactory: fakeQrCodeViewFactory,
        );
        await tester.pumpAndSettle();

        final shareCTA = find.text(l10n.shareSheetCTA_QRCode);
        expect(shareCTA, findsOneWidget);

        await tester.tap(shareCTA);
        await tester.pumpAndSettle();

        expect(fakeShareService.sharedParams.length, equals(1));
        expect(fakeShareService.sharedParams.first.title,
            equals(l10n.meetingPlaceInvitationTitle));
      });
    });

    group('and handling errors', () {
      testWidgets('should call retry method when retry button is tapped',
          (tester) async {
        final l10n = await getL10n();
        final fakeSdk = FakeMeetingPlaceSDK(
          createOobFlowException: Exception('Failed to create OOB flow'),
        );

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        await tester.pumpAndSettle();

        final initialCallCount = fakeSdk.createOobFlowCalls.length;

        final retryButton =
            find.widgetWithText(FilledButton, l10n.generalRetry);
        expect(retryButton, findsOneWidget);

        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        expect(
            fakeSdk.createOobFlowCalls.length, greaterThan(initialCallCount));
      });
    });

    group('and showing loading states', () {
      testWidgets('should hide loading indicator after QR generation',
          (tester) async {
        final l10n = await getL10n();
        final fakeSdk = FakeMeetingPlaceSDK();

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        expect(find.text(l10n.generatingQrCode), findsNothing);
      });
    });

    group('and handling edge cases', () {
      testWidgets('should handle connection established after cancellation',
          (tester) async {
        final fakeSdk = FakeMeetingPlaceSDK();

        await navigateToLocation(
          tester,
          location,
          identities: [testIdentity],
          meetingPlaceCoreSDK: fakeSdk,
        );
        await tester.pumpAndSettle();

        final cancelButton = find.byIcon(Icons.cancel_outlined);
        await tester.tap(cancelButton);
        await tester.pump();

        final fakeChannel = Channel(
          offerLink: 'test-offer-link',
          publishOfferDid: 'test-publish-did',
          mediatorDid: 'test-mediator-did',
          status: ChannelStatus.inaugurated,
          outboundMessageId: 'test-message-id',
          acceptOfferDid: 'test-accept-did',
          permanentChannelDid: 'test-permanent-did',
          type: ChannelType.oob,
          vCard: VCard(values: {}),
        );

        fakeSdk.simulateOobConnectionEstablished(fakeChannel);
        await tester.pumpAndSettle();
      });
    });
  });
}
