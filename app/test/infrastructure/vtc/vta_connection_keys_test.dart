import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/vta_connection_keys.dart';
import 'package:ssi/ssi.dart';

import '../../fakes/fake_vta.dart';

const _connectionDid = 'did:web:mpx.example:user:connection';

Matcher _throwsUnavailable(String code) => throwsA(
  isA<VtaSigningUnavailableException>().having((e) => e.code, 'code', code),
);

void main() {
  // did:key multibase of an Ed25519 key, multicodec-prefixed.
  String multibaseOf(Uint8List seed) =>
      Ed25519DidKeySigner.fromSeed(seed).did.substring('did:key:'.length);
  final signingKey = multibaseOf(
    Uint8List.fromList(List.generate(32, (i) => i)),
  );
  final secret = Uint8List.fromList(List.generate(32, (i) => i + 1));
  final agreementKey = multibaseOf(secret);
  final controlPlaneKey = toMultiBase(
    Uint8List.fromList([
      0x80,
      0x24,
      ...P256KeyPair.generate().$1.publicKey.bytes,
    ]),
  );

  late FakeVta vta;
  late VtcService service;
  late VtaConnectionKeys keys;

  int loans() =>
      vta.received.where((r) => r['type'] == VtaTask.exportSecret).length;

  setUp(() async {
    var created = 0;
    vta = FakeVta();
    vta.answers[VtaTask.contextsList] = {
      'contexts': [
        {'id': connectionKeysContextId},
      ],
    };
    // The signing key first, then the agreement key, then the P-256 one
    // for the control plane.
    vta.answerTo[VtaTask.keysCreate] = (payload) => {
      'key': {
        'keyId': 'key-${++created}',
        'keyType': payload['keyType'],
        'publicKey': switch (created) {
          1 => signingKey,
          2 => agreementKey,
          _ => controlPlaneKey,
        },
      },
    };
    vta.answerTo[VtaTask.exportSecret] = (payload) => {
      'keyId': payload['keyId'],
      'privateKeyMultibase': toMultiBase(
        Uint8List.fromList([0x80, 0x26, ...secret]),
      ),
    };
    service = await vta.linkedService();
    keys = VtaConnectionKeys(service);
  });

  group('VtaConnectionKeys', () {
    test('creates the keys on the VTA and keeps only references', () async {
      final created = await keys.createKeys(_connectionDid);

      expect(created!.signing.keyId, 'key-1');
      expect(created.signing.publicKey, hasLength(32));
      expect(created.agreement.keyId, 'key-2');
      expect(created.agreement.publicKey, hasLength(32));
      expect(created.controlPlaneAgreement!.keyId, 'key-3');
      expect(created.controlPlaneAgreement!.publicKey, hasLength(33));

      final found = await keys.findKeys(_connectionDid);
      expect(found!.signing.keyId, 'key-1');
      expect(found.agreement.keyId, 'key-2');
      expect(found.agreement.publicKey, created.agreement.publicKey);
      expect(found.controlPlaneAgreement!.keyId, 'key-3');
      expect(
        found.controlPlaneAgreement!.publicKey,
        created.controlPlaneAgreement!.publicKey,
      );

      final stored = (await const FlutterSecureStorage().readAll()).values
          .join();
      expect(stored, contains('key-2'));
      expect(stored, isNot(contains('privateKey')));
      expect(loans(), 0);
    });

    test('finds no control plane key for a DID made before', () async {
      await const FlutterSecureStorage().write(
        key: 'vta_connection_keys_$_connectionDid',
        value:
            '{"signing":{"keyId":"key-1","publicKey":"AA=="},'
            '"agreement":{"keyId":"key-2","publicKey":"AA=="}}',
      );

      final found = await keys.findKeys(_connectionDid);

      expect(found!.agreement.keyId, 'key-2');
      expect(found.controlPlaneAgreement, isNull);
    });

    test('borrows the DIDComm key once while linked', () async {
      final first = await keys.lendSecret('key-2');
      first.fillRange(0, first.length, 0);
      final second = await keys.lendSecret('key-2');

      expect(second, secret);
      expect(loans(), 1);
    });

    test('borrows the key once when asked for it at the same time', () async {
      await Future.wait([keys.lendSecret('key-2'), keys.lendSecret('key-2')]);

      expect(loans(), 1);
    });

    test('forgets lent keys on unlink', () async {
      await keys.lendSecret('key-2');
      await service.unlink();

      await expectLater(
        keys.lendSecret('key-2'),
        _throwsUnavailable(VtaSigningUnavailableException.notLinkedCode),
      );
    });

    test('asks again after a failed loan', () async {
      vta.isDown = true;
      await expectLater(
        keys.lendSecret('key-2'),
        _throwsUnavailable(VtaSigningUnavailableException.unreachableCode),
      );

      vta.isDown = false;
      expect(await keys.lendSecret('key-2'), secret);
    });

    test('keeps the keys on the device when no VTA is linked', () async {
      await service.unlink();
      vta.received.clear();

      expect(await keys.createKeys(_connectionDid), isNull);
      expect(await keys.findKeys(_connectionDid), isNull);
      expect(vta.received, isEmpty);
    });

    test('fails when the linked VTA cannot be reached', () async {
      vta.isDown = true;

      await expectLater(
        keys.createKeys(_connectionDid),
        _throwsUnavailable(VtaSigningUnavailableException.unreachableCode),
      );
      expect(await keys.findKeys(_connectionDid), isNull);
    });

    test('fails when the linked VTA refuses', () async {
      vta.refusals[VtaTask.keysCreate] = {'code': 'forbidden'};

      await expectLater(
        keys.createKeys(_connectionDid),
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
