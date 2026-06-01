import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_errors.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_w3c_credential_validation.dart';
import 'package:ssi/ssi.dart';

void main() {
  group('validateIssuedW3cLivenessCredential', () {
    const holderDid = 'did:example:holder';
    final evidence = LivenessEvidence(
      providerId: 'demo_liveness',
      providerTransactionId: 'session-abc',
      livenessScore: 99,
      livenessThreshold: 80,
      checkedAt: DateTime.utc(2026, 5, 29, 12),
    );

    test('accepts a valid signed credential', () {
      expect(
        () => validateIssuedW3cLivenessCredential(
          credential: _validCredential(
            holderDid: holderDid,
            evidence: evidence,
          ),
          holderDid: holderDid,
          evidence: evidence,
        ),
        returnsNormally,
      );
    });

    test('rejects missing LivenessCredential type', () {
      final credential = _validCredential(
        holderDid: holderDid,
        evidence: evidence,
        types: {'VerifiableCredential'},
      );

      expect(
        () => validateIssuedW3cLivenessCredential(
          credential: credential,
          holderDid: holderDid,
          evidence: evidence,
        ),
        throwsA(isA<InvalidLivenessW3cCredentialException>()),
      );
    });

    test('rejects missing proof', () {
      final credential = _validCredential(
        holderDid: holderDid,
        evidence: evidence,
        includeProof: false,
      );

      expect(
        () => validateIssuedW3cLivenessCredential(
          credential: credential,
          holderDid: holderDid,
          evidence: evidence,
        ),
        throwsA(isA<InvalidLivenessW3cCredentialException>()),
      );
    });

    test('rejects subject DID mismatch', () {
      expect(
        () => validateIssuedW3cLivenessCredential(
          credential: _validCredential(
            holderDid: 'did:example:other',
            evidence: evidence,
          ),
          holderDid: holderDid,
          evidence: evidence,
        ),
        throwsA(isA<InvalidLivenessW3cCredentialException>()),
      );
    });

    test('rejects evidence mismatch', () {
      final mismatchedEvidence = LivenessEvidence(
        providerId: 'other_provider',
        providerTransactionId: 'other-session',
        livenessScore: 99,
        livenessThreshold: 80,
        checkedAt: DateTime.utc(2026, 5, 29, 12),
      );

      expect(
        () => validateIssuedW3cLivenessCredential(
          credential: _validCredential(
            holderDid: holderDid,
            evidence: evidence,
          ),
          holderDid: holderDid,
          evidence: mismatchedEvidence,
        ),
        throwsA(isA<InvalidLivenessW3cCredentialException>()),
      );
    });
  });
}

VcDataModelV2 _validCredential({
  required String holderDid,
  required LivenessEvidence evidence,
  Set<String>? types,
  bool includeProof = true,
}) {
  final json = <String, dynamic>{
    '@context': ['https://www.w3.org/ns/credentials/v2'],
    'type': (types ?? {'VerifiableCredential', 'LivenessCredential'}).toList(),
    'issuer': 'did:example:issuer',
    'credentialSubject': [
      {
        'id': holderDid,
        'livenessProvider': evidence.providerId,
        'livenessSessionId': evidence.providerTransactionId,
        'livenessScore': evidence.livenessScore,
        'livenessThreshold': evidence.livenessThreshold,
        'livenessPassed': true,
        'checkedAt': evidence.checkedAt.toUtc().toIso8601String(),
      },
    ],
  };

  if (includeProof) {
    json['proof'] = {'type': 'DataIntegrityProof', 'proofValue': 'abc'};
  }

  return VcDataModelV2.fromJson(json);
}
