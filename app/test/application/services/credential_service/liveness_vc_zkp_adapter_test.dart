import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_vc_zkp_adapter.dart';
import 'package:ssi/ssi.dart' hide VcVerifier;
import 'package:vc_zkp/vc_zkp.dart';

void main() {
  group('LivenessVcZkpAdapter', () {
    test(
      'buildSignedDocumentFromW3c produces verifiable signed document',
      () async {
        final w3c = VcDataModelV2(
          context: JsonLdContext.fromJson([
            'https://www.w3.org/ns/credentials/v2',
          ]),
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

        const issuerPrivateKeyHex =
            '0101010101010101010101010101010101010101010101010101010101010101';
        const holderPrivateKeyHex =
            '0202020202020202020202020202020202020202020202020202020202020202';

        final material = await LivenessVcZkpAdapter.buildSignedDocumentFromW3c(
          w3cCredential: w3c,
          issuerDid: 'did:example:issuer',
          issuerPrivateKeyHex: issuerPrivateKeyHex,
          holderPrivateKeyHex: holderPrivateKeyHex,
        );

        expect(material.document.disclosures.single.field, 'did');
        expect(
          material.document.disclosures.single.value,
          'did:example:holder',
        );
        expect(material.document.header['issuer'], 'did:example:issuer');

        final verification = await VcVerifier().verifyDocument(
          material.document,
          issuerPublicKeyAx: material.issuerPub.ax,
          issuerPublicKeyAy: material.issuerPub.ay,
          isIssuerPubKeyMatchAlreadyVerified: true,
        );

        expect(verification.valid, isTrue);
      },
    );
  });
}
