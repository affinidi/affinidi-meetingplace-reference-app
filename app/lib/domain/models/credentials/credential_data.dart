import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential_data.freezed.dart';

/// Data class representing a credential and its metadata.
@Freezed(fromJson: false, toJson: false)
abstract class CredentialData with _$CredentialData {
  const factory CredentialData({
    required String identityId,
    required String w3cCredentialJson,
    required String issuerName,
    required DateTime issuedAt,
    required DateTime expiresAt,
    required String holderDid,
  }) = _CredentialData;
}
