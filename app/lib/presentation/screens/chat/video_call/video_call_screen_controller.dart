import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:matrix/matrix.dart' as matrix;
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/contacts_service/contacts_service.dart';
import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../../infrastructure/services/livekit_service/livekit_service.dart';
import '../../../../infrastructure/services/livekit_service/livekit_token_service.dart';
import '../../../../infrastructure/services/livekit_service/matrix_livekit_key_provider.dart';
import 'video_call_screen_state.dart';

part 'video_call_screen_controller.g.dart';

@riverpod
class VideoCallScreenController extends _$VideoCallScreenController {
  static const _logKey = 'VideoCallScreen';

  late final _logger = ref.read(appLoggerProvider);
  late final _livekitService = LiveKitService(
    serverUrl: ref.read(environmentProvider).livekitUrl,
    apiKey: ref.read(environmentProvider).livekitApiKey,
    apiSecret: ref.read(environmentProvider).livekitApiSecret,
    logger: ref.read(appLoggerProvider),
  );

  StreamSubscription<matrix.MatrixRTCCallEvent>? _matrixRtcSubscription;

  /// The local Matrix userId (e.g. `@alice:server.com`) extracted from
  /// `matrixParticipantId` (`@alice:server.com:DEVICEID`). Used to filter
  /// the local user out of join/leave notifications.
  String? _localMatrixUserId;

  @override
  VideoCallScreenState build(String roomId, String contactId) {
    Future(() async {
      if (state.status == VideoCallStatus.idle) {
        await joinCall();
      }
    });

    ref.onDispose(_cleanup);
    return const VideoCallScreenState();
  }

  Future<void> joinCall() async {
    if (state.status == VideoCallStatus.connected ||
        state.status == VideoCallStatus.connecting) {
      return;
    }
    state = state.copyWith(status: VideoCallStatus.connecting);

    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);

      await _signalMatrixRTC(sdk);
      _subscribeToMatrixRTCEvents(sdk);
      _cacheLocalMatrixUserId(sdk);

      final myDisplayName = await _resolveMemberNames(sdk);

      final (:keyProvider, :token) = await _prepareE2EECredentials();

      await _connectToLiveKit(
        displayName: myDisplayName,
        token: token,
        keyProvider: keyProvider,
      );

      await _enableLocalMedia();

      _logger.info('Joined video call for room $roomId', name: _logKey);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to join video call',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      state = state.copyWith(status: VideoCallStatus.error, error: error);
    }
  }

  Future<void> leaveCall() async {
    final sdk = await ref.read(meetingPlaceSdkProvider.future);
    await sdk.leaveVideoCall(roomId: roomId, callId: roomId);
    await _cleanup();
    state = const VideoCallScreenState();
  }

  Future<void> toggleMic() async {
    final next = !state.isMicEnabled;
    await _livekitService.setMicrophoneEnabled(next);
    state = state.copyWith(isMicEnabled: next);
  }

  Future<void> toggleCamera() async {
    final next = !state.isCameraEnabled;
    await _livekitService.setCameraEnabled(next);
    state = state.copyWith(isCameraEnabled: next);
  }

  /// Publishes `m.call.member` state event via MatrixRTC.
  Future<void> _signalMatrixRTC(MeetingPlaceCoreSDK sdk) async {
    await sdk.startVideoCall(
      roomId: roomId,
      livekitServiceUrl: _livekitService.serverUrl,
      livekitAlias: roomId,
      callId: roomId,
    );
  }

  /// Subscribes to MatrixRTC membership events for join/leave toasts.
  void _subscribeToMatrixRTCEvents(MeetingPlaceCoreSDK sdk) {
    final matrixRtcStream = sdk.watchVideoCall(roomId: roomId, callId: roomId);
    if (matrixRtcStream != null) {
      _matrixRtcSubscription = matrixRtcStream.listen(_onMatrixRTCEvent);
    }
  }

  /// Caches the local Matrix userId (strips trailing `:deviceId`) so we can
  /// filter the local user out of join/leave event notifications.
  void _cacheLocalMatrixUserId(MeetingPlaceCoreSDK sdk) {
    final rawId = sdk.matrixParticipantId;
    if (rawId != null) {
      final lastColon = rawId.lastIndexOf(':');
      if (lastColon > 0) _localMatrixUserId = rawId.substring(0, lastColon);
    }
  }

  /// Resolves member names from the Group entity and populates
  /// `state.memberNames`. Returns the local user's display name (if found)
  /// so it can be broadcast via the LiveKit JWT `name` claim.
  Future<String?> _resolveMemberNames(MeetingPlaceCoreSDK sdk) async {
    String? myDisplayName;
    final memberNameMap = <String, String>{};

    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    if (contact == null) return null;

    final group = await sdk.getGroupByOfferLink(contact.offerLink);
    if (group == null) return null;

    final myLocalpart = _extractLocalpart(_localMatrixUserId);

    for (final member in group.members) {
      final memberHash = md5.convert(utf8.encode(member.did)).toString();
      final name = member.contactCard.firstName;
      if (name.isNotEmpty) {
        memberNameMap[memberHash] = name;
      }
      if (memberHash == myLocalpart && name.isNotEmpty) {
        myDisplayName = name;
      }
    }

    state = state.copyWith(memberNames: memberNameMap);
    return myDisplayName;
  }

  /// Prepares the E2EE key provider and LiveKit token.
  ///
  /// When a token server URL is configured, the JWT and E2EE key are fetched
  /// from the server. Otherwise falls back to dev-only in-app generation.
  ///
  /// Shared-key mode: both participants derive the same key from
  /// HMAC-SHA256(apiSecret, roomId). No network key exchange needed.
  Future<({MatrixLiveKitKeyProvider keyProvider, String? token})>
  _prepareE2EECredentials() async {
    final env = ref.read(environmentProvider);
    final tokenServerUrl = env.livekitTokenServerUrl;

    if (tokenServerUrl != null) {
      final tokenService = LiveKitTokenService(serverUrl: tokenServerUrl);
      final tokenResponse = await tokenService.fetchToken(
        roomId: roomId,
        participantId: contactId,
      );
      final keyProvider = await MatrixLiveKitKeyProvider.fromKey(
        e2eeKey: tokenResponse.e2eeKey,
      );
      return (keyProvider: keyProvider, token: tokenResponse.token);
    }

    final keyProvider = await MatrixLiveKitKeyProvider.create(
      roomId: roomId,
      apiSecret: env.livekitApiSecret,
    );
    return (keyProvider: keyProvider, token: null);
  }

  /// Connects to the LiveKit SFU with the given credentials.
  Future<void> _connectToLiveKit({
    String? displayName,
    String? token,
    required MatrixLiveKitKeyProvider keyProvider,
  }) async {
    await _livekitService.connect(
      roomId: roomId,
      participantId: contactId,
      displayName: displayName,
      token: token,
      e2eeKeyProvider: keyProvider.liveKitKeyProvider,
      onParticipantsChanged: () => state = state.copyWith(
        participants: _livekitService.getParticipants(),
      ),
      onDisconnected: () {
        if (state.status == VideoCallStatus.connected) {
          state = const VideoCallScreenState();
        }
      },
    );
  }

  /// Enables microphone and camera. Camera failures (e.g. on simulators)
  /// are caught and logged rather than aborting the call.
  Future<void> _enableLocalMedia() async {
    await _livekitService.setMicrophoneEnabled(true);
    var cameraEnabled = false;
    try {
      await _livekitService.setCameraEnabled(true);
      cameraEnabled = true;
    } catch (e, stackTrace) {
      _logger.error(
        'Camera unavailable: $e',
        name: _logKey,
        error: e,
        stackTrace: stackTrace,
      );
    }

    state = state.copyWith(
      status: VideoCallStatus.connected,
      participants: _livekitService.getParticipants(),
      isMicEnabled: true,
      isCameraEnabled: cameraEnabled,
    );
  }

  /// Returns a display name for a participant. Local participant returns
  /// [youLabel], remote participants use their broadcast name, memberNames
  /// map, or identity localpart as fallback.
  String displayNameFor(Participant participant, String youLabel) {
    if (participant is LocalParticipant) return youLabel;
    final broadcastName = participant.name;
    if (broadcastName.isNotEmpty && broadcastName != participant.identity) {
      return broadcastName;
    }
    final localpart = _parseIdentityLocalpart(participant.identity);
    return state.memberNames[localpart] ?? localpart;
  }

  /// Extracts the localpart from a participant identity string.
  /// Handles both `@alice:server` and `alice:server` formats.
  String _parseIdentityLocalpart(String identity) {
    var body = identity;
    if (body.startsWith('@')) body = body.substring(1);
    final colon = body.indexOf(':');
    if (colon > 0) return body.substring(0, colon);
    return identity;
  }

  /// Extracts the localpart from a Matrix userId (`@alice:server` → `alice`).
  /// Returns `null` for invalid input.
  String? _extractLocalpart(String? userId) {
    if (userId == null || !userId.startsWith('@')) return null;
    final body = userId.substring(1);
    final colon = body.indexOf(':');
    if (colon > 0) return body.substring(0, colon);
    return null;
  }

  void _onMatrixRTCEvent(matrix.MatrixRTCCallEvent event) {
    _logger.info('MatrixRTC event: $event', name: _logKey);

    if (event is! matrix.ParticipantsChangeEvent) return;

    final String names;
    final ParticipantEventType eventType;
    switch (event) {
      case matrix.ParticipantsJoinEvent(:final participants):
        final others = _filterLocalParticipants(participants);
        if (others.isEmpty) return;
        names = _resolveParticipantNames(others);
        eventType = ParticipantEventType.joined;
      case matrix.ParticipantsLeftEvent(:final participants):
        final others = _filterLocalParticipants(participants);
        if (others.isEmpty) return;
        names = _resolveParticipantNames(others);
        eventType = ParticipantEventType.left;
    }

    state = state.copyWith(
      participantEvent: VideoCallParticipantEvent(
        names: names,
        type: eventType,
      ),
    );
  }

  /// Removes the local participant from `participants` so we never show
  /// "you joined/left" notifications.
  List<matrix.CallParticipant> _filterLocalParticipants(
    List<matrix.CallParticipant> participants,
  ) {
    final localId = _localMatrixUserId;
    if (localId == null) return participants;
    return participants.where((p) => p.userId != localId).toList();
  }

  /// Returns a human-readable name for `participants` by looking up
  /// their Matrix localpart (md5 of DID) in the Group member names map.
  String _resolveParticipantNames(List<matrix.CallParticipant> participants) {
    return participants
        .map((p) {
          final localpart = _extractLocalpart(p.userId) ?? p.userId;
          return state.memberNames[localpart] ?? localpart;
        })
        .join(', ');
  }

  Future<void> _cleanup() async {
    await _matrixRtcSubscription?.cancel();
    _matrixRtcSubscription = null;
    await _livekitService.disconnect();
  }
}
