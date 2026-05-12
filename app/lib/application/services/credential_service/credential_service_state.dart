import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vc_zkp/vc_zkp.dart';

part 'credential_service_state.freezed.dart';

/// State for credential service
@Freezed(fromJson: false, toJson: false)
abstract class CredentialServiceState with _$CredentialServiceState {
  const factory CredentialServiceState({CredentialData? latestCredential}) =
      _CredentialServiceState;
}

/// Data class representing a credential and its metadata
@Freezed(fromJson: false, toJson: false)
abstract class CredentialData with _$CredentialData {
  const factory CredentialData({
    required SignedVcDocument document,
    required String issuerName,
    required DateTime issuedAt,
    required DateTime expiresAt,
    required String holderDid,
  }) = _CredentialData;
}
