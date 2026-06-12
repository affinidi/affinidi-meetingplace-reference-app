import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/credentials/liveness_credential_record.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/liveness_credentials_repository/liveness_credentials_repository_secure_storage.dart';
import '../../fakes/fake_secure_storage.dart';

void main() {
  group('LivenessCredentialsRepositorySecureStorage', () {
    late FakeSecureStorage storage;
    late LivenessCredentialsRepositorySecureStorage repository;

    setUp(() {
      storage = FakeSecureStorage();
      repository = LivenessCredentialsRepositorySecureStorage(storage);
    });

    LivenessCredentialRecord sampleRecord({String identityId = 'identity-1'}) {
      return LivenessCredentialRecord(
        identityId: identityId,
        issuedToDid: 'did:example:holder',
        issuerName: 'did:example:issuer',
        issuerDid: 'did:example:issuer',
        issuedAt: DateTime.utc(2026, 5, 29),
        expiresAt: DateTime.utc(2026, 6, 3),
        livenessProvider: 'demo_liveness',
        w3cCredentialJson: '{"id":"vc-1"}',
        zkpSignedDocumentJson: '{"header":{}}',
        zkpHolderPrivateKeyHex: 'abc123',
        zkpIssuerAx: '1',
        zkpIssuerAy: '2',
      );
    }

    test('upsert persists and lists records', () async {
      await repository.upsert(sampleRecord());

      final records = await repository.list();

      expect(records, hasLength(1));
      expect(records.single.identityId, 'identity-1');
      expect(records.single.w3cCredentialJson, '{"id":"vc-1"}');
    });

    test('upsert replaces record for the same identity', () async {
      await repository.upsert(sampleRecord());
      await repository.upsert(
        sampleRecord().copyWithReplacement(w3cCredentialJson: '{"id":"vc-2"}'),
      );

      final records = await repository.list();

      expect(records, hasLength(1));
      expect(records.single.w3cCredentialJson, '{"id":"vc-2"}');
    });

    test('delete removes a record', () async {
      await repository.upsert(sampleRecord(identityId: 'identity-1'));
      await repository.upsert(sampleRecord(identityId: 'identity-2'));

      await repository.delete('identity-1');

      final records = await repository.list();
      expect(records, hasLength(1));
      expect(records.single.identityId, 'identity-2');
    });

    test('delete last record clears storage', () async {
      await repository.upsert(sampleRecord());
      await repository.delete('identity-1');

      expect(await repository.list(), isEmpty);
      expect(await storage.readLivenessCredentials(), isNull);
    });
  });
}

extension on LivenessCredentialRecord {
  LivenessCredentialRecord copyWithReplacement({String? w3cCredentialJson}) {
    return LivenessCredentialRecord(
      identityId: identityId,
      issuedToDid: issuedToDid,
      issuerName: issuerName,
      issuerDid: issuerDid,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      livenessProvider: livenessProvider,
      w3cCredentialJson: w3cCredentialJson ?? this.w3cCredentialJson,
      zkpSignedDocumentJson: zkpSignedDocumentJson,
      zkpHolderPrivateKeyHex: zkpHolderPrivateKeyHex,
      zkpIssuerAx: zkpIssuerAx,
      zkpIssuerAy: zkpIssuerAy,
    );
  }
}
