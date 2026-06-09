import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/credentials/liveness_credential_record.dart';

void main() {
  group('LivenessCredentialRecord.displayIssuer', () {
    test('prefers issuerDid when set', () {
      final record = LivenessCredentialRecord(
        identityId: 'id-1',
        issuedToDid: 'did:example:holder',
        issuerName: 'Affinidi',
        issuerDid: 'did:example:issuer',
        issuedAt: DateTime.utc(2026, 5, 29),
        expiresAt: DateTime.utc(2026, 6, 3),
        w3cCredentialJson: '',
        zkpSignedDocumentJson: '',
        zkpHolderPrivateKeyHex: '',
        zkpIssuerAx: '',
        zkpIssuerAy: '',
        livenessProvider: 'demo_liveness',
      );

      expect(record.displayIssuer, 'did:example:issuer');
    });

    test('falls back to issuerName for legacy records', () {
      final record = LivenessCredentialRecord(
        identityId: 'id-1',
        issuedToDid: 'did:example:holder',
        issuerName: 'Affinidi',
        issuerDid: '',
        issuedAt: DateTime.utc(2026, 5, 29),
        expiresAt: DateTime.utc(2026, 6, 3),
        w3cCredentialJson: '',
        zkpSignedDocumentJson: '',
        zkpHolderPrivateKeyHex: '',
        zkpIssuerAx: '',
        zkpIssuerAy: '',
        livenessProvider: 'demo_liveness',
      );

      expect(record.displayIssuer, 'Affinidi');
    });

    test('fromJson defaults issuerDid to empty string', () {
      final record = LivenessCredentialRecord.fromJson({
        'identityId': 'id-1',
        'issuedToDid': 'did:example:holder',
        'issuerName': 'Affinidi',
        'issuedAt': '2026-05-29T12:00:00.000Z',
        'expiresAt': '2026-06-03T12:00:00.000Z',
      });

      expect(record.issuerDid, isEmpty);
      expect(record.displayIssuer, 'Affinidi');
    });
  });
}
