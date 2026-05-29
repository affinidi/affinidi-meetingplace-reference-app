import 'package:meeting_place_relationship/src/shared/credential_constants.dart';
import 'package:meeting_place_relationship/src/shared/credential_signer.dart';
import 'package:ssi/ssi.dart';
import 'package:uuid/uuid.dart';

import '../zkp_service/zkp_constants.dart';
import 'liveness_credential_constants.dart';
import 'liveness_credential_subject.dart';
import 'liveness_evidence_source.dart';

abstract final class LivenessCredentialBuilder {
  static Future<VcDataModelV2> build({
    required String issuerDid,
    required LivenessCredentialSubject subject,
    required DidManager issuerDidManager,
    required LivenessEvidence evidence,
  }) async {
    final validFrom = evidence.checkedAt.toUtc();
    final validUntil = validFrom.add(ZkpConstants.vcExpiryDuration);

    final unsigned = VcDataModelV2(
      context: JsonLdContext.fromJson([
        dmV2ContextUrl,
        RelationshipCredentialConstants.dataIntegrityV2Context,
        LivenessCredentialConstants.contextLivenessCredential,
      ]),
      id: Uri.parse('urn:uuid:${const Uuid().v4()}'),
      issuer: Issuer.uri(issuerDid),
      type: {
        RelationshipCredentialConstants.typeVerifiableCredential,
        LivenessCredentialConstants.typeLivenessCredential,
      },
      validFrom: validFrom,
      validUntil: validUntil,
      credentialSubject: [
        CredentialSubject.fromJson(subject.toJson()),
      ],
    );

    return CredentialSigner.sign(unsigned, issuerDidManager);
  }
}
