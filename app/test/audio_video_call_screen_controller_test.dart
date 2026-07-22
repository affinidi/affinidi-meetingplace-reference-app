import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/call_audio_session_service/call_audio_session_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';

import 'fakes/fake_audio_session.dart';
import 'fakes/fake_chat_session_service.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_contacts_service.dart';
import 'fakes/fake_groups.dart';
import 'fakes/fake_permission_service.dart';

class _FakeCallSession extends Fake implements AudioVideoCallSession {
  final _controller = StreamController<AudioVideoCallState>.broadcast();
  final _participantEventsController =
      StreamController<CallParticipantEvent>.broadcast();
  int hangUpCalls = 0;

  void emit(AudioVideoCallState s) => _controller.add(s);

  @override
  Stream<AudioVideoCallState> get state => _controller.stream;

  @override
  Stream<CallParticipantEvent> get participantEvents =>
      _participantEventsController.stream;

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {}

  @override
  Future<void> setCameraEnabled(bool enabled) async {}

  @override
  Future<void> setSpeakerphoneEnabled(bool enabled) async {}

  @override
  Future<void> hangUp() async => hangUpCalls++;

  void dispose() {
    _controller.close();
    _participantEventsController.close();
  }
}

class _FakeMeetingPlaceMatrixSDK extends Fake implements MeetingPlaceMatrixSDK {
  _FakeMeetingPlaceMatrixSDK() : _session = _FakeCallSession();

  final _FakeCallSession _session;
  final _callSignalsController = StreamController<CallSignal>.broadcast();
  sdk.Group? _mockGroup;

  @override
  bool get isCallSupported => true;

  @override
  Stream<IncomingAudioVideoCallEvent> get incomingCalls =>
      const Stream<IncomingAudioVideoCallEvent>.empty();

  @override
  Stream<CallSignal> get callSignals => _callSignalsController.stream;

  @override
  Future<AudioVideoCallSession> startCall({
    required String otherPartyChannelDid,
    required CallMediaType mediaType,
  }) async => _session;

  @override
  Future<void> acceptCall({required String callId}) async {}

  @override
  Future<void> declineCall({required String callId}) async {}

  @override
  Future<void> leaveCurrentCall() async {}

  @override
  Future<sdk.Group?> getGroupByOfferLink(String offerLink) async => _mockGroup;

  void setMockGroup(sdk.Group group) {
    _mockGroup = group;
  }

  void emitState(AudioVideoCallState s) => _session.emit(s);

  void emitCallSignal(CallSignal signal) => _callSignalsController.add(signal);

  @override
  Future<void> dispose() async {
    await _callSignalsController.close();
    _session.dispose();
  }
}

class _GroupAwareContactsService extends FakeContactsService {
  _GroupAwareContactsService({super.contacts});

  final _updates = StreamController<String>.broadcast();

  @override
  Stream<String> get onContactCardUpdated => _updates.stream;

  @override
  void notifyContactCardUpdated(String did) {
    _updates.add(did);
  }

  @override
  void updateContactCard(String did, ContactCard card) {
    final contact = getContactByChannelDid(did);
    if (contact == null) return;
    final amendedContact = contact.copyWith(
      card: card,
      displayName: card.displayName,
    );
    contacts = [
      for (final existingContact in contacts)
        if (existingContact.id == amendedContact.id)
          amendedContact
        else
          existingContact,
    ];
    state = state.copyWith(contacts: contacts);
    _updates.add(did);
  }

  Future<void> disposeService() => _updates.close();
}

Contact _groupMemberContact({
  required String id,
  required String channelDid,
  required String displayName,
  String? profilePic,
}) {
  final card = FakeContacts.individualContact.card.copyWith(
    did: channelDid,
    firstName: displayName,
    displayName: displayName,
    profilePic: profilePic,
  );
  return Contact(
    id: id,
    channelDid: channelDid,
    channelDidSha256: '$channelDid-sha256',
    offerLink: FakeContacts.individualContact.offerLink,
    card: card,
    otherPartyCard: FakeContacts.individualContact.otherPartyCard,
    dateAdded: FakeContacts.individualContact.dateAdded,
    type: FakeContacts.individualContact.type,
    status: FakeContacts.individualContact.status,
    mediatorDid: FakeContacts.individualContact.mediatorDid,
    origin: FakeContacts.individualContact.origin,
    category: FakeContacts.individualContact.category,
    displayName: displayName,
    hasBeenOpened: FakeContacts.individualContact.hasBeenOpened,
  );
}

ProviderContainer _buildContainer({
  _FakeMeetingPlaceMatrixSDK? fakeSDK,
  FakePermissionService? permissionService,
  FakeAudioSession? audioSession,
  bool canUsePlatformAudioSession = false,
}) {
  return ProviderContainer(
    overrides: [
      contactsServiceProvider.overrideWith(FakeContactsService.new),
      chatSessionServiceProvider.overrideWith(FakeChatSessionService.new),
      meetingPlaceSdkProvider.overrideWith(
        (ref) async => fakeSDK ?? _FakeMeetingPlaceMatrixSDK(),
      ),
      permissionServiceProvider.overrideWith(
        (ref) => permissionService ?? FakePermissionService(),
      ),
      canUsePlatformAudioSessionProvider.overrideWith(
        (ref) => canUsePlatformAudioSession,
      ),
      if (audioSession != null)
        audioSessionProvider.overrideWith((ref) async => audioSession),
    ],
  );
}

class _SpyChatSessionService extends FakeChatSessionService {
  _SpyChatSessionService({required this.onSendOutgoingCallMessage});

  final void Function() onSendOutgoingCallMessage;

  @override
  Future<String?> sendOutgoingCallMessage({
    required CallMediaType mediaType,
    required String callId,
  }) async {
    onSendOutgoingCallMessage();
    return 'spy-call-item-id';
  }
}

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/app_debug_test.log'),
    );
  });

  group('initial state', () {
    test('status is idle and toggles default to enabled', () {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final state = container.read(
        audioVideoCallScreenControllerProvider('no-such-id'),
      );
      expect(state.status, AudioVideoCallStatus.idle);
      expect(state.isMicEnabled, isTrue);
      expect(state.isCameraEnabled, isTrue);
      expect(state.isAudioOnly, isFalse);
      expect(state.errorCode, isNull);
    });

    test('peerIsCallingBack defaults to false', () {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final state = container.read(
        audioVideoCallScreenControllerProvider('no-such-id'),
      );
      expect(state.peerIsCallingBack, isFalse);
    });
  });
  group('service state forwarding', () {
    test(
      'status update from session stream is reflected in controller state',
      () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        await controller.joinCall();

        fakeSDK.emitState(
          const AudioVideoCallState(status: AudioVideoCallStatus.connected),
        );
        await Future<void>.microtask(() {});

        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .status,
          AudioVideoCallStatus.connected,
        );
      },
    );
  });

  group('group member contact cards', () {
    test(
      'loads live contact cards for group participants on first fetch',
      () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK()
          ..setMockGroup(FakeGroups.approvedGroup());
        final contactsService = _GroupAwareContactsService(
          contacts: [
            FakeContacts.individualContact,
            FakeContacts.groupContact,
            _groupMemberContact(
              id: 'group-member-contact',
              channelDid: FakeGroups.removableMemberDid,
              displayName: 'Updated Bob',
              profilePic: 'live-avatar',
            ),
          ],
        );
        addTearDown(contactsService.disposeService);

        final container = ProviderContainer(
          overrides: [
            contactsServiceProvider.overrideWith(() => contactsService),
            chatSessionServiceProvider.overrideWith(FakeChatSessionService.new),
            meetingPlaceSdkProvider.overrideWith((ref) async => fakeSDK),
            permissionServiceProvider.overrideWith(
              (ref) => FakePermissionService(),
            ),
            canUsePlatformAudioSessionProvider.overrideWith((ref) => false),
          ],
        );
        addTearDown(container.dispose);
        final subscription = container.listen(
          audioVideoCallScreenControllerProvider(FakeContacts.groupContact.id),
          (_, _) {},
        );
        addTearDown(subscription.close);

        await container.read(meetingPlaceSdkProvider.future);
        await pumpEventQueue();

        final state = container.read(
          audioVideoCallScreenControllerProvider(FakeContacts.groupContact.id),
        );

        expect(
          state.memberContactCards[FakeGroups.removableMemberDid]?.displayName,
          'Updated Bob',
        );
        expect(
          state.memberContactCards[FakeGroups.removableMemberDid]?.profilePic,
          'live-avatar',
        );
      },
    );

    test('refreshes active group member cards after profile updates', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK()
        ..setMockGroup(FakeGroups.approvedGroup());
      final contactsService = _GroupAwareContactsService(
        contacts: [
          FakeContacts.individualContact,
          FakeContacts.groupContact,
          _groupMemberContact(
            id: 'group-member-contact',
            channelDid: FakeGroups.removableMemberDid,
            displayName: 'Initial Bob',
            profilePic: 'initial-avatar',
          ),
        ],
      );
      addTearDown(contactsService.disposeService);

      final container = ProviderContainer(
        overrides: [
          contactsServiceProvider.overrideWith(() => contactsService),
          chatSessionServiceProvider.overrideWith(FakeChatSessionService.new),
          meetingPlaceSdkProvider.overrideWith((ref) async => fakeSDK),
          permissionServiceProvider.overrideWith(
            (ref) => FakePermissionService(),
          ),
          canUsePlatformAudioSessionProvider.overrideWith((ref) => false),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        audioVideoCallScreenControllerProvider(FakeContacts.groupContact.id),
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container.read(meetingPlaceSdkProvider.future);
      await pumpEventQueue();

      contactsService.updateContactCard(
        FakeGroups.removableMemberDid,
        FakeContacts.individualContact.card.copyWith(
          did: FakeGroups.removableMemberDid,
          firstName: 'Renamed Bob',
          displayName: 'Renamed Bob',
          profilePic: 'updated-avatar',
        ),
      );
      await pumpEventQueue();

      final state = container.read(
        audioVideoCallScreenControllerProvider(FakeContacts.groupContact.id),
      );

      expect(
        state.memberContactCards[FakeGroups.removableMemberDid]?.displayName,
        'Renamed Bob',
      );
      expect(
        state.memberContactCards[FakeGroups.removableMemberDid]?.profilePic,
        'updated-avatar',
      );
    });

    test('refreshes active group member cards from group updates '
        'without direct contact', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK()
        ..setMockGroup(FakeGroups.approvedGroup());
      final contactsService = _GroupAwareContactsService(
        contacts: [FakeContacts.individualContact, FakeContacts.groupContact],
      );
      addTearDown(contactsService.disposeService);

      final container = ProviderContainer(
        overrides: [
          contactsServiceProvider.overrideWith(() => contactsService),
          chatSessionServiceProvider.overrideWith(FakeChatSessionService.new),
          meetingPlaceSdkProvider.overrideWith((ref) async => fakeSDK),
          permissionServiceProvider.overrideWith(
            (ref) => FakePermissionService(),
          ),
          canUsePlatformAudioSessionProvider.overrideWith((ref) => false),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        audioVideoCallScreenControllerProvider(FakeContacts.groupContact.id),
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container.read(meetingPlaceSdkProvider.future);
      await pumpEventQueue();

      fakeSDK.setMockGroup(
        sdk.Group(
          id: 'group-id',
          did: 'group-did',
          offerLink: FakeContacts.groupContact.offerLink,
          members: [
            sdk.GroupMember(
              did: 'did:key:member',
              dateAdded: DateTime.now(),
              status: sdk.GroupMemberStatus.approved,
              membershipType: sdk.GroupMembershipType.member,
              contactCard: FakeContacts.sdkContactCard,
              publicKey: 'fake-public-key',
            ),
            sdk.GroupMember(
              did: FakeGroups.removableMemberDid,
              dateAdded: DateTime.now(),
              status: sdk.GroupMemberStatus.approved,
              membershipType: sdk.GroupMembershipType.member,
              contactCard: sdk.ContactCard(
                did: FakeGroups.removableMemberDid,
                type: FakeContacts.sdkContactCard.type,
                contactInfo: {
                  'n': {'given': 'Fresh Bob', 'surname': 'Builder'},
                  'photo': 'group-updated-avatar',
                },
              ),
              publicKey: 'fake-public-key-2',
            ),
            sdk.GroupMember(
              did: FakeGroups.adminMemberDid,
              dateAdded: DateTime.now(),
              status: sdk.GroupMemberStatus.approved,
              membershipType: sdk.GroupMembershipType.admin,
              contactCard: sdk.ContactCard(
                did: FakeGroups.adminMemberDid,
                type: FakeContacts.sdkContactCard.type,
                contactInfo: {
                  'n': {
                    'given': FakeGroups.adminMemberFirstName,
                    'surname': 'Owner',
                  },
                },
              ),
              publicKey: 'fake-public-key-3',
            ),
          ],
          created: DateTime.now(),
          publicKey: 'fake-public-key',
        ),
      );

      contactsService.notifyContactCardUpdated(FakeGroups.removableMemberDid);
      await pumpEventQueue();

      final state = container.read(
        audioVideoCallScreenControllerProvider(FakeContacts.groupContact.id),
      );

      expect(
        state.memberContactCards[FakeGroups.removableMemberDid]?.displayName,
        'Fresh Bob Builder',
      );
      expect(
        state.memberContactCards[FakeGroups.removableMemberDid]?.profilePic,
        'group-updated-avatar',
      );
    });
  });

  group('joinCall', () {
    test('acquires the audio session when joining a call', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final audioSession = FakeAudioSession();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(
        fakeSDK: fakeSDK,
        audioSession: audioSession,
        canUsePlatformAudioSession: true,
      );
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isTrue,
      );
      expect(audioSession.configureCalls, 1);
      expect(audioSession.setActiveCalls, 1);
      expect(audioSession.lastSetActiveValue, isTrue);
      expect(
        audioSession.lastConfiguration?.avAudioSessionMode,
        AVAudioSessionMode.videoChat,
      );
    });

    test('sets status to connecting', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.connecting,
      );
    });

    test('second joinCall while connecting is a no-op', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.joinCall();
      await controller.joinCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.connecting,
      );
    });

    test('individual call disables isSpeakerEnabled by default', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .isSpeakerEnabled,
        isFalse,
      );
    });

    test('group call disables speakerphone by default', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.groupContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .isSpeakerEnabled,
        isFalse,
      );
    });
  });

  group('leaveCall', () {
    test('sets status to ended', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final audioSession = FakeAudioSession();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(
        fakeSDK: fakeSDK,
        audioSession: audioSession,
        canUsePlatformAudioSession: true,
      );
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .leaveCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.ended,
      );
      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isFalse,
      );
      expect(audioSession.setActiveCalls, 2);
      expect(audioSession.lastSetActiveValue, isFalse);
      expect(
        audioSession.lastSetActiveOptions,
        AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      );
    });

    test('releases the audio session when the call disconnects', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final audioSession = FakeAudioSession();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(
        fakeSDK: fakeSDK,
        audioSession: audioSession,
        canUsePlatformAudioSession: true,
      );
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      fakeSDK.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.disconnected),
      );
      await pumpEventQueue();

      expect(audioSession.setActiveCalls, 2);
      expect(audioSession.lastSetActiveValue, isFalse);
      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isFalse,
      );
    });
  });

  group('banner timer wiring', () {
    test('startTimer is called on banner when first remote joins', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      fakeSDK.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [
            AudioVideoCallParticipant(participantId: 'local', isSelf: true),
            AudioVideoCallParticipant(participantId: 'remote-1'),
          ],
        ),
      );
      await Future<void>.microtask(() {});

      expect(
        container.read(activeCallControllerProvider)?.callDurationSeconds,
        isNotNull,
        reason: 'banner must have state after first remote joins',
      );
    });

    test('anchors the banner timer to callStartedAt when provided', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      final startedAt = DateTime.now().subtract(const Duration(seconds: 30));
      fakeSDK.emitState(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          callStartedAt: startedAt,
          participants: const [
            AudioVideoCallParticipant(participantId: 'local', isSelf: true),
            AudioVideoCallParticipant(participantId: 'remote-1'),
          ],
        ),
      );
      await Future<void>.microtask(() {});

      expect(
        container.read(activeCallControllerProvider)?.callDurationSeconds,
        greaterThanOrEqualTo(29),
        reason:
            'on-screen duration must anchor to callStartedAt so both parties '
            'show the same elapsed time, not count up from zero',
      );
    });
  });

  group('startCall', () {
    test('sets isAudioOnly on the state', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .startCall(isAudioOnly: true);

      final state = container.read(
        audioVideoCallScreenControllerProvider(contactId),
      );
      expect(state.isAudioOnly, isTrue);
      expect(state.isCameraEnabled, isFalse);
    });

    test('sets isCameraEnabled true for video call', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .startCall(isAudioOnly: false);

      final state = container.read(
        audioVideoCallScreenControllerProvider(contactId),
      );
      expect(state.isAudioOnly, isFalse);
      expect(state.isCameraEnabled, isTrue);
    });

    test('places an outgoing call (status becomes connecting)', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .startCall(isAudioOnly: false);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.connecting,
      );
    });
  });

  group('restartCall', () {
    test('resets status to idle then starts a fresh outgoing call', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      // Simulate a missed call.
      await controller.joinCall();
      fakeSDK.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.missed),
      );
      await Future<void>.microtask(() {});

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.missed,
      );

      // Restart should produce a fresh connecting state.
      await controller.restartCall(isAudioOnly: true);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.connecting,
      );
    });

    test('clears hasHadPeer when restarting', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.joinCall();

      // Peer joins, latch flips to true.
      fakeSDK.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [
            AudioVideoCallParticipant(participantId: 'local', isSelf: true),
            AudioVideoCallParticipant(participantId: 'remote-1'),
          ],
        ),
      );
      await Future<void>.microtask(() {});

      // Call ends as declined.
      fakeSDK.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.declined),
      );
      await Future<void>.microtask(() {});

      await controller.restartCall(isAudioOnly: false);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .hasHadPeer,
        isFalse,
        reason: 'hasHadPeer must be reset so the ringing phase shows correctly',
      );
    });

    test(
      'sets isAudioOnly and isCameraEnabled=false on audio restart',
      () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        await controller.joinCall();
        fakeSDK.emitState(
          const AudioVideoCallState(status: AudioVideoCallStatus.missed),
        );
        await Future<void>.microtask(() {});

        await controller.restartCall(isAudioOnly: true);

        final state = container.read(
          audioVideoCallScreenControllerProvider(contactId),
        );
        expect(state.isAudioOnly, isTrue);
        expect(state.isCameraEnabled, isFalse);
      },
    );

    test('sets isCameraEnabled=true on video restart', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.joinCall();
      fakeSDK.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.missed),
      );
      await Future<void>.microtask(() {});

      await controller.restartCall(isAudioOnly: false);

      final state = container.read(
        audioVideoCallScreenControllerProvider(contactId),
      );
      expect(state.isAudioOnly, isFalse);
      expect(state.isCameraEnabled, isTrue);
    });

    test(
      'preserves isCameraEnabled=false when restoring a minimized call',
      () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        // Start video call and turn camera off.
        await controller.startCall(isAudioOnly: false);
        await controller
            .toggleCamera(); // turns camera off (isCameraEnabled: false)

        // Verify camera is off before minimize.
        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .isCameraEnabled,
          isFalse,
        );

        // Simulate restore: inject a pending session so startCall detects
        // restore.
        final session = fakeSDK._session;
        container
            .read(audioVideoCallScreenControllerProvider(contactId).notifier)
            .state = container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .copyWith(session: session);

        // startCall is called again on screen restore with isAudioOnly: false.
        await controller.startCall(isAudioOnly: false);

        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .isCameraEnabled,
          isFalse,
          reason: 'camera state must survive minimize/maximize',
        );
      },
    );
  });

  group('dispose — terminal status skips hangUp', () {
    for (final status in [
      AudioVideoCallStatus.missed,
      AudioVideoCallStatus.declined,
      AudioVideoCallStatus.ended,
      AudioVideoCallStatus.disconnected,
      AudioVideoCallStatus.error,
    ]) {
      test('does not call hangUp when disposing in $status state', () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );
        await controller.joinCall();

        fakeSDK.emitState(AudioVideoCallState(status: status));
        await Future<void>.microtask(() {});

        // Dispose the screen controller (simulates Navigator.pop).
        container.invalidate(audioVideoCallScreenControllerProvider(contactId));
        await Future<void>.microtask(() {});

        expect(
          fakeSDK._session.hangUpCalls,
          0,
          reason: 'hangUp must not be called when already in $status',
        );
      });
    }
  });

  group('toggleCamera', () {
    test('does not reconfigure audio session when enabling camera in'
        ' audio-only call', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final audioSession = FakeAudioSession();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(
        fakeSDK: fakeSDK,
        audioSession: audioSession,
        canUsePlatformAudioSession: true,
      );
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.startCall(isAudioOnly: true);
      // After audio-only join: voiceChat mode, 1 configure call.
      expect(
        audioSession.lastConfiguration?.avAudioSessionMode,
        AVAudioSessionMode.voiceChat,
      );
      final configureCallsAfterJoin = audioSession.configureCalls;

      await controller.toggleCamera();

      // LiveKit owns the iOS audio session, so switching to video must not
      // reconfigure it. Reconfiguring mid-call reads as an audio interruption
      // and drops the LiveKit room.
      expect(audioSession.configureCalls, configureCallsAfterJoin);
      expect(
        audioSession.lastConfiguration?.avAudioSessionMode,
        AVAudioSessionMode.voiceChat,
      );
    });

    test(
      'switches from audio to video when enabling camera in audio call',
      () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        await controller.startCall(isAudioOnly: true);
        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .isAudioOnly,
          isTrue,
        );

        await controller.toggleCamera();

        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .isAudioOnly,
          isFalse,
        );
      },
    );

    test(
      'does not reconfigure audio session when enabling camera in video call',
      () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final audioSession = FakeAudioSession();
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(
          fakeSDK: fakeSDK,
          audioSession: audioSession,
          canUsePlatformAudioSession: true,
        );
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        await controller.startCall(isAudioOnly: false);
        final configureCallsAfterJoin = audioSession.configureCalls;

        await controller.toggleCamera();

        expect(audioSession.configureCalls, configureCallsAfterJoin);
      },
    );
  });

  group('incoming call', () {
    test(
      'does not send outgoing call chat item when accepting incoming call',
      () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final contactId = FakeContacts.individualContact.id;
        final channelDid = FakeContacts.individualContact.channelDid!;

        var sendOutgoingCallMessageCount = 0;
        final spy = _SpyChatSessionService(
          onSendOutgoingCallMessage: () => sendOutgoingCallMessageCount++,
        );

        final container = ProviderContainer(
          overrides: [
            contactsServiceProvider.overrideWith(FakeContactsService.new),
            chatSessionServiceProvider.overrideWith(() => spy),
            meetingPlaceSdkProvider.overrideWith((ref) async => fakeSDK),
            permissionServiceProvider.overrideWith(
              (ref) => FakePermissionService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Set the incoming event before the controller builds so its build()
        // sees isAcceptedIncomingForThisScreen = true.
        container
            .read(incomingCallProvider.notifier)
            .set(
              IncomingAudioVideoCallEvent(
                callId: 'call-1',
                callerPermanentChannelDid: 'sim1@example.com',
                otherPartyPermanentChannelDid: channelDid,
                mediaType: CallMediaType.video,
                invitedAt: DateTime.now(),
              ),
            );

        await container.read(meetingPlaceSdkProvider.future);
        await container
            .read(audioVideoCallScreenControllerProvider(contactId).notifier)
            .joinCall();

        fakeSDK.emitState(AudioVideoCallState.initial);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(sendOutgoingCallMessageCount, 0);
      },
    );
  });

  group('peer restart state', () {
    test('peerIsCallingBack state field exists and defaults to false', () {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final state = container.read(
        audioVideoCallScreenControllerProvider('no-such-id'),
      );
      expect(state.peerIsCallingBack, isFalse);
    });

    test('peerIsCallingBack can be set to true via state.copyWith', () {
      final container = _buildContainer();
      addTearDown(container.dispose);
      final contactId = FakeContacts.individualContact.id;

      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      controller.state = controller.state.copyWith(peerIsCallingBack: true);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .peerIsCallingBack,
        isTrue,
      );
    });

    test('peerIsCallingBack flag can be cleared via state.copyWith', () {
      final container = _buildContainer();
      addTearDown(container.dispose);
      final contactId = FakeContacts.individualContact.id;

      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      controller.state = controller.state.copyWith(peerIsCallingBack: true);
      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .peerIsCallingBack,
        isTrue,
      );

      controller.state = controller.state.copyWith(peerIsCallingBack: false);
      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .peerIsCallingBack,
        isFalse,
      );
    });
  });

  group('call signal — declined by peer', () {
    test(
      'caller receives CallDeclineSignal listener when SDK is provided',
      () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);
        addTearDown(fakeSDK.dispose);

        await container.read(meetingPlaceSdkProvider.future);

        expect(fakeSDK.callSignals, isNotNull);
      },
    );

    test('call signal listener exists on controller initialization', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);
      addTearDown(fakeSDK.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      expect(controller, isNotNull);
    });
  });
}
