import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/application/services/control_plane_service/control_plane_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/exceptions/app_exception.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';
import 'package:mpx_flutter_reference_app/infrastructure/firebase_messaging/push_notifications_handler.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';

import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_meeting_place_matrix_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('ControlPlaneService', () {
    late ProviderContainer container;
    late FakeMeetingPlaceMatrixSDK fakeCoreSdk;
    late ControlPlaneService controlPlaneService;

    setUp(() async {
      fakeCoreSdk = FakeMeetingPlaceMatrixSDK(
        channels: {
          FakeContacts.individualContact.channelDid!: _channelWithStatus(
            ChannelStatus.inaugurated,
          ),
        },
      );

      container = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
          pushNotificationsHandlerProvider.overrideWith(
            _FakePushNotificationsHandler.new,
          ),
          networkConnectivityServiceProvider.overrideWith(
            _FakeNetworkConnectivityService.new,
          ),
        ],
      );

      container.listen(
        controlPlaneServiceProvider,
        (previous, next) {},
        fireImmediately: true,
      );
      controlPlaneService = container.read(
        controlPlaneServiceProvider.notifier,
      );

      await container.read(meetingPlaceSdkProvider.future);
      await fakeCoreSdk.waitForControlPlaneEventsListener();
    });

    tearDown(() => container.dispose());

    test('throws on channel activity before inauguration', () async {
      final capturedError = Completer<Object>();
      var emittedActivityCount = 0;

      await runZonedGuarded(
        () async {
          final scopedFakeSdk = FakeMeetingPlaceMatrixSDK(
            channels: {
              FakeContacts.individualContact.channelDid!: _channelWithStatus(
                ChannelStatus.inaugurated,
              ),
            },
          );
          final scopedContainer = ProviderContainer(
            overrides: [
              meetingPlaceSdkProvider.overrideWith(
                (ref) async => scopedFakeSdk,
              ),
              pushNotificationsHandlerProvider.overrideWith(
                _FakePushNotificationsHandler.new,
              ),
              networkConnectivityServiceProvider.overrideWith(
                _FakeNetworkConnectivityService.new,
              ),
            ],
          );
          addTearDown(scopedContainer.dispose);

          scopedContainer.listen(
            controlPlaneServiceProvider,
            (previous, next) {},
            fireImmediately: true,
          );
          final scopedControlPlaneService = scopedContainer.read(
            controlPlaneServiceProvider.notifier,
          );

          await scopedContainer.read(meetingPlaceSdkProvider.future);
          await scopedFakeSdk.waitForControlPlaneEventsListener();

          final subscription = scopedControlPlaneService.onChannelActivity
              .listen((_) {
                emittedActivityCount += 1;
              });
          addTearDown(subscription.cancel);

          scopedFakeSdk.simulateChannelActivity(
            _channelWithStatus(ChannelStatus.approved),
          );
          await capturedError.future;
        },
        (error, stackTrace) {
          if (!capturedError.isCompleted) {
            capturedError.complete(error);
          }
        },
      );

      final error = await capturedError.future;

      expect(error, isA<AppException>());
      expect(
        (error as AppException).message,
        'Received channel activity for a non-inaugurated channel',
      );
      expect(emittedActivityCount, 0);
    });

    test('emits channel activity after inauguration', () async {
      final nextActivity = controlPlaneService.onChannelActivity.first;

      fakeCoreSdk.simulateChannelActivity(
        _channelWithStatus(ChannelStatus.inaugurated),
      );

      final channel = await nextActivity;

      expect(channel.status, ChannelStatus.inaugurated);
    });
  });
}

Channel _channelWithStatus(ChannelStatus status) {
  final contact = FakeContacts.individualContact;
  return Channel(
    permanentChannelDid: contact.channelDid!,
    otherPartyPermanentChannelDid: 'did:key:other-party',
    offerLink: contact.offerLink,
    contactCard: contact.card.toSdkContactCard(),
    otherPartyContactCard: contact.otherPartyCard?.toSdkContactCard(),
    otherPartyNotificationToken: 'fake-notification-token',
    seqNo: 0,
    type: ChannelType.individual,
    publishOfferDid: 'did:key:individual-offer',
    mediatorDid: contact.mediatorDid,
    status: status,
    isConnectionInitiator: true,
  );
}

class _FakePushNotificationsHandler extends PushNotificationsHandler {
  @override
  Future<void> build() async {}

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> getToken() async {}
}

class _FakeNetworkConnectivityService extends NetworkConnectivityService {
  @override
  NetworkConnectivityServiceState build() {
    return const NetworkConnectivityServiceState(isConnected: true);
  }
}
