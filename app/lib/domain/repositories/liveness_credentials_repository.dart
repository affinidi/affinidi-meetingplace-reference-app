import '../models/credentials/liveness_credential_record.dart';

/// Persistence for liveness credential metadata, keyed by identity.
abstract interface class LivenessCredentialsRepository {
  /// Returns all stored liveness credential records.
  Future<List<LivenessCredentialRecord>> list();

  /// Inserts or replaces the record for the given identity.
  Future<void> upsert(LivenessCredentialRecord record);

  /// Removes the record for [identityId], if present.
  Future<void> delete(String identityId);
}
