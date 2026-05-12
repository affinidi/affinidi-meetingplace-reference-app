import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/vrc/vrc_credential.dart';
import '../../../../domain/repositories/vrc_repository.dart';
import 'vrc_database.dart';

Future<VrcRepository> vrcRepositoryDrift(Ref ref) async {
  final database = await ref.read(vrcDatabaseProvider.future);
  return VrcRepositoryDrift(database: database);
}

Future<VrcRepository> vrcRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(vrcInMemoryDatabaseProvider.future);
  return VrcRepositoryDrift(database: database);
}

class VrcRepositoryDrift implements VrcRepository {
  VrcRepositoryDrift({required VrcDatabase database}) : _database = database;

  final VrcDatabase _database;

  @override
  Future<void> saveVrc(VrcCredential vrc) async {
    final record = VrcTableCompanion.insert(
      id: vrc.id,
      vc: vrc.vc,
      channelId: vrc.channelId,
      holderIdentityDid: vrc.holderIdentityDid,
      issuerIdentityDid: vrc.issuerIdentityDid,
      issuedAt: vrc.issuedAt,
      verifiedAt: Value(vrc.verifiedAt),
    );
    await _database
        .into(_database.vrcTable)
        .insert(record, mode: InsertMode.insertOrReplace);
  }

  @override
  Future<List<VrcCredential>> listVrcs() async {
    final rows = await _database.select(_database.vrcTable).get();
    return rows.map(_rowToCredential).toList();
  }

  @override
  Future<void> deleteVrc(String id) async {
    await (_database.delete(
      _database.vrcTable,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<VrcCredential>> listVrcsByDid(String did) async {
    final rows = await (_database.select(
      _database.vrcTable,
    )..where((t) => t.holderIdentityDid.equals(did))).get();
    return rows.map(_rowToCredential).toList();
  }

  @override
  Future<int> countVrcsByDid(String did) async {
    final countExp = _database.vrcTable.id.count();
    final query = _database.selectOnly(_database.vrcTable)
      ..addColumns([countExp])
      ..where(_database.vrcTable.holderIdentityDid.equals(did));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  VrcCredential _rowToCredential(VrcRow row) => VrcCredential(
    id: row.id,
    vc: row.vc,
    channelId: row.channelId,
    holderIdentityDid: row.holderIdentityDid,
    issuerIdentityDid: row.issuerIdentityDid,
    issuedAt: row.issuedAt,
    verifiedAt: row.verifiedAt,
  );
}
