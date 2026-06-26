import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_livekit_flutter/src/delegates/matrix_encryption_key_provider_adapter.dart';

import '../fakes/fake_base_key_provider.dart';
import '../fakes/fake_call_participant.dart';

void main() {
  group('MatrixEncryptionKeyProviderAdapter', () {
    late FakeKeyProvider fakeKeyProvider;
    late MatrixEncryptionKeyProviderAdapter adapter;

    const participantId = '@alice:example.org:DEVICE1';

    setUp(() {
      fakeKeyProvider = FakeKeyProvider();
      adapter = MatrixEncryptionKeyProviderAdapter(fakeKeyProvider);
    });

    test('onSetEncryptionKey forwards key and index to KeyProvider', () async {
      final key = Uint8List.fromList([1, 2, 3, 4]);
      await adapter.onSetEncryptionKey(
        FakeCallParticipant(participantId),
        key,
        2,
      );

      expect(fakeKeyProvider.setRawKeyCalls, hasLength(1));
      expect(fakeKeyProvider.setRawKeyCalls.first.participantId, participantId);
      expect(fakeKeyProvider.setRawKeyCalls.first.key, key);
      expect(fakeKeyProvider.setRawKeyCalls.first.index, 2);
    });

    test(
      'onRatchetKey forwards participant and index to KeyProvider',
      () async {
        final result = await adapter.onRatchetKey(
          FakeCallParticipant(participantId),
          1,
        );

        expect(fakeKeyProvider.ratchetKeyCalls, hasLength(1));
        expect(
          fakeKeyProvider.ratchetKeyCalls.first.participantId,
          participantId,
        );
        expect(fakeKeyProvider.ratchetKeyCalls.first.index, 1);
        expect(result, fakeKeyProvider.returnedRatchetKey);
      },
    );

    test('onExportKey forwards participant and index to KeyProvider', () async {
      final result = await adapter.onExportKey(
        FakeCallParticipant(participantId),
        0,
      );

      expect(fakeKeyProvider.exportKeyCalls, hasLength(1));
      expect(fakeKeyProvider.exportKeyCalls.first.participantId, participantId);
      expect(fakeKeyProvider.exportKeyCalls.first.index, 0);
      expect(result, fakeKeyProvider.returnedExportKey);
    });
  });
}
