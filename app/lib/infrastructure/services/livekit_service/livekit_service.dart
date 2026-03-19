import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../loggers/app_logger/app_logger.dart';

/// Encapsulates all LiveKit room interactions: connect, disconnect,
/// media toggles, participant list, and room event streaming.
///
/// Token generation here is dev-only. In production, replace
/// [generateDevToken] with a call to your token server endpoint.
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

  /// Connects to the LiveKit room using a dev-generated JWT.
  Future<void> connect({
    required String roomId,
    required String participantId,
    void Function()? onParticipantsChanged,
    void Function()? onDisconnected,
  }) async {
    final token = generateDevToken(
      participantId: participantId,
      roomId: roomId,
    );

    _room = Room();
    _listener = _room!.createListener()
      ..on<RoomDisconnectedEvent>((_) => onDisconnected?.call())
      ..on<ParticipantEvent>((_) => onParticipantsChanged?.call())
      ..on<LocalTrackPublishedEvent>((_) => onParticipantsChanged?.call())
      ..on<TrackSubscribedEvent>((_) => onParticipantsChanged?.call())
      ..on<TrackUnsubscribedEvent>((_) => onParticipantsChanged?.call());

    await _room!.connect(_serverUrl, token);
    _logger.info('Connected to LiveKit room $roomId', name: _logKey);
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
  String generateDevToken({
    required String participantId,
    required String roomId,
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
              'name': participantId,
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
