import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';

/// Local dev helper for Tuwunel compose in the `affinidi-ai-mpx-matrix` repo.
///
/// Tuwunel validates HS256 JWTs with `TUWUNEL_JWT__KEY`. The Meeting Place Core
/// SDK logs in with `org.matrix.login.jwt` and
/// `AuthenticationUserIdentifier(user: md5(did))`, so the JWT `sub` must be
/// that md5 hex string.
///
/// When [Environment.matrixJwtHs256Secret] is set (via `--dart-define`), call
/// [injectDevCredentialIfConfigured] so Matrix login uses Tuwunel instead of a
/// control-plane JWT minted for Synapse.
final class TuwunelDevMatrixJwt {
  TuwunelDevMatrixJwt._();

  static String mintHs256Jwt({
    required String secret,
    required String sub,
    Duration ttl = const Duration(hours: 1),
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = now + ttl.inSeconds;
    final header = jsonEncode({'alg': 'HS256', 'typ': 'JWT'});
    final payload = jsonEncode({'sub': sub, 'iat': now, 'exp': exp});
    final h = _b64urlNoPad(utf8.encode(header));
    final p = _b64urlNoPad(utf8.encode(payload));
    final signingInput = '$h.$p';
    final sig = Hmac(sha256, utf8.encode(secret))
        .convert(utf8.encode(signingInput))
        .bytes;
    return '$signingInput.${_b64urlNoPad(sig)}';
  }

  static String _b64urlNoPad(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  /// Writes a Tuwunel-compatible Matrix login JWT to secure storage when
  /// [Environment.matrixJwtHs256Secret] is non-empty.
  static Future<void> injectDevCredentialIfConfigured({
    required Environment environment,
    required MeetingPlaceCoreSDK sdk,
    required SecureStorage secureStorage,
  }) async {
    final secret = environment.matrixJwtHs256Secret;
    if (secret == null || secret.isEmpty) {
      return;
    }
    final did = (await sdk.discovery.didManager.getDidDocument()).id;
    final sub = md5.convert(utf8.encode(did)).toString();
    final jwt = mintHs256Jwt(secret: secret, sub: sub);
    await secureStorage.saveMatrixLoginCredential(jwt: jwt);
  }
}
