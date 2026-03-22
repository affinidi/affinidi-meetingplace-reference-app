/// Response model for a LiveKit token server request.
///
/// The server returns a short-lived JWT ([token]) for room access and the
/// pre-derived E2EE key ([e2eeKey]) as a 64-char hex string (32 bytes). The
/// key is derived server-side using `HMAC-SHA256(apiSecret, roomId)` so that
/// the `apiSecret` never has to be shipped inside the app binary.
class LiveKitTokenResponse {
  factory LiveKitTokenResponse.fromJson(Map<String, dynamic> json) {
    return LiveKitTokenResponse(
      token: json['token'] as String,
      e2eeKey: json['e2eeKey'] as String,
    );
  }

  const LiveKitTokenResponse({required this.token, required this.e2eeKey});

  /// Short-lived LiveKit JWT signed by the server.
  final String token;

  /// 64-char lowercase hex E2EE key derived from
  /// `HMAC-SHA256(apiSecret, roomId)`.
  final String e2eeKey;
}
