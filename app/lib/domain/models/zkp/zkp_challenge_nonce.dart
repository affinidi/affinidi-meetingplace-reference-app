import 'dart:math';

const zkpChallengeNonceByteLength = 32;

/// Verifier-issued 32-byte challenge for liveness ZKP generation.
List<int> generateZkpChallengeNonce() {
  return List<int>.generate(
    zkpChallengeNonceByteLength,
    (_) => Random.secure().nextInt(256),
  );
}

String zkpChallengeNonceToHex(List<int> bytes) {
  if (bytes.length != zkpChallengeNonceByteLength) {
    throw ArgumentError(
      'challenge nonce must be $zkpChallengeNonceByteLength bytes',
    );
  }
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
