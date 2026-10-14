import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/infrastructure/vtc/user_verification_key.dart';
import 'package:ssi/ssi.dart';

class _FakeStorage implements UserVerificationKeyStorage {
  String? seed;
  String? did;
  int seedReads = 0;
  PlatformException? readError;

  @override
  Future<String?> readSeed() async {
    seedReads++;
    if (readError case final error?) throw error;
    return seed;
  }

  @override
  Future<void> writeSeed(String value) async => seed = value;

  @override
  Future<String?> readDid() async => did;

  @override
  Future<void> writeDid(String value) async => did = value;

  @override
  Future<void> delete() async {
    seed = null;
    did = null;
  }
}

Matcher _throwsUv(UserVerificationError error) => throwsA(
  isA<UserVerificationException>().having((e) => e.error, 'error', error),
);

void main() {
  late _FakeStorage storage;
  late UserVerificationKey key;

  setUp(() {
    storage = _FakeStorage();
    key = UserVerificationKey(storage);
  });

  group('UserVerificationKey', () {
    test('creates one key and names it without the biometric prompt', () async {
      final did = await key.ensureKey();

      expect(did, startsWith('did:key:z6Mk'));
      expect(await key.ensureKey(), did);
      expect(await key.did(), did);
      expect(storage.seedReads, 0);
    });

    test('signs as its DID after reading the gated seed', () async {
      final did = await key.ensureKey();
      final signer = await key.signer();

      final signed = await EddsaJcs2022.sign(
        {'issuer': did, 'payload': <String, dynamic>{}},
        signer: signer,
        purpose: ProofPurpose.assertionMethod,
      );

      expect(storage.seedReads, 1);
      await expectLater(
        EddsaJcs2022.verify(
          signed,
          purpose: ProofPurpose.assertionMethod,
          resolver: UniversalDIDResolver.defaultResolver,
          expectedSigner: did,
        ),
        completes,
      );
    });

    test('reports a cancelled biometric prompt', () async {
      await key.ensureKey();
      storage.readError = PlatformException(
        code: '-128',
        message: 'User canceled the operation.',
      );

      expect(
        (await key.signer()).sign(Uint8List(1)),
        _throwsUv(UserVerificationError.cancelled),
      );
    });

    test('reports a key lost to a biometric change', () async {
      await key.ensureKey();
      storage.seed = null;

      expect(
        (await key.signer()).sign(Uint8List(1)),
        _throwsUv(UserVerificationError.lost),
      );
    });

    test('reports a missing key as lost', () {
      expect(key.signer(), _throwsUv(UserVerificationError.lost));
    });

    test('reset deletes the key', () async {
      await key.ensureKey();

      await key.reset();

      expect(await key.did(), isNull);
    });
  });
}
