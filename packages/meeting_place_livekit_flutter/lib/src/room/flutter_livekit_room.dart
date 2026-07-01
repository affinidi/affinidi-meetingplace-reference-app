import 'dart:async';

import 'package:livekit_client/livekit_client.dart';
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
    _logger.info('connect: url=$url', name: _logKey);

    final keyProvider = _keyProvider;
    final e2eeOptions = keyProvider != null
        ? E2EEOptions(keyProvider: keyProvider)
        : null;

    final room = Room(roomOptions: RoomOptions(e2eeOptions: e2eeOptions));

    final needsListener =
        onE2EEStateChanged != null ||
        onParticipantDisconnected != null ||
        onParticipantsChanged != null;

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
      if (onParticipantDisconnected != null) {
        listener.on<ParticipantDisconnectedEvent>((event) {
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
    await _room?.disconnect();
    _room = null;
    _keyProvider = null;
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
        'setCameraEnabled: failed to ${enabled ? 'enable' : 'disable'} camera — '
        'device may not have a camera (e.g. simulator): $e',
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
    await Hardware.instance.setSpeakerphoneOn(enabled);
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
    for (final publication in participant.videoTrackPublications) {
      _logger.info(
        'forceRemoteKeyframe: re-subscribing ${participant.identity} '
        'track ${publication.sid}',
        name: _logKey,
      );
      await publication.disable();
      await publication.enable();
    }
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
