import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/livekit_service/matrix_livekit_key_provider.dart';

void main() {
  group('MatrixLiveKitKeyProvider.deriveSharedKey', () {
    const apiSecret = 'test-api-secret';
    const roomId = '!room123:localhost';

    test('produces a 64-character hex string (32 bytes)', () {
      final key = MatrixLiveKitKeyProvider.deriveSharedKey(
        apiSecret: apiSecret,
        roomId: roomId,
      );
      expect(key.length, 64);
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(key), isTrue);
    });

    test('is deterministic — same inputs always yield the same key', () {
      final key1 = MatrixLiveKitKeyProvider.deriveSharedKey(
        apiSecret: apiSecret,
        roomId: roomId,
      );
      final key2 = MatrixLiveKitKeyProvider.deriveSharedKey(
        apiSecret: apiSecret,
        roomId: roomId,
      );
      expect(key1, equals(key2));
    });

    test('matches a reference HMAC-SHA256 computed independently', () {
      // Compute the reference value using the same crypto package
      // so the test is self-contained and correct by construction.
      final expected = Hmac(sha256, utf8.encode(apiSecret))
          .convert(utf8.encode(roomId))
          .bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      final actual = MatrixLiveKitKeyProvider.deriveSharedKey(
        apiSecret: apiSecret,
        roomId: roomId,
      );
      expect(actual, equals(expected));
    });

    test('different roomId produces a different key', () {
      final key1 = MatrixLiveKitKeyProvider.deriveSharedKey(
        apiSecret: apiSecret,
        roomId: '!room-a:localhost',
      );
      final key2 = MatrixLiveKitKeyProvider.deriveSharedKey(
        apiSecret: apiSecret,
        roomId: '!room-b:localhost',
      );
      expect(key1, isNot(equals(key2)));
    });

    test('different apiSecret produces a different key', () {
      final key1 = MatrixLiveKitKeyProvider.deriveSharedKey(
        apiSecret: 'secret-1',
        roomId: roomId,
      );
      final key2 = MatrixLiveKitKeyProvider.deriveSharedKey(
        apiSecret: 'secret-2',
        roomId: roomId,
      );
      expect(key1, isNot(equals(key2)));
    });
  });
}
