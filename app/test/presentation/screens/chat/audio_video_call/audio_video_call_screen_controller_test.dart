import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../fakes/fake_chat_session_service.dart';
import '../../../../mocks/fake_active_call_controller.dart';
import '../../../../mocks/fake_app_logger.dart';
import '../../../../mocks/fake_contacts_service.dart';
import '../../../../mocks/fake_meeting_place_matrix_sdk.dart';
import '../../../../mocks/mock_audio_video_call_session.dart';

const _kContactId = 'test-contact-id';
const _kMsgId = 'test-msg-001';

const _kActiveBannerState = ActiveCallState(
  contactId: _kContactId,
  peerName: 'Peer',
  status: AudioVideoCallStatus.active,
  callDurationSeconds: 1,
  isMicEnabled: true,
  isAudioOnly: false,
);

ProviderContainer _makeContainer({
  FakeActiveCallController? bannerController,
  FakeChatSessionService? chatService,
  MockAudioVideoCallSession? pendingSession,
}) {
  final banner =
      bannerController ??
      FakeActiveCallController(
        fixedCallChatItemId: _kMsgId,
        bannerState: _kActiveBannerState,
        fixedSession: pendingSession,
      );
  final chat = chatService ?? FakeChatSessionService();
  final container = ProviderContainer(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      contactsServiceProvider.overrideWith(FakeContactsService.new),
      activeCallControllerProvider.overrideWith(() => banner),
      chatSessionServiceProvider(_kContactId).overrideWith(() => chat),
      meetingPlaceSdkProvider.overrideWith(
        (ref) async => FakeMeetingPlaceMatrixSDK(),
      ),
      permissionServiceProvider.overrideWith((ref) => _FakePermissionService()),
      incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _pumpAsync() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resolveEndCallStatus — caller + hasHadPeer → ended', () {
    test('calls updateCallChatItem with CallStatus.ended', () async {
      final session = MockAudioVideoCallSession();
      final chatSvc = FakeChatSessionService();
      final container = _makeContainer(
        chatService: chatSvc,
        pendingSession: session,
      );
      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(ownRole: CallRole.caller),
      );
      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.ended,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      expect(chatSvc.updateCalls, isNotEmpty);
      expect(chatSvc.updateCalls.last.status, CallStatus.ended);
    });
  });

  group('resolveEndCallStatus — caller + no peer → declined', () {
    test('calls updateCallChatItem with CallStatus.declined', () async {
      final session = MockAudioVideoCallSession();
      final chatSvc = FakeChatSessionService();
      final banner = FakeActiveCallController(fixedCallChatItemId: _kMsgId);
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          activeCallControllerProvider.overrideWith(() => banner),
          chatSessionServiceProvider(_kContactId).overrideWith(() => chatSvc),
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceMatrixSDK(),
          ),
          permissionServiceProvider.overrideWith(
            (ref) => _FakePermissionService(),
          ),
          incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
        ],
      );
      addTearDown(container.dispose);

      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.ended,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      expect(chatSvc.updateCalls.isEmpty, isTrue);
    });
  });

  group('resolveEndCallStatus — caller + terminal declined', () {
    test('calls updateCallChatItem with CallStatus.declined', () async {
      final session = MockAudioVideoCallSession();
      final chatSvc = FakeChatSessionService();
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          activeCallControllerProvider.overrideWith(
            () => FakeActiveCallController(
              fixedCallChatItemId: _kMsgId,
              bannerState: _kActiveBannerState,
              fixedSession: session,
            ),
          ),
          chatSessionServiceProvider(_kContactId).overrideWith(() => chatSvc),
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceMatrixSDK(),
          ),
          permissionServiceProvider.overrideWith(
            (ref) => _FakePermissionService(),
          ),
          incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
        ],
      );
      addTearDown(container.dispose);

      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(ownRole: CallRole.caller),
      );
      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.declined,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      expect(chatSvc.updateCalls, isNotEmpty);
      expect(chatSvc.updateCalls.last.status, CallStatus.declined);
    });
  });

  group('resolveEndCallStatus — receiver + hasHadPeer → ended', () {
    test('calls updateCallChatItem with CallStatus.ended', () async {
      final session = MockAudioVideoCallSession();
      final chatSvc = FakeChatSessionService(resolveIncomingResult: _kMsgId);
      final banner = FakeActiveCallController(
        bannerState: _kActiveBannerState,
        fixedSession: session,
      );
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          activeCallControllerProvider.overrideWith(() => banner),
          chatSessionServiceProvider(_kContactId).overrideWith(() => chatSvc),
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceMatrixSDK(),
          ),
          permissionServiceProvider.overrideWith(
            (ref) => _FakePermissionService(),
          ),
          incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
        ],
      );
      addTearDown(container.dispose);

      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(ownRole: CallRole.recipient),
      );
      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.ended,
          ownRole: CallRole.recipient,
        ),
      );
      await _pumpAsync();

      expect(chatSvc.updateCalls, isNotEmpty);
      expect(chatSvc.updateCalls.last.status, CallStatus.ended);
    });
  });

  group('resolveEndCallStatus — receiver + no peer → missed', () {
    test('calls updateCallChatItem with CallStatus.missed', () async {
      final session = MockAudioVideoCallSession();
      final chatSvc = FakeChatSessionService(resolveIncomingResult: _kMsgId);
      final banner = FakeActiveCallController(fixedSession: session);
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          activeCallControllerProvider.overrideWith(() => banner),
          chatSessionServiceProvider(_kContactId).overrideWith(() => chatSvc),
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceMatrixSDK(),
          ),
          permissionServiceProvider.overrideWith(
            (ref) => _FakePermissionService(),
          ),
          incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
        ],
      );
      addTearDown(container.dispose);

      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.missed,
          ownRole: CallRole.recipient,
        ),
      );
      await _pumpAsync();

      expect(chatSvc.updateCalls.isEmpty, isTrue);
    });
  });

  group('_updateCallChatItemStatus — skips if callChatItemEnded', () {
    test(
      'second terminal emit does not produce a second updateCallChatItem',
      () async {
        final session = MockAudioVideoCallSession();
        final chatSvc = FakeChatSessionService();
        final container = _makeContainer(
          chatService: chatSvc,
          pendingSession: session,
        );
        container.listen(
          audioVideoCallScreenControllerProvider(_kContactId),
          (_, _) {},
        );

        await session.emitState(
          const AudioVideoCallState(ownRole: CallRole.caller),
        );
        await session.emitState(
          const AudioVideoCallState(status: AudioVideoCallStatus.ended),
        );
        await _pumpAsync();

        final firstCount = chatSvc.updateCalls.length;

        await session.emitState(
          const AudioVideoCallState(status: AudioVideoCallStatus.ended),
        );
        await _pumpAsync();

        expect(chatSvc.updateCalls.length, firstCount);
      },
    );
  });

  group('_endCallChatItem — idempotent', () {
    test(
      'second call after terminal state produces no additional service call',
      () async {
        final session = MockAudioVideoCallSession();
        final chatSvc = FakeChatSessionService();
        final container = _makeContainer(
          chatService: chatSvc,
          pendingSession: session,
        );
        final ctrl = container.read(
          audioVideoCallScreenControllerProvider(_kContactId).notifier,
        );
        container.listen(
          audioVideoCallScreenControllerProvider(_kContactId),
          (_, _) {},
        );

        await session.emitState(
          const AudioVideoCallState(ownRole: CallRole.caller),
        );
        await session.emitState(
          const AudioVideoCallState(status: AudioVideoCallStatus.ended),
        );
        await _pumpAsync();

        final callCount = chatSvc.updateCalls.length;

        await ctrl.cancelCall();
        await _pumpAsync();

        expect(chatSvc.updateCalls.length, callCount);
      },
    );
  });

  group('_ensureCallChatItemId — uses banner id when available', () {
    test('updateCallChatItem uses the id from banner controller', () async {
      final session = MockAudioVideoCallSession();
      final chatSvc = FakeChatSessionService();
      final banner = FakeActiveCallController(
        fixedCallChatItemId: 'banner-msg',
        bannerState: _kActiveBannerState,
        fixedSession: session,
      );
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          activeCallControllerProvider.overrideWith(() => banner),
          chatSessionServiceProvider(_kContactId).overrideWith(() => chatSvc),
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceMatrixSDK(),
          ),
          permissionServiceProvider.overrideWith(
            (ref) => _FakePermissionService(),
          ),
          incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
        ],
      );
      addTearDown(container.dispose);

      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(ownRole: CallRole.caller),
      );
      await session.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.ended),
      );
      await _pumpAsync();

      expect(chatSvc.updateCalls, isNotEmpty);
      expect(chatSvc.updateCalls.first.messageId, 'banner-msg');
    });
  });

  group('_ensureCallChatItemId — falls back to service for receiver', () {
    test('resolveIncomingCallChatItemId is called when no banner id', () async {
      final session = MockAudioVideoCallSession();
      final chatSvc = FakeChatSessionService(resolveIncomingResult: 'svc-msg');
      final banner = FakeActiveCallController(
        bannerState: _kActiveBannerState,
        fixedSession: session,
      );
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          activeCallControllerProvider.overrideWith(() => banner),
          chatSessionServiceProvider(_kContactId).overrideWith(() => chatSvc),
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceMatrixSDK(),
          ),
          permissionServiceProvider.overrideWith(
            (ref) => _FakePermissionService(),
          ),
          incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
        ],
      );
      addTearDown(container.dispose);

      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(ownRole: CallRole.recipient),
      );
      await session.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.ended),
      );
      await _pumpAsync();

      expect(chatSvc.updateCalls, isNotEmpty);
      expect(chatSvc.updateCalls.first.messageId, 'svc-msg');
    });
  });
}

class _FakePermissionService extends PermissionService {
  @override
  Future<PermissionStatus> getCameraPermissionStatus() async =>
      PermissionStatus.granted;

  @override
  Future<PermissionStatus> getMicrophonePermissionStatus() async =>
      PermissionStatus.granted;

  @override
  Future<PermissionStatus> requestCameraPermission() async =>
      PermissionStatus.granted;

  @override
  Future<PermissionStatus> requestMicrophonePermission() async =>
      PermissionStatus.granted;
}

class _FakeIncomingCallState extends IncomingCallNotifier {
  @override
  IncomingCallState build() => const IncomingCallState.idle();
}
