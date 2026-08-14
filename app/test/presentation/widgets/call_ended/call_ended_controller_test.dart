import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call_ended/call_ended_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call_ended/call_ended_state.dart';

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/call_ended_controller_test.log'),
    );
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('initial state', () {
    test('is null', () {
      final container = buildContainer();
      expect(container.read(callEndedControllerProvider), isNull);
    });
  });

  group('show', () {
    test('sets state with provided values', () {
      final container = buildContainer();
      container
          .read(callEndedControllerProvider.notifier)
          .show(
            contactId: 'contact-1',
            peerName: 'Alice',
            callDurationSeconds: 90,
            isAudioOnly: false,
          );

      expect(
        container.read(callEndedControllerProvider),
        isA<CallEndedState>()
            .having((s) => s.contactId, 'contactId', 'contact-1')
            .having((s) => s.peerName, 'peerName', 'Alice')
            .having((s) => s.callDurationSeconds, 'callDurationSeconds', 90)
            .having((s) => s.isAudioOnly, 'isAudioOnly', false),
      );
    });

    test('overwrites previous state on second show', () {
      final container = buildContainer();
      final ctrl = container.read(callEndedControllerProvider.notifier);

      ctrl.show(
        contactId: 'contact-1',
        peerName: 'Alice',
        callDurationSeconds: 30,
        isAudioOnly: true,
      );
      ctrl.show(
        contactId: 'contact-2',
        peerName: 'Bob',
        callDurationSeconds: 60,
        isAudioOnly: false,
      );

      expect(container.read(callEndedControllerProvider)?.peerName, 'Bob');
    });
  });

  group('dismiss', () {
    test('clears state to null', () {
      final container = buildContainer();
      final ctrl = container.read(callEndedControllerProvider.notifier);

      ctrl.show(
        contactId: 'contact-1',
        peerName: 'Alice',
        callDurationSeconds: 42,
        isAudioOnly: false,
      );
      expect(container.read(callEndedControllerProvider), isNotNull);

      ctrl.dismiss();
      expect(container.read(callEndedControllerProvider), isNull);
    });

    test('does not auto-dismiss without explicit dismiss call', () async {
      final container = buildContainer();
      container.listen(callEndedControllerProvider, (_, _) {});
      container
          .read(callEndedControllerProvider.notifier)
          .show(
            contactId: 'contact-1',
            peerName: 'Alice',
            callDurationSeconds: 10,
            isAudioOnly: false,
          );

      await Future<void>.delayed(const Duration(seconds: 5));

      expect(container.read(callEndedControllerProvider), isNotNull);
    });
  });

  group('dismiss on incoming call', () {
    IncomingAudioVideoCallEvent incomingEvent() => IncomingAudioVideoCallEvent(
      callId: 'call-1',
      callerPermanentChannelDid: 'did:example:other',
      otherPartyPermanentChannelDid: 'did:example:other',
      mediaType: CallMediaType.video,
      invitedAt: DateTime.now(),
    );

    test('dismisses a shown screen when a fresh call comes in', () {
      final container = buildContainer();
      container.listen(callEndedControllerProvider, (_, _) {});
      container
          .read(callEndedControllerProvider.notifier)
          .show(
            contactId: 'contact-1',
            peerName: 'Alice',
            callDurationSeconds: 30,
            isAudioOnly: false,
          );
      expect(container.read(callEndedControllerProvider), isNotNull);

      container.read(incomingCallProvider.notifier).set(incomingEvent());

      expect(container.read(callEndedControllerProvider), isNull);
    });

    test('does nothing when there is no screen to dismiss', () {
      final container = buildContainer();
      container.listen(callEndedControllerProvider, (_, _) {});

      container.read(incomingCallProvider.notifier).set(incomingEvent());

      expect(container.read(callEndedControllerProvider), isNull);
    });
  });
}
