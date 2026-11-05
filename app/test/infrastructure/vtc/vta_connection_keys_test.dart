import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/vta_connection_keys.dart';

import '../../fakes/fake_vta.dart';

const _connectionDid = 'did:web:mpx.example:user:connection';

Matcher _throwsUnavailable(String code) => throwsA(
  isA<VtaSigningUnavailableException>().having((e) => e.code, 'code', code),
);

void main() {
  // did:key multibase of an Ed25519 key, multicodec-prefixed.
  final publicKey = Ed25519DidKeySigner.fromSeed(
    Uint8List.fromList(List.generate(32, (i) => i)),
  ).did.substring('did:key:'.length);

  late FakeVta vta;
  late VtcService service;
  late VtaConnectionKeys keys;

  setUp(() async {
    vta = FakeVta();
    vta.answers[VtaTask.contextsList] = {
      'contexts': [
        {'id': connectionKeysContextId},
      ],
    };
    vta.answers[VtaTask.keysCreate] = {
      'key': {'keyId': 'key-1', 'keyType': 'ed25519', 'publicKey': publicKey},
    };
    service = await vta.linkedService();
    keys = VtaConnectionKeys(service);
  });

  group('VtaConnectionKeys', () {
    test('creates the key on the VTA and keeps only its reference', () async {
      final key = await keys.createKey(_connectionDid);

      expect(key!.keyId, 'key-1');
      expect(key.publicKey, hasLength(32));
      expect(
        vta.received.map((request) => request['type']),
        contains(VtaTask.keysCreate),
      );

      final found = await keys.findKey(_connectionDid);
      expect(found!.keyId, 'key-1');
      expect(found.publicKey, key.publicKey);
      final stored = await const FlutterSecureStorage().readAll();
      expect(
        stored.values.where((value) => value.contains('key-1')),
        hasLength(1),
      );
    });

    test('keeps the key on the device when no VTA is linked', () async {
      await service.unlink();
      vta.received.clear();

      expect(await keys.createKey(_connectionDid), isNull);
      expect(await keys.findKey(_connectionDid), isNull);
      expect(vta.received, isEmpty);
    });

    test('fails when the linked VTA cannot be reached', () async {
      vta.isDown = true;

      await expectLater(
        keys.createKey(_connectionDid),
        _throwsUnavailable(VtaSigningUnavailableException.unreachableCode),
      );
      expect(await keys.findKey(_connectionDid), isNull);
    });

    test('fails when the linked VTA refuses', () async {
      vta.refusals[VtaTask.keysCreate] = {'code': 'forbidden'};

      await expectLater(
        keys.createKey(_connectionDid),
        _throwsUnavailable(VtaSigningUnavailableException.unreachableCode),
      );
    });

    test('cannot sign without a linked VTA', () async {
      await service.unlink();

      await expectLater(
        keys.signDocument(const {'issuer': _connectionDid}, keyId: 'key-1'),
        _throwsUnavailable(VtaSigningUnavailableException.notLinkedCode),
      );
    });
  });
}
