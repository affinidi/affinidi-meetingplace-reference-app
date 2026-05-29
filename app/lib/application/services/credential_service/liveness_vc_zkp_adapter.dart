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
  final EddsaSignatureResult issuerPub;
  final EddsaSignatureResult holderPub;
  final String holderPrivateKeyHex;
}

abstract final class LivenessVcZkpAdapter {
  static Future<LivenessVcZkpMaterial> buildFromW3cCredential({
    required VcDataModelV2 w3cCredential,
    required String issuerDid,
    required String holderPrivateKeyHex,
    required String issuerPrivateKeyHex,
  }) async {
    final crypto = RustEddsaHelperFfi();

    final issuerPub = await crypto.signDigest(
      msgHash: '1',
      privateKeyHex: issuerPrivateKeyHex,
    );
    final holderPub = await crypto.signDigest(
      msgHash: '1',
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
