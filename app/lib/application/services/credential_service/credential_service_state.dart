import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/credentials/credential_data.dart';
import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../domain/models/credentials/session_credential_material.dart';

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

  bool hasSessionMaterialFor(String identityId) {
    final record = credentialsByIdentityId[identityId];
    if (record == null) return false;
    final isExpired = !record.expiresAt.toUtc().isAfter(DateTime.now().toUtc());
    if (isExpired) return false;
    return sessionMaterialByIdentityId.containsKey(identityId);
  }
}
