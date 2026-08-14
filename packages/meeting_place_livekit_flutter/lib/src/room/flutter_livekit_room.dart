import 'dart:async';

import 'package:livekit_client/livekit_client.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../extensions/participant_video_extension.dart';
import '../extensions/room_participants_extension.dart';

/// Concrete LiveKit implementation of [LiveKitRoom].
///
/// Owns all livekit_client types so they do not leak into the SDK layer.
/// Converts LiveKit events and participants into domain objects before
/// publishing them through the interface.
class FlutterLiveKitRoom implements LiveKitRoom {
  FlutterLiveKitRoom({MeetingPlaceCoreSDKLogger? logger})
    : _logger = logger ?? DefaultMeetingPlaceCoreSDKLogger(className: _logKey);

  static const _logKey = 'FlutterLiveKitRoom';

  final MeetingPlaceCoreSDKLogger _logger;
  Room? _room;
  bool _isDisposed = false;
  EventsListener<RoomEvent>? _roomListener;
  BaseKeyProvider? _keyProvider;

  Map<String, String> _participantIdToDid = const {};
  final ReconnectGuard _reconnectGuard = ReconnectGuard();

  @override
  String? get ownParticipantId => _room?.localParticipant?.identity;

  @override
  List<AudioVideoCallParticipant> get participants =>
      _room?.toParticipants(_participantIdToDid) ?? const [];

  @override
  Future<void> setSharedKey(String key) async {
    _logger.info('setSharedKey', name: _logKey);
    final keyProvider = await BaseKeyProvider.create(sharedKey: true);
    await keyProvider.setSharedKey(key);
    _keyProvider = keyProvider;
  }

  @override
  Future<void> ratchetKey(String participantId, int keyIndex) async {
    _logger.info('ratchetKey', name: _logKey);
    await _keyProvider?.ratchetKey(participantId, keyIndex);
  }

  @override
  Future<void> connect({
    required String url,
    required String token,
    Map<String, String> participantIdToDid = const {},
    OnCallE2EEStateChanged? onE2EEStateChanged,
    OnParticipantDisconnected? onParticipantDisconnected,
    void Function()? onParticipantsChanged,
  }) async {
    if (_isDisposed) return;
    _participantIdToDid = participantIdToDid;
    _reconnectGuard.reset();
    _logger.info('connect: url=$url', name: _logKey);

    final keyProvider = _keyProvider;
    final e2eeOptions = keyProvider != null
        ? E2EEOptions(keyProvider: keyProvider)
        : null;

    final room = Room(roomOptions: RoomOptions(e2eeOptions: e2eeOptions));

    final needsPeerPresenceTracking =
        onParticipantDisconnected != null || onParticipantsChanged != null;
    final needsListener =
        onE2EEStateChanged != null || needsPeerPresenceTracking;

    if (needsListener) {
      final listener = room.createListener();
      if (onE2EEStateChanged != null) {
        listener.on<TrackE2EEStateEvent>((event) {
          onE2EEStateChanged(
            event.participant.identity,
            _toCallE2EEState(event.state),
          );
        });
      }
      if (needsPeerPresenceTracking) {
        listener
          ..on<ReconnectingEvent>((_) => _reconnectGuard.onReconnecting())
          ..on<RoomReconnectedEvent>((_) {
            _reconnectGuard.onReconnected();
            if (onParticipantsChanged != null &&
                room.remoteParticipants.isEmpty) {
              _logger.info(
                'connect: Reconnected with no remote participants; '
                'surfacing peer departure',
                name: _logKey,
              );
              onParticipantsChanged();
            }
          })
          ..on<RoomDisconnectedEvent>((_) => _reconnectGuard.onDisconnected());
      }
      if (onParticipantDisconnected != null) {
        listener.on<ParticipantDisconnectedEvent>((event) {
          if (_reconnectGuard.shouldIgnoreDisconnect(room.connectionState)) {
            _logger.info(
              'connect: Ignoring participant-disconnect for '
              '${event.participant.identity}; room is not stably connected '
              '(reconnecting=${_reconnectGuard.isReconnecting}, '
              'connectionState=${room.connectionState})',
              name: _logKey,
            );
            return;
          }
          onParticipantDisconnected(event.participant.identity);
        });
      }
      if (onParticipantsChanged != null) {
        listener
          ..on<LocalTrackPublishedEvent>((_) => onParticipantsChanged())
          ..on<LocalTrackUnpublishedEvent>((_) => onParticipantsChanged())
          ..on<TrackMutedEvent>((_) => onParticipantsChanged())
          ..on<TrackUnmutedEvent>((_) => onParticipantsChanged())
          ..on<TrackSubscribedEvent>((_) => onParticipantsChanged())
          ..on<TrackUnsubscribedEvent>((_) => onParticipantsChanged())
          ..on<ParticipantConnectedEvent>((_) => onParticipantsChanged());
      }
      _roomListener = listener;
    }

    _room = room;
    await room.connect(url, token);
    _logger.info(
      'connect: Room connected identity=${room.localParticipant?.identity}',
      name: _logKey,
    );
  }

  @override
  Future<void> disconnect() async {
    _logger.info('disconnect: Releasing room', name: _logKey);
    _isDisposed = true;
    await _roomListener?.dispose();
    _roomListener = null;
    final room = _room;
    _room = null;
    _keyProvider = null;
    try {
      await room?.disconnect();
    } on TimeoutException {
      _logger.info(
        'disconnect: Server disconnect ack timed out; room released anyway',
        name: _logKey,
      );
    }
    _logger.info('disconnect: Done', name: _logKey);
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    _logger.info('setMicrophoneEnabled: enabled=$enabled', name: _logKey);
    await _room?.localParticipant?.setMicrophoneEnabled(enabled);
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    _logger.info('setCameraEnabled: enabled=$enabled', name: _logKey);
    try {
      await _room?.localParticipant?.setCameraEnabled(enabled);
    } catch (e) {
      _logger.warning(
        'setCameraEnabled: Failed to ${enabled ? 'enable' : 'disable'} '
        'camera — device may not have a camera (e.g. simulator): $e',
        name: _logKey,
      );
    }
  }

  @override
  Future<void> switchCamera() async {
    _logger.info('switchCamera', name: _logKey);
    final track =
        _room?.localParticipant?.videoTrackPublications.firstOrNull?.track;
    if (track is! LocalVideoTrack) {
      _logger.warning('switchCamera: no local video track', name: _logKey);
      return;
    }
    final options = track.currentOptions;
    if (options is! CameraCaptureOptions) {
      _logger.warning(
        'switchCamera: track is not a camera track',
        name: _logKey,
      );
      return;
    }
    final next = options.cameraPosition == CameraPosition.front
        ? CameraPosition.back
        : CameraPosition.front;
    await track.setCameraPosition(next);
  }

  @override
  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    _logger.info('setSpeakerphoneEnabled: enabled=$enabled', name: _logKey);
    await AudioManager.instance.setSpeakerOutputPreferred(enabled);
  }

  @override
  Future<void> forceRemoteKeyframe(String participantId) async {
    if (_isDisposed) return;
    final participant = _room?.remoteParticipants[participantId];
    if (participant == null) {
      _logger.warning(
        'forceRemoteKeyframe: no remote participant $participantId',
        name: _logKey,
      );
      return;
    }
    final publications = List.of(
      participant.videoTrackPublications,
      growable: false,
    );
    for (final publication in publications) {
      await _resubscribeForKeyframe(participant.identity, publication);
    }
  }

  /// Drops and re-establishes the subscription for [publication] so the SFU
  /// sends a fresh keyframe. After an E2EE key rotation the decoder cannot
  /// decode inter-frames encrypted with the previous key, so it stays frozen
  /// until the next keyframe. A full unsubscribe/subscribe cycle forces the
  /// SFU to emit one immediately.
  Future<void> _resubscribeForKeyframe(
    String participantIdentity,
    RemoteTrackPublication<RemoteVideoTrack> publication,
  ) async {
    _logger.info(
      'forceRemoteKeyframe: re-subscribing $participantIdentity '
      'track ${publication.sid} to request a new keyframe',
      name: _logKey,
    );
    await publication.unsubscribe();
    await publication.subscribe();
  }

  /// Returns the renderable video track for [participantId], or `null` when
  /// the room is not connected, the participant is not found, or they have no
  /// active video track.
  VideoTrack? renderableVideoTrackFor(String participantId) {
    final room = _room;
    if (room == null) {
      _logger.warning(
        'renderableVideoTrackFor: room not connected',
        name: _logKey,
      );
      return null;
    }
    final Participant? participant;
    if (room.localParticipant?.identity == participantId) {
      participant = room.localParticipant;
    } else {
      participant = room.remoteParticipants[participantId];
    }
    if (participant == null) {
      _logger.warning(
        'renderableVideoTrackFor: participant $participantId not found',
        name: _logKey,
      );
      return null;
    }
    return participant.renderableVideoTrack;
  }

  static CallE2EEState _toCallE2EEState(E2EEState state) => switch (state) {
    E2EEState.kOk => CallE2EEState.ok,
    E2EEState.kKeyRatcheted => CallE2EEState.keyRatcheted,
    E2EEState.kMissingKey => CallE2EEState.missingKey,
    E2EEState.kEncryptionFailed => CallE2EEState.encryptionFailed,
    E2EEState.kDecryptionFailed => CallE2EEState.decryptionFailed,
    E2EEState.kInternalError => CallE2EEState.internalError,
    E2EEState.kNew => CallE2EEState.newState,
  };
}

/// Tracks LiveKit reconnect churn so a mid-reconnect
/// `ParticipantDisconnectedEvent` — which LiveKit fires for every remote
/// participant even though nobody actually left — is told apart from a real
/// peer departure.
class ReconnectGuard {
  bool _isReconnecting = false;

  /// Whether the room is currently mid-reconnect.
  bool get isReconnecting => _isReconnecting;

  /// Resets to the initial (not reconnecting) state, e.g. before a fresh
  /// connect attempt.
  void reset() => _isReconnecting = false;

  /// Call when the room starts reconnecting.
  void onReconnecting() => _isReconnecting = true;

  /// Call once the room has reconnected.
  void onReconnected() => _isReconnecting = false;

  /// Call when the room disconnects for good.
  void onDisconnected() => _isReconnecting = false;

  /// Whether a participant-disconnect event observed right now reflects
  /// reconnect noise rather than a real departure.
  bool shouldIgnoreDisconnect(ConnectionState connectionState) =>
      _isReconnecting || connectionState != ConnectionState.connected;
}
