import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/participants/call_participant.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/participants/call_participants_ring_controller.dart';

import 'fakes/fake_contacts.dart';
import 'mocks/fake_app_logger.dart';

// FakeContacts.groupContact has id 'group-contact-id' and channelDid
// 'did:key:group-channel'.
const _contactId = 'group-contact-id';

typedef _RingCall = ({String group, String member, CallMediaType media});

class _CapturingSdk extends Fake implements MeetingPlaceMatrixSDK {
  final List<_RingCall> calls = [];

  @override
  Future<void> ringGroupMember({
    required String groupChannelDid,
    required String memberDid,
    required CallMediaType mediaType,
  }) async {
    calls.add((group: groupChannelDid, member: memberDid, media: mediaType));
  }
}

class _FakeContactsService extends ContactsService {
  @override
  ContactsServiceState build() =>
      ContactsServiceState(contacts: [FakeContacts.groupContact]);
}

class _FixedCallController extends AudioVideoCallScreenController {
  _FixedCallController(this._state);

  final AudioVideoCallScreenState _state;

  @override
  AudioVideoCallScreenState build(String contactId) => _state;

  @override
  Future<void> startCall({bool isAudioOnly = false}) async {}
}

void main() {
  late ProviderContainer container;
  late _CapturingSdk sdk;

  CallParticipantsRingController controller() => container.read(
    callParticipantsRingControllerProvider(_contactId).notifier,
  );

  Map<String, CallRingState> currentState() =>
      container.read(callParticipantsRingControllerProvider(_contactId));

  setUp(() {
    sdk = _CapturingSdk();
    container = ProviderContainer(
      overrides: [
        appLoggerProvider.overrideWithValue(FakeAppLogger()),
        meetingPlaceSdkProvider.overrideWith((ref) async => sdk),
        contactsServiceProvider.overrideWith(_FakeContactsService.new),
        audioVideoCallScreenControllerProvider(
          _contactId,
        ).overrideWith(() => _FixedCallController(AudioVideoCallScreenState())),
      ],
    );
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

  test('ring sends a targeted ringGroupMember through the SDK', () async {
    controller().ring('did:a');
    await Future<void>.delayed(Duration.zero);

    expect(sdk.calls, hasLength(1));
    expect(sdk.calls.single.member, 'did:a');
    expect(sdk.calls.single.group, 'did:key:group-channel');
    expect(sdk.calls.single.media, CallMediaType.video);
  });

  test('ring transitions to timedOut after the timeout elapses', () {
    fakeAsync((async) {
      controller().ring('did:a');
      expect(currentState()['did:a'], CallRingState.ringing);

      async.elapse(container.read(environmentProvider).callRingTimeout);

      expect(currentState()['did:a'], CallRingState.timedOut);
    });
  });

  test('cancelRing returns the member to idle (removed from map)', () {
    fakeAsync((async) {
      controller().ring('did:a');
      controller().cancelRing('did:a');

      expect(currentState().containsKey('did:a'), isFalse);

      // Timer was cancelled: no timedOut transition after the timeout window.
      async.elapse(container.read(environmentProvider).callRingTimeout);
      expect(currentState().containsKey('did:a'), isFalse);
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
