import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/participants/call_participant.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/participants/call_participants_ring_controller.dart';

const _contactId = 'group:1';

void main() {
  late ProviderContainer container;

  CallParticipantsRingController controller() => container.read(
    callParticipantsRingControllerProvider(_contactId).notifier,
  );

  Map<String, CallRingState> currentState() =>
      container.read(callParticipantsRingControllerProvider(_contactId));

  setUp(() {
    container = ProviderContainer();
    // Keep the autoDispose provider alive for the duration of each test so its
    // timers are not cancelled by disposal mid-test.
    container.listen(
      callParticipantsRingControllerProvider(_contactId),
      (_, _) {},
    );
  });
  tearDown(() => container.dispose());

  test('ring marks the member as ringing', () {
    controller().ring('did:a');
    expect(currentState()['did:a'], CallRingState.ringing);
  });

  test('ring transitions to timedOut after the timeout elapses', () {
    fakeAsync((async) {
      final c = container.read(
        callParticipantsRingControllerProvider(_contactId).notifier,
      );
      c.ring('did:a');
      expect(
        container.read(
          callParticipantsRingControllerProvider(_contactId),
        )['did:a'],
        CallRingState.ringing,
      );

      async.elapse(const Duration(seconds: 30));

      expect(
        container.read(
          callParticipantsRingControllerProvider(_contactId),
        )['did:a'],
        CallRingState.timedOut,
      );
    });
  });

  test('cancelRing returns the member to idle (removed from map)', () {
    fakeAsync((async) {
      final c = container.read(
        callParticipantsRingControllerProvider(_contactId).notifier,
      );
      c.ring('did:a');
      c.cancelRing('did:a');

      expect(
        container
            .read(callParticipantsRingControllerProvider(_contactId))
            .containsKey('did:a'),
        isFalse,
      );

      // Timer was cancelled: no timedOut transition after the timeout window.
      async.elapse(const Duration(seconds: 30));
      expect(
        container
            .read(callParticipantsRingControllerProvider(_contactId))
            .containsKey('did:a'),
        isFalse,
      );
    });
  });

  test('ring keeps distinct members independent', () {
    final c = controller();
    c.ring('did:a');
    c.ring('did:b');
    c.cancelRing('did:a');

    final state = currentState();
    expect(state.containsKey('did:a'), isFalse);
    expect(state['did:b'], CallRingState.ringing);
  });
}
