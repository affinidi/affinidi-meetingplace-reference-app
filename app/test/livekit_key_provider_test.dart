import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart' show CallParticipant;
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
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
    keyProvider = MatrixLiveKitKeyProvider.fromProvider(
      fake,
      logger: AppLogger.instance,
    );
  });

  group('MatrixLiveKitKeyProvider', () {
    test('onSetEncryptionKey stores key under participant.id', () async {
      final key = Uint8List.fromList(List.filled(32, 0x01));

      await keyProvider.onSetEncryptionKey(
        participant('@alice:localhost', 'DEVXYZ'),
        key,
        3,
      );

      expect(fake.setRawKeyCalls, hasLength(1));
      expect(
        fake.setRawKeyCalls.first.participantId,
        '@alice:localhost:DEVXYZ',
      );
      expect(fake.setRawKeyCalls.first.keyIndex, 3);
      expect(fake.setRawKeyCalls.first.key, key);
    });

    test(
      'onRatchetKey rotates key for participant.id and returns new key',
      () async {
        final result = await keyProvider.onRatchetKey(
          participant('@bob:localhost', 'DEVABC'),
          1,
        );

        expect(fake.ratchetKeyCalls, hasLength(1));
        expect(
          fake.ratchetKeyCalls.first.participantId,
          '@bob:localhost:DEVABC',
        );
        expect(fake.ratchetKeyCalls.first.keyIndex, 1);
        expect(result, FakeKeyProvider.stubKey);
      },
    );

    test(
      'onExportKey exports key for participant.id and returns current key',
      () async {
        final result = await keyProvider.onExportKey(
          participant('@charlie:localhost', 'DEVQRS'),
          0,
        );

        expect(fake.exportKeyCalls, hasLength(1));
        expect(
          fake.exportKeyCalls.first.participantId,
          '@charlie:localhost:DEVQRS',
        );
        expect(fake.exportKeyCalls.first.keyIndex, 0);
        expect(result, FakeKeyProvider.stubKey);
      },
    );

    test('participant.id is userId:deviceId', () {
      expect(
        participant('@alice:localhost', 'DEVXYZ').id,
        '@alice:localhost:DEVXYZ',
      );
    });
  });
}
