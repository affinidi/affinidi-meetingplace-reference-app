import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../loggers/app_logger/app_logger.dart';

/// Encapsulates all LiveKit room interactions: connect, disconnect,
/// media toggles, participant list, and room event streaming.
///
/// Token generation here is dev-only. In production, replace
/// `_generateDevToken` with a call to your token server endpoint.
class LiveKitService {
  LiveKitService({
    required String serverUrl,
    required String apiKey,
    required String apiSecret,
    required AppLogger logger,
  }) : _serverUrl = serverUrl,
       _apiKey = apiKey,
       _apiSecret = apiSecret,
       _logger = logger;

  static const _logKey = 'LVKTSVC';

  final String _serverUrl;
  final String _apiKey;
  final String _apiSecret;
  final AppLogger _logger;

  Room? _room;
  EventsListener<RoomEvent>? _listener;

  Room? get room => _room;
  String get serverUrl => _serverUrl;

  /// Connects to the LiveKit room.
  ///
  /// - `participantId` — caller's display name shown to other participants.
  /// - `token` — when provided, used directly as the LiveKit JWT. When null,
  ///   a dev-only JWT is generated in-app via `_generateDevToken`. Replace with
  ///   a token server call once one is available.
  /// - `e2eeKeyProvider` — when provided, the room is created with LiveKit
  ///   FrameCryptor E2EE enabled. Pass
  ///   `MatrixLiveKitKeyProvider.liveKitKeyProvider`. Shared-key mode
  ///   (`fromKey`) is used when a token server supplies the key;
  ///   per-participant mode (`create`) is used otherwise.
  Future<void> connect({
    required String roomId,
    required String participantId,
    String? displayName,
    String? token,
    BaseKeyProvider? e2eeKeyProvider,
    void Function()? onParticipantsChanged,
    void Function()? onDisconnected,
    void Function(String participantIdentity)? onMissingKey,
  }) async {
    final jwt =
        token ??
        _generateDevToken(
          participantId: participantId,
          roomId: roomId,
          displayName: displayName,
        );

    _room = e2eeKeyProvider != null
        ? Room(
            roomOptions: RoomOptions(
              encryption: E2EEOptions(keyProvider: e2eeKeyProvider),
            ),
          )
        : Room();

    _listener = _room!.createListener()
      ..on<RoomDisconnectedEvent>((_) => onDisconnected?.call())
      ..on<ParticipantEvent>((_) => onParticipantsChanged?.call())
      ..on<LocalTrackPublishedEvent>((_) => onParticipantsChanged?.call())
      ..on<TrackSubscribedEvent>((_) => onParticipantsChanged?.call())
      ..on<TrackUnsubscribedEvent>((_) => onParticipantsChanged?.call())
      ..on<TrackE2EEStateEvent>((event) {
        final msg = switch (event.state) {
          E2EEState.kNew => 'Media stream encryption initialising',
          E2EEState.kOk => 'Media stream end-to-end encrypted',
          E2EEState.kKeyRatcheted => 'Media stream encryption key rotated',
          E2EEState.kMissingKey =>
            'Media stream encryption key not yet available',
          E2EEState.kEncryptionFailed =>
            'Media stream failed to encrypt outbound frame',
          E2EEState.kDecryptionFailed =>
            'Media stream failed to decrypt inbound frame — key mismatch?',
          E2EEState.kInternalError => 'Media stream encryption internal error',
        };

        final isError = switch (event.state) {
          E2EEState.kEncryptionFailed ||
          E2EEState.kDecryptionFailed ||
          E2EEState.kInternalError => true,
          _ => false,
        };

        if (isError) {
          _logger.error(msg, name: _logKey);
        } else {
          _logger.info(msg, name: _logKey);
        }

        // When a remote track has no key, ask that participant to resend.
        if (event.state == E2EEState.kMissingKey &&
            event.participant is RemoteParticipant) {
          onMissingKey?.call(event.participant.identity);
        }
      });

    await _room!.connect(_serverUrl, jwt);
    _logger.info(
      'Connected to LiveKit room $roomId (e2ee=${e2eeKeyProvider != null})',
      name: _logKey,
    );
  }

  Future<void> disconnect() async {
    await _listener?.dispose();
    _listener = null;
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
    _logger.info('Disconnected from LiveKit room', name: _logKey);
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    await _room?.localParticipant?.setMicrophoneEnabled(enabled);
  }

  Future<void> setCameraEnabled(bool enabled) async {
    await _room?.localParticipant?.setCameraEnabled(enabled);
  }

  List<Participant> getParticipants() {
    final room = _room;
    if (room == null) return [];
    return [
      if (room.localParticipant != null) room.localParticipant!,
      ...room.remoteParticipants.values,
    ];
  }

  // The server reads the secret from its own secure env variable and returns
  // a short-lived JWT. The secret must never be shipped in the app.
  // TODO (Earl): Replace with a call to the token server
  String _generateDevToken({
    required String participantId,
    required String roomId,
    String? displayName,
  }) {
    final header = base64Url
        .encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})))
        .replaceAll('=', '');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payload = base64Url
        .encode(
          utf8.encode(
            jsonEncode({
              'iss': _apiKey,
              'sub': participantId,
              'iat': now,
              'exp': now + 3600,
              'name': displayName ?? participantId,
              'video': {
                'roomCreate': false,
                'room': roomId,
                'roomJoin': true,
                'canPublish': true,
                'canSubscribe': true,
                'canPublishData': true,
              },
            }),
          ),
        )
        .replaceAll('=', '');
    final signingInput = '$header.$payload';
    final sig = base64Url
        .encode(
          Hmac(
            sha256,
            utf8.encode(_apiSecret),
          ).convert(utf8.encode(signingInput)).bytes,
        )
        .replaceAll('=', '');
    return '$signingInput.$sig';
  }
}
