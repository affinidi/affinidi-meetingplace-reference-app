import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/incoming_call_state_provider.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/incoming_call/incoming_call_banner_controller.dart';

import '../../../../mocks/fake_app_logger.dart';
import '../../../../mocks/fake_incoming_call_service.dart';

const _kCallId = 'call-123';

ProviderContainer _makeContainer({FakeIncomingCallService? service}) {
  final fakeService = service ?? FakeIncomingCallService();
  final container = ProviderContainer(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      incomingCallServiceProvider.overrideWith(() => fakeService),
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

  group('accept', () {
    test('sets state to true', () {
      final container = _makeContainer();
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .accept(callId: _kCallId);
      expect(container.read(incomingCallBannerControllerProvider), true);
    });

    test('forwards accept to IncomingCallService', () {
      final service = FakeIncomingCallService();
      final container = _makeContainer(service: service);
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .accept(callId: _kCallId);
      expect(service.acceptedCallIds, [_kCallId]);
    });
  });

  group('dismiss', () {
    test('sets state to true', () {
      final container = _makeContainer();
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .dismiss(callId: _kCallId);
      expect(container.read(incomingCallBannerControllerProvider), true);
    });

    test('forwards decline to IncomingCallService', () {
      final service = FakeIncomingCallService();
      final container = _makeContainer(service: service);
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .dismiss(callId: _kCallId);
      expect(service.declinedCallIds, [_kCallId]);
    });
  });

  group('reset', () {
    test('sets state back to false after dismiss', () {
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

  group('new incoming call event', () {
    test('resets dismissed state so the banner shows again', () {
      final container = _makeContainer();
      container
          .read(incomingCallBannerControllerProvider.notifier)
          .dismiss(callId: _kCallId);
      expect(container.read(incomingCallBannerControllerProvider), true);

      container
          .read(incomingCallStateProvider.notifier)
          .set(
            const IncomingAudioVideoCallEvent(
              callId: 'call-456',
              otherPartyChannelDid: 'did:example:other',
              mediaType: CallMediaType.video,
            ),
          );

      expect(container.read(incomingCallBannerControllerProvider), false);
    });
  });
}
