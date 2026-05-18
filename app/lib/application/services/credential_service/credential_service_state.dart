import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vc_zkp/vc_zkp.dart';

import '../../../domain/models/credentials/liveness_credential_record.dart';

part 'credential_service_state.freezed.dart';

/// State for credential service
@Freezed(fromJson: false, toJson: false)
abstract class CredentialServiceState with _$CredentialServiceState {
  const factory CredentialServiceState({
    @Default({}) Map<String, LivenessCredentialRecord> credentialsByIdentityId,
    @Default({})
    Map<String, SessionCredentialMaterial> sessionMaterialByIdentityId,

    CredentialData? latestCredential,
  }) = _CredentialServiceState;
}

class SessionCredentialMaterial {
  const SessionCredentialMaterial({
    required this.document,
    required this.holderPrivateKeyHex,
    required this.issuerAx,
    required this.issuerAy,
  });

  final SignedVcDocument document;
  final String holderPrivateKeyHex;
  final String issuerAx;
  final String issuerAy;
}

/// Data class representing a credential and its metadata
@Freezed(fromJson: false, toJson: false)
abstract class CredentialData with _$CredentialData {
  const factory CredentialData({
    required String identityId,
    required SignedVcDocument document,
    required String issuerName,
    required DateTime issuedAt,
    required DateTime expiresAt,
    required String holderDid,
  }) = _CredentialData;
}

extension CredentialServiceStateX on CredentialServiceState {
  List<LivenessCredentialRecord> get credentials {
    final list = credentialsByIdentityId.values.toList();
    list.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
    return list;
  }

  LivenessCredentialRecord? credentialFor(String identityId) =>
      credentialsByIdentityId[identityId];

  bool hasCredentialFor(String identityId) =>
      credentialsByIdentityId.containsKey(identityId);

  bool hasSessionMaterialFor(String identityId) =>
      sessionMaterialByIdentityId.containsKey(identityId);
}
