import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/credential_service/liveness_vc_zkp_adapter.dart';
import 'package:ssi/ssi.dart' hide VcVerifier;
import 'package:vc_zkp/vc_zkp.dart';

void main() {
  group('LivenessVcZkpAdapter', () {
    test(
      'builds and verifies a ZKP document from a signed W3C credential',
      () async {
        final checkedAt = DateTime.now().toUtc().subtract(
          const Duration(minutes: 1),
        );
        final w3c = VcDataModelV2(
          context: JsonLdContext.fromJson([
            'https://www.w3.org/ns/credentials/v2',
          ]),
          issuer: Issuer.uri('did:example:issuer'),
          type: {'VerifiableCredential', 'LivenessCredential'},
          validFrom: checkedAt.subtract(const Duration(minutes: 1)),
          validUntil: checkedAt.add(const Duration(days: 5)),
          credentialSubject: [
            CredentialSubject.fromJson({
              'id': 'did:example:holder',
              'livenessProvider': 'demo_liveness',
              'livenessSessionId': 'session-abc',
              'livenessScore': 99,
              'livenessThreshold': 80,
              'livenessPassed': true,
              'checkedAt': checkedAt.toIso8601String(),
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
