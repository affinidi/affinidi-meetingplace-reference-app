import 'dart:async';

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
  FakeMeetingPlaceMatrixSDK? sdk,
}) {
  final banner =
      bannerController ??
      FakeActiveCallController(
        fixedCallChatItemId: _kMsgId,
        bannerState: _kActiveBannerState,
        fixedSession: pendingSession,
      );
  final chat = chatService ?? FakeChatSessionService();
  final meetingPlaceSDK = sdk ?? FakeMeetingPlaceMatrixSDK();
  final container = ProviderContainer(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      contactsServiceProvider.overrideWith(FakeContactsService.new),
      activeCallControllerProvider.overrideWith(() => banner),
      chatSessionServiceProvider(_kContactId).overrideWith(() => chat),
      meetingPlaceSdkProvider.overrideWith((ref) async => meetingPlaceSDK),
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

  group('_applySessionUpdate — ended status lock', () {
    test(
      'ended status from session is not overwritten by a later non-ended emit',
      () async {
        final session = MockAudioVideoCallSession();
        final container = _makeContainer(pendingSession: session);
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

        await session.emitState(
          const AudioVideoCallState(status: AudioVideoCallStatus.connecting),
        );
        await _pumpAsync();

        expect(
          container
              .read(audioVideoCallScreenControllerProvider(_kContactId))
              .status,
          AudioVideoCallStatus.ended,
        );
      },
    );
  });

  group('cancelCall — caller hangs up before peer answers', () {
    test('sets ended status when caller cancels with no peer', () async {
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
        const AudioVideoCallState(
          status: AudioVideoCallStatus.outgoingRinging,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      await ctrl.cancelCall();
      await _pumpAsync();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(_kContactId))
            .status,
        AudioVideoCallStatus.ended,
      );
    });
  });

  group('onPeerDeclined — peer declines ringing call', () {
    test(
      'flushes the outgoing chat item to declined before switching state',
      () async {
        final session = MockAudioVideoCallSession();
        final banner = FakeActiveCallController(
          fixedCallChatItemId: _kMsgId,
          bannerState: _kActiveBannerState,
          fixedSession: session,
        );
        final container = _makeContainer(
          bannerController: banner,
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
          const AudioVideoCallState(
            status: AudioVideoCallStatus.outgoingRinging,
            ownRole: CallRole.caller,
          ),
        );
        await _pumpAsync();

        await ctrl.cancelCall();
        await _pumpAsync();

        expect(chatSvc.updateCalls, isNotEmpty);
        expect(chatSvc.updateCalls.last.status, CallStatus.declined);
      },
    );
  });

  group('onPeerDeclined — peer declines ringing call', () {
    test(
      'transitions status to declined so the decline screen renders',
      () async {
        final session = MockAudioVideoCallSession();
        final container = _makeContainer(pendingSession: session);
        final ctrl = container.read(
          audioVideoCallScreenControllerProvider(_kContactId).notifier,
        );
        container.listen(
          audioVideoCallScreenControllerProvider(_kContactId),
          (_, _) {},
        );

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.outgoingRinging,
            ownRole: CallRole.caller,
          ),
        );
        await _pumpAsync();

        await ctrl.onPeerDeclined();
        await _pumpAsync();

        expect(
          container
              .read(audioVideoCallScreenControllerProvider(_kContactId))
              .status,
          AudioVideoCallStatus.declined,
        );
      },
    );

    test('declined status survives a later terminal teardown status', () async {
      final session = MockAudioVideoCallSession();
      final container = _makeContainer(pendingSession: session);
      final ctrl = container.read(
        audioVideoCallScreenControllerProvider(_kContactId).notifier,
      );
      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.outgoingRinging,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      await ctrl.onPeerDeclined();
      await _pumpAsync();

      await session.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.ended),
      );
      await _pumpAsync();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(_kContactId))
            .status,
        AudioVideoCallStatus.declined,
      );
    });

    test('declined status survives later non-ended session status', () async {
      final session = MockAudioVideoCallSession();
      final container = _makeContainer(pendingSession: session);
      final ctrl = container.read(
        audioVideoCallScreenControllerProvider(_kContactId).notifier,
      );
      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.outgoingRinging,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      await ctrl.onPeerDeclined();
      await _pumpAsync();

      await session.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.connecting),
      );
      await _pumpAsync();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(_kContactId))
            .status,
        AudioVideoCallStatus.declined,
      );
    });

    test(
      'stale declined lifecycle update does not flash after Call Again',
      () async {
        final session = MockAudioVideoCallSession();
        final container = _makeContainer(pendingSession: session);
        final ctrl = container.read(
          audioVideoCallScreenControllerProvider(_kContactId).notifier,
        );
        container.listen(
          audioVideoCallScreenControllerProvider(_kContactId),
          (_, _) {},
        );

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.outgoingRinging,
            ownRole: CallRole.caller,
          ),
        );
        await _pumpAsync();

        unawaited(ctrl.onPeerDeclined());

        await ctrl.restartCall(isAudioOnly: true);
        await _pumpAsync();

        expect(
          container
              .read(audioVideoCallScreenControllerProvider(_kContactId))
              .status,
          isNot(AudioVideoCallStatus.declined),
        );
      },
    );

    test('does not call SDK leaveCurrentCall to prevent signal loop', () async {
      final session = MockAudioVideoCallSession();
      final sdk = FakeMeetingPlaceMatrixSDK();
      final container = _makeContainer(pendingSession: session, sdk: sdk);
      final ctrl = container.read(
        audioVideoCallScreenControllerProvider(_kContactId).notifier,
      );
      container.listen(
        audioVideoCallScreenControllerProvider(_kContactId),
        (_, _) {},
      );

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.outgoingRinging,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      await ctrl.onPeerDeclined();
      await _pumpAsync();

      expect(sdk.leaveCurrentCallCount, 0);
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
