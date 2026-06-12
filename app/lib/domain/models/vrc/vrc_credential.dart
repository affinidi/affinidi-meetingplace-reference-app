import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart'
    show CredentialsSDKConstants, VrcConstants;
import 'package:ssi/ssi.dart';

import 'vrc_credential_subject.dart';

part 'vrc_credential.freezed.dart';

@freezed
abstract class VrcCredential with _$VrcCredential {
  const factory VrcCredential({
    required String id,
    required String vc,
    required String channelId,
    required String holderIdentityDid,
    required String issuerIdentityDid,
    required DateTime issuedAt,
    DateTime? verifiedAt,
  }) = _VrcCredential;
}

extension ParsedVerifiableCredentialVrcExtension on ParsedVerifiableCredential {
  VrcCredential toVrcCredential({
    required String channelId,
    DateTime? verifiedAt,
  }) {
    final subjectJson = credentialSubject.firstOrNull as Map<String, dynamic>?;
    final subject = VrcCredentialSubject.fromJson(subjectJson ?? {});

    return VrcCredential(
      id: id.toString(),
      vc: serialized as String,
      channelId: channelId,
      holderIdentityDid: subject.to.did,
      issuerIdentityDid: subject.from.did,
      issuedAt: validFrom ?? DateTime.now(),
      verifiedAt: verifiedAt,
    );
  }

  bool get isCredentialVrc {
    return type.contains(CredentialsSDKConstants.typeVerifiableCredential) &&
        type.contains(VrcConstants.typeRelationshipCredential);
  }
}
