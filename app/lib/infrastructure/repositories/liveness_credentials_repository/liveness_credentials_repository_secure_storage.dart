import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/credentials/liveness_credential_record.dart';
import '../../../domain/repositories/liveness_credentials_repository.dart';
import '../../secure_storage/secure_storage.dart';

/// Secure-storage implementation of [LivenessCredentialsRepository].
Future<LivenessCredentialsRepository>
livenessCredentialsRepositorySecureStorage(Ref ref) async {
  final storage = await ref.read(secureStorageProvider.future);
  return LivenessCredentialsRepositorySecureStorage(storage);
}

class LivenessCredentialsRepositorySecureStorage
    implements LivenessCredentialsRepository {
  LivenessCredentialsRepositorySecureStorage(this._storage);

  final SecureStorage _storage;

  @override
  Future<List<LivenessCredentialRecord>> list() async {
    final raw = await _storage.readLivenessCredentials();
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (e) => LivenessCredentialRecord.fromJson(e as Map<String, Object?>),
        )
        .toList();
  }

  @override
  Future<void> upsert(LivenessCredentialRecord record) async {
    final records = await list();
    final updated = [
      ...records.where((r) => r.identityId != record.identityId),
      record,
    ];
    await _saveAll(updated);
  }

  @override
  Future<void> delete(String identityId) async {
    final records = await list();
    await _saveAll(records.where((r) => r.identityId != identityId).toList());
  }

  Future<void> _saveAll(List<LivenessCredentialRecord> records) async {
    if (records.isEmpty) {
      await _storage.clearLivenessCredentials();
      return;
    }
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await _storage.writeLivenessCredentials(encoded);
  }
}
