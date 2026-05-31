import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_credential_session.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_vc_zkp_adapter.dart';
import 'package:mpx_flutter_reference_app/domain/models/credentials/liveness_credential_record.dart';
import 'package:ssi/ssi.dart';

void main() {
  group('sessionMaterialFromRecord', () {
    late String zkpDocumentJson;
    late String holderPrivateKeyHex;
    late String issuerAx;
    late String issuerAy;

    setUpAll(() async {
      const issuerPrivateKeyHex =
          '0101010101010101010101010101010101010101010101010101010101010101';
      holderPrivateKeyHex =
          '0202020202020202020202020202020202020202020202020202020202020202';

      final material = await LivenessVcZkpAdapter.buildSignedDocumentFromW3c(
        w3cCredential: _sampleW3cCredential,
        issuerDid: 'did:example:issuer',
        issuerPrivateKeyHex: issuerPrivateKeyHex,
        holderPrivateKeyHex: holderPrivateKeyHex,
      );

      zkpDocumentJson = jsonEncode(material.document.toJson());
      issuerAx = material.issuerPub.ax;
      issuerAy = material.issuerPub.ay;
    });

    test('returns session material when ZKP fields are persisted', () {
      final record = LivenessCredentialRecord(
        identityId: 'id-1',
        issuedToDid: 'did:example:holder',
        issuerName: 'did:example:issuer',
        issuerDid: 'did:example:issuer',
        issuedAt: DateTime.utc(2026, 5, 29),
        expiresAt: DateTime.utc(2026, 6, 3),
        livenessProvider: 'demo_liveness',
        w3cCredentialJson: '{}',
        zkpSignedDocumentJson: zkpDocumentJson,
        zkpHolderPrivateKeyHex: holderPrivateKeyHex,
        zkpIssuerAx: issuerAx,
        zkpIssuerAy: issuerAy,
      );

      final session = sessionMaterialFromRecord(record);

      expect(session, isNotNull);
      expect(session!.holderPrivateKeyHex, holderPrivateKeyHex);
      expect(session.issuerAx, issuerAx);
      expect(session.issuerAy, issuerAy);
      expect(session.document.header['issuer'], 'did:example:issuer');
    });

    test('returns null when ZKP document json is missing', () {
      final record = LivenessCredentialRecord(
        identityId: 'id-1',
        issuedToDid: 'did:example:holder',
        issuerName: 'did:example:issuer',
        issuerDid: 'did:example:issuer',
        issuedAt: DateTime.utc(2026, 5, 29),
        expiresAt: DateTime.utc(2026, 6, 3),
        livenessProvider: 'demo_liveness',
        w3cCredentialJson: '{}',
        zkpSignedDocumentJson: '',
        zkpHolderPrivateKeyHex: holderPrivateKeyHex,
        zkpIssuerAx: issuerAx,
        zkpIssuerAy: issuerAy,
      );

      expect(sessionMaterialFromRecord(record), isNull);
    });

    test('returns null when holder private key is missing', () {
      final record = LivenessCredentialRecord(
        identityId: 'id-1',
        issuedToDid: 'did:example:holder',
        issuerName: 'did:example:issuer',
        issuerDid: 'did:example:issuer',
        issuedAt: DateTime.utc(2026, 5, 29),
        expiresAt: DateTime.utc(2026, 6, 3),
        livenessProvider: 'demo_liveness',
        w3cCredentialJson: '{}',
        zkpSignedDocumentJson: zkpDocumentJson,
        zkpHolderPrivateKeyHex: '',
        zkpIssuerAx: issuerAx,
        zkpIssuerAy: issuerAy,
      );

      expect(sessionMaterialFromRecord(record), isNull);
    });

    test('returns null when W3C credential json is missing', () {
      final record = LivenessCredentialRecord(
        identityId: 'id-1',
        issuedToDid: 'did:example:holder',
        issuerName: 'did:example:issuer',
        issuerDid: 'did:example:issuer',
        issuedAt: DateTime.utc(2026, 5, 29),
        expiresAt: DateTime.utc(2026, 6, 3),
        livenessProvider: 'demo_liveness',
        w3cCredentialJson: '',
        zkpSignedDocumentJson: zkpDocumentJson,
        zkpHolderPrivateKeyHex: holderPrivateKeyHex,
        zkpIssuerAx: issuerAx,
        zkpIssuerAy: issuerAy,
      );

      expect(sessionMaterialFromRecord(record), isNull);
    });

    test('returns null for corrupt ZKP document json', () {
      final record = LivenessCredentialRecord(
        identityId: 'id-1',
        issuedToDid: 'did:example:holder',
        issuerName: 'did:example:issuer',
        issuerDid: 'did:example:issuer',
        issuedAt: DateTime.utc(2026, 5, 29),
        expiresAt: DateTime.utc(2026, 6, 3),
        livenessProvider: 'demo_liveness',
        w3cCredentialJson: '{}',
        zkpSignedDocumentJson: '{not-valid-json',
        zkpHolderPrivateKeyHex: holderPrivateKeyHex,
        zkpIssuerAx: issuerAx,
        zkpIssuerAy: issuerAy,
      );

      expect(sessionMaterialFromRecord(record), isNull);
    });
  });
}

final _sampleW3cCredential = VcDataModelV2(
  context: JsonLdContext.fromJson(['https://www.w3.org/ns/credentials/v2']),
  issuer: Issuer.uri('did:example:issuer'),
  type: {'VerifiableCredential', 'LivenessCredential'},
  validFrom: DateTime.utc(2026, 5, 29, 12),
  validUntil: DateTime.utc(2026, 6, 3, 12),
  credentialSubject: [
    CredentialSubject.fromJson({
      'id': 'did:example:holder',
      'livenessProvider': 'demo_liveness',
      'livenessSessionId': 'session-abc',
      'livenessScore': 99,
      'livenessThreshold': 80,
      'livenessPassed': true,
      'checkedAt': '2026-05-29T12:00:00.000Z',
    }),
  ],
);
