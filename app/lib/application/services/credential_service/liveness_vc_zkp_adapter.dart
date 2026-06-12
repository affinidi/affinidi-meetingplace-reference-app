import 'package:ssi/ssi.dart';
import 'package:vc_zkp/vc_zkp.dart';

import '../zkp_service/zkp_constants.dart';

class LivenessVcZkpMaterial {
  const LivenessVcZkpMaterial({
    required this.document,
    required this.issuerPub,
    required this.holderPub,
    required this.holderPrivateKeyHex,
  });

  final SignedVcDocument document;
  final BabyJubPublicKey issuerPub;
  final BabyJubPublicKey holderPub;
  final String holderPrivateKeyHex;
}

abstract final class LivenessVcZkpAdapter {
  /// Builds a vc_zkp signed document for the Groth16 circuit.
  ///
  /// Uses independently generated EdDSA keys — not the W3C Data Integrity proof
  /// keys on the input credential. The W3C VC and ZKP document are parallel
  /// artifacts; see README § Liveness Credential pipeline.
  static Future<LivenessVcZkpMaterial> buildSignedDocumentFromW3c({
    required VcDataModelV2 w3cCredential,
    required String issuerDid,
    required String holderPrivateKeyHex,
    required String issuerPrivateKeyHex,
  }) async {
    final crypto = RustEddsaHelperFfi();
    final keyDerivation = VcKeyDerivation(crypto: crypto);

    final issuerPub = await keyDerivation.derivePublicKey(
      privateKeyHex: issuerPrivateKeyHex,
    );
    final holderPub = await keyDerivation.derivePublicKey(
      privateKeyHex: holderPrivateKeyHex,
    );

    final subject = w3cCredential.credentialSubject.firstOrNull;
    final subjectMap = subject?.toJson() ?? <String, dynamic>{};
    final holderDid = subjectMap['id']?.toString() ?? '';

    final validFrom = w3cCredential.validFrom?.toUtc();
    final validUntil = w3cCredential.validUntil?.toUtc();
    final issuedAt = validFrom ?? DateTime.now().toUtc();

    final header = <String, Object?>{
      'version': '1',
      'issued_at': issuedAt.millisecondsSinceEpoch ~/ 1000,
      'expires_at':
          (validUntil ?? issuedAt.add(ZkpConstants.vcExpiryDuration))
              .millisecondsSinceEpoch ~/
          1000,
      'issuer': issuerDid,
      'holderAx': holderPub.ax,
      'holderAy': holderPub.ay,
      'schema': ZkpConstants.livenessSchemaVersion,
    };

    final disclosures = <Disclosure>[
      Disclosure(field: 'did', value: holderDid),
    ];

    final issuer = VcIssuer(crypto: crypto);
    final document = await issuer.createSignedDocument(
      header: header,
      disclosures: disclosures,
      issuerPrivateKeyHex: issuerPrivateKeyHex,
    );

    return LivenessVcZkpMaterial(
      document: document,
      issuerPub: issuerPub,
      holderPub: holderPub,
      holderPrivateKeyHex: holderPrivateKeyHex,
    );
  }
}
