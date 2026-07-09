import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call_ended/call_ended_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call_ended/call_ended_state.dart';

import '../../../fakes/fake_app_logger.dart';

void main() {
  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [appLoggerProvider.overrideWithValue(FakeAppLogger())],
    );
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
}
