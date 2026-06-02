import 'package:mpx_flutter_reference_app/application/services/credential_service/credential_service.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_vc_zkp_adapter.dart';
import 'package:ssi/ssi.dart';

/// Fixed 32-byte verifier challenge used across ZKP service tests.
final testZkpChallengeNonce = List<int>.generate(32, (index) => index);

const testIssuerPrivateKeyHex =
    '0101010101010101010101010101010101010101010101010101010101010101';
const testHolderPrivateKeyHex =
    '0202020202020202020202020202020202020202020202020202020202020202';

Future<CredentialCreationResult> buildTestCredentialCreationResult() async {
  final material = await LivenessVcZkpAdapter.buildSignedDocumentFromW3c(
    w3cCredential: _sampleW3cCredential,
    issuerDid: 'did:example:issuer',
    issuerPrivateKeyHex: testIssuerPrivateKeyHex,
    holderPrivateKeyHex: testHolderPrivateKeyHex,
  );

  return CredentialCreationResult(
    document: material.document,
    issuerPub: material.issuerPub,
    holderPub: material.holderPub,
    holderPrivateKeyHex: material.holderPrivateKeyHex,
  );
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

class FakeCredentialService extends CredentialService {
  FakeCredentialService({
    required super.ref,
    this.credentialResult,
    this.missingSession = false,
  });

  final CredentialCreationResult? credentialResult;
  final bool missingSession;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<CredentialCreationResult> prepareCredentialForProof({
    required String identityId,
  }) async {
    if (missingSession) {
      throw const LivenessCredentialSessionMissingException();
    }
    return credentialResult!;
  }
}
