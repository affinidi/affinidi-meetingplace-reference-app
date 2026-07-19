import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/navigation/navigator.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_ui_rules.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/incoming_call/incoming_call_banner_controller.dart';

import '../../../../mocks/fake_app_logger.dart';
import '../../../../mocks/fake_incoming_call_service.dart';
import '../../../../mocks/mock_navigator.dart';

const _kCallId = 'call-123';
const _kOtherPartyPermanentChannelDid = 'did:key:other-party';
const _kContactId = 'contact-1';

ProviderContainer _makeContainer({
  FakeIncomingCallService? service,
  RecordingNavigator? navigator,
}) {
  final fakeService = service ?? FakeIncomingCallService();
  final fakeNavigator = navigator ?? RecordingNavigator();
  final container = ProviderContainer(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      incomingCallServiceProvider.overrideWith(() => fakeService),
      navigatorProvider.overrideWithValue(fakeNavigator),
    ],
  );
  addTearDown(container.dispose);
  container.listen(incomingCallBannerControllerProvider, (_, _) {});
  return container;
}

void main() {
  group('initial state', () {
    test('is false', () {
      final container = _makeContainer();
      expect(container.read(incomingCallBannerControllerProvider), false);
    });
  });

  group('when accept is called', () {
    test('it sets state to true', () {
      final container = _makeContainer();
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .accept(
            callId: _kCallId,
            otherPartyChannelDid: _kOtherPartyPermanentChannelDid,
            mediaType: CallMediaType.video,
            contactId: _kContactId,
          );
      expect(container.read(incomingCallBannerControllerProvider), true);
    });

    test('it forwards accept to IncomingCallService', () {
      final service = FakeIncomingCallService();
      final container = _makeContainer(service: service);
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .accept(
            callId: _kCallId,
            otherPartyChannelDid: _kOtherPartyPermanentChannelDid,
            mediaType: CallMediaType.video,
            contactId: _kContactId,
          );
      expect(service.acceptedCallIds, [_kCallId]);
    });
  });

  group('when dismiss is called', () {
    test('it sets state to true', () {
      final container = _makeContainer();
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .dismiss(callId: _kCallId);
      expect(container.read(incomingCallBannerControllerProvider), true);
    });

    test('it forwards decline to IncomingCallService', () {
      final service = FakeIncomingCallService();
      final container = _makeContainer(service: service);
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .dismiss(callId: _kCallId);
      expect(service.declinedCallIds, [_kCallId]);
    });
  });

  group('when reset is called', () {
    test('it sets state back to false after dismiss', () {
      final container = _makeContainer();
      final ctrl = container.read(
        incomingCallBannerControllerProvider.notifier,
      );
      ctrl.dismiss(callId: _kCallId);
      expect(container.read(incomingCallBannerControllerProvider), true);
      ctrl.reset();
      expect(container.read(incomingCallBannerControllerProvider), false);
    });
  });

  group('when a new incoming call event occurs', () {
    test('it resets dismissed state so the banner shows again', () {
      final container = _makeContainer();
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .dismiss(callId: _kCallId);
      expect(container.read(incomingCallBannerControllerProvider), true);

      container
          .read(incomingCallProvider.notifier)
          .set(
            IncomingAudioVideoCallEvent(
              callId: 'call-1',
              callerPermanentChannelDid: 'did:example:other',
              otherPartyPermanentChannelDid: 'did:example:other',
              invitedAt: DateTime.utc(2026),
              mediaType: CallMediaType.video,
              invitedAt: DateTime.now(),
            ),
          );

      expect(container.read(incomingCallBannerControllerProvider), false);
    });

    test(
      'it dismisses the end-call banner so the retry can take the top slot',
      () {
        final container = _makeContainer();

        container
            .read(endCallBannerControllerProvider.notifier)
            .show(
              contactId: 'contact-123',
              peerName: 'Alice',
              endState: CallEndState.declinedCall,
              isAudioOnly: false,
            );
        expect(container.read(endCallBannerControllerProvider), isNotNull);

        container
            .read(incomingCallProvider.notifier)
            .set(
              IncomingAudioVideoCallEvent(
                callId: 'call-1',
                callerPermanentChannelDid: 'did:example:other',
                otherPartyPermanentChannelDid: 'did:example:other',
                invitedAt: DateTime.utc(2026),
                mediaType: CallMediaType.video,
                invitedAt: DateTime.now(),
              ),
            );

        expect(container.read(endCallBannerControllerProvider), isNull);
        expect(container.read(incomingCallBannerControllerProvider), false);
      },
    );

    test(
      'it resets dismissed state for an audio call so the banner shows again',
      () {
        final container = _makeContainer();
        container
            .read(incomingCallBannerControllerProvider.notifier)
            .dismiss(callId: _kCallId);
        expect(container.read(incomingCallBannerControllerProvider), true);

        container
            .read(incomingCallProvider.notifier)
            .set(
              IncomingAudioVideoCallEvent(
                callId: 'call-1',
                callerPermanentChannelDid: 'did:example:other',
                otherPartyPermanentChannelDid: 'did:example:other',
                invitedAt: DateTime.utc(2026),
                mediaType: CallMediaType.audio,
                invitedAt: DateTime.now(),
              ),
            );

        expect(container.read(incomingCallBannerControllerProvider), false);
      },
    );
  });

  group('accept', () {
    test('forwards accept to IncomingCallService', () {
      final service = FakeIncomingCallService();
      final container = _makeContainer(service: service);
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .accept(
            callId: _kCallId,
            otherPartyChannelDid: _kOtherPartyPermanentChannelDid,
            mediaType: CallMediaType.video,
            contactId: _kContactId,
          );

      expect(service.acceptedCallIds, [_kCallId]);
    });

    test('navigates to the call screen with the resolved contact id', () {
      final navigator = RecordingNavigator();
      final container = _makeContainer(navigator: navigator);
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .accept(
            callId: _kCallId,
            otherPartyChannelDid: _kOtherPartyPermanentChannelDid,
            mediaType: CallMediaType.video,
            contactId: _kContactId,
          );

      expect(navigator.goCalls.length, 1);
      expect(navigator.goCalls.single, contains(_kContactId));
    });

    test('navigates using channel did when no contact id', () {
      final navigator = RecordingNavigator();
      final container = _makeContainer(navigator: navigator);
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .accept(
            callId: _kCallId,
            otherPartyChannelDid: _kOtherPartyPermanentChannelDid,
            mediaType: CallMediaType.audio,
            contactId: null,
          );

      expect(navigator.goCalls.length, 1);
      expect(
        navigator.goCalls.single,
        contains(_kOtherPartyPermanentChannelDid.replaceAll(':', '%3A')),
      );
    });

    test('sets state to true', () {
      final container = _makeContainer();
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .accept(
            callId: _kCallId,
            otherPartyChannelDid: _kOtherPartyPermanentChannelDid,
            mediaType: CallMediaType.video,
            contactId: _kContactId,
          );

      expect(container.read(incomingCallBannerControllerProvider), true);
    });
  });
}
