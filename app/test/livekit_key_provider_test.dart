import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' show CallParticipant;
import 'package:mpx_flutter_reference_app/infrastructure/services/livekit_service/matrix_livekit_key_provider.dart';

import 'fakes/fake_call_participant.dart';
import 'fakes/fake_key_provider.dart';

CallParticipant participant(String userId, String deviceId) =>
    FakeCallParticipant(userId: userId, deviceId: deviceId);

void main() {
  late FakeKeyProvider fake;
  late MatrixLiveKitKeyProvider keyProvider;

  setUp(() {
    fake = FakeKeyProvider();
    keyProvider = MatrixLiveKitKeyProvider.forTest(fake);
  });

  group('MatrixLiveKitKeyProvider', () {
    test('onSetEncryptionKey is a no-op (shared-key mode)', () async {
      final key = Uint8List.fromList(List.filled(32, 0x01));

      await keyProvider.onSetEncryptionKey(
        participant('@alice:localhost', 'DEVXYZ'),
        key,
        3,
      );

      // No keys should be stored — shared-key mode does not use
      // per-participant key distribution.
      expect(fake.setRawKeyCalls, isEmpty);
    });

    test(
      'onRatchetKey delegates to ratchetSharedKey',
      () async {
        final result = await keyProvider.onRatchetKey(
          participant('@bob:localhost', 'DEVABC'),
          1,
        );

        expect(fake.ratchetSharedKeyCalls, hasLength(1));
        expect(fake.ratchetSharedKeyCalls.first.keyIndex, 1);
        expect(result, FakeKeyProvider.stubKey);
      },
    );

    test(
      'onExportKey delegates to exportSharedKey',
      () async {
        final result = await keyProvider.onExportKey(
          participant('@charlie:localhost', 'DEVQRS'),
          0,
        );

        expect(fake.exportSharedKeyCalls, hasLength(1));
        expect(fake.exportSharedKeyCalls.first.keyIndex, 0);
        expect(result, FakeKeyProvider.stubKey);
      },
    );

    test('deriveSharedKey produces deterministic 64-char hex', () {
      final key = MatrixLiveKitKeyProvider.deriveSharedKey(
        apiSecret: 'test-secret',
        roomId: 'test-room',
      );
      expect(key.length, 64);
      // Same inputs always yield the same key.
      expect(
        key,
        MatrixLiveKitKeyProvider.deriveSharedKey(
          apiSecret: 'test-secret',
          roomId: 'test-room',
        ),
      );
    });

    test('participant.id is userId:deviceId', () {
      expect(
        participant('@alice:localhost', 'DEVXYZ').id,
        '@alice:localhost:DEVXYZ',
      );
    });
  });
}
