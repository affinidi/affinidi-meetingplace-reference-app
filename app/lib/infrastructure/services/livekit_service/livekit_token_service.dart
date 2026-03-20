import 'dart:convert';

import 'package:http/http.dart' as http;

import 'livekit_token_response.dart';

/// Fetches a LiveKit JWT and E2EE key from a token server.
///
/// The token server is responsible for:
/// - Signing a short-lived LiveKit JWT with the API secret (so the secret
///   never needs to be bundled in the app).
/// - Deriving the E2EE key as `HMAC-SHA256(apiSecret, roomId)` and returning
///   it alongside the JWT.
///
/// Expected server response shape:
/// ```json
/// { "token": "<livekit-jwt>", "e2eeKey": "<64-char-hex>" }
/// ```
///
/// See [LiveKitTokenResponse] for the response model.
///
/// Usage:
/// ```dart
/// final service = LiveKitTokenService(serverUrl: 'https://your-token-server');
/// final response = await service.fetchToken(
///   roomId: roomId,
///   participantId: participantId,
/// );
/// ```
class LiveKitTokenService {
  LiveKitTokenService({required String serverUrl, http.Client? httpClient})
    : _serverUrl = serverUrl,
      _httpClient = httpClient ?? http.Client();

  final String _serverUrl;
  final http.Client _httpClient;

  /// Requests a [LiveKitTokenResponse] from the token server for the given
  /// [roomId] and [participantId].
  ///
  /// Throws [LiveKitTokenException] if the server returns a non-200 status or
  /// an unexpected response shape.
  Future<LiveKitTokenResponse> fetchToken({
    required String roomId,
    required String participantId,
  }) async {
    final uri = Uri.parse(_serverUrl).replace(
      path: '/livekit/token',
      queryParameters: {'roomId': roomId, 'participantId': participantId},
    );

    final response = await _httpClient.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw LiveKitTokenException(
        'Token server returned ${response.statusCode}: ${response.body}',
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const LiveKitTokenException('Token server returned invalid JSON.');
    }

    if (json['token'] is! String || json['e2eeKey'] is! String) {
      throw const LiveKitTokenException(
        'Token server response missing required fields: "token", "e2eeKey".',
      );
    }

    return LiveKitTokenResponse.fromJson(json);
  }
}

class LiveKitTokenException implements Exception {
  const LiveKitTokenException(this.message);
  final String message;

  @override
  String toString() => 'LiveKitTokenException: $message';
}
