import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import '../../../../domain/repositories/r_card_repository.dart';
import '../../../helpers/canonical_json.dart';
import 'r_cards_database.dart' as db;

String _safeCanonical(String json) {
  try {
    return canonicalizeJsonString(json);
  } catch (_) {
    return json;
  }
}

/// Returns an [RCardRepository] backed by an encrypted on-device Drift
/// database.
Future<RCardRepository> rCardsRepositoryDrift(Ref ref) async {
  final database = await ref.read(db.rCardsDatabaseProvider.future);
  return RCardsRepositoryDrift(database: database);
}

/// Returns an [RCardRepository] backed by an in-memory Drift database.
///
/// Intended for tests and Storybook-style previews only.
Future<RCardRepository> rCardsRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(db.rCardsInMemoryDatabaseProvider.future);
  return RCardsRepositoryDrift(database: database);
}

/// Drift implementation of [RCardRepository].
///
/// - Persists R-Cards in the local [db.RCardsDatabase].
/// - [upsertFromVdip] compares canonical JSON representations to avoid
///   redundant writes.
class RCardsRepositoryDrift implements RCardRepository {
  RCardsRepositoryDrift({required db.RCardsDatabase database})
    : _database = database;

  final db.RCardsDatabase _database;

  @override
  Future<void> upsertFromVdip({
    required String subjectDid,
    required String issuerDid,
    required String vcBlob,
    required DateTime issuanceDate,
    required String? threadId,
    required String? contactChannelDid,
    required DateTime receivedAt,
  }) async {
    await _database.transaction(() async {
      final existing = await (_database.select(
        _database.rCards,
      )..where((t) => t.subjectDid.equals(subjectDid))).getSingleOrNull();

      final newCanonical = _safeCanonical(vcBlob);
      final existingCanonical = existing == null
          ? null
          : _safeCanonical(existing.vcBlob);

      if (existing != null && existingCanonical == newCanonical) {
        return;
      }

      if (existing == null) {
        await _database
            .into(_database.rCards)
            .insert(
              db.RCardsCompanion(
                subjectDid: Value(subjectDid),
                issuerDid: Value(issuerDid),
                vcBlob: Value(vcBlob),
                issuanceDate: Value(issuanceDate),
                receivedAt: Value(receivedAt),
                threadId: Value(threadId),
                contactChannelDid: Value(contactChannelDid),
              ),
            );
        return;
      }

      await (_database.update(
        _database.rCards,
      )..where((t) => t.subjectDid.equals(subjectDid))).write(
        db.RCardsCompanion(
          issuerDid: Value(issuerDid),
          vcBlob: Value(vcBlob),
          issuanceDate: Value(issuanceDate),
          receivedAt: Value(receivedAt),
          threadId: Value(threadId),
          contactChannelDid: Value(contactChannelDid),
          version: Value(existing.version + 1),
          notes: Value(existing.notes),
        ),
      );
    });
  }

  @override
  Stream<List<ReceivedRCard>> watchAll() {
    return (_database.select(_database.rCards)
          ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
        .watch()
        .map((rows) => rows.map(_mapRow).toList());
  }

  @override
  Future<List<ReceivedRCard>> listAll() async {
    final rows = await (_database.select(
      _database.rCards,
    )..orderBy([(t) => OrderingTerm.desc(t.receivedAt)])).get();
    return rows.map(_mapRow).toList();
  }

  @override
  Future<ReceivedRCard?> getBySubjectDid(String subjectDid) async {
    final row = await (_database.select(
      _database.rCards,
    )..where((t) => t.subjectDid.equals(subjectDid))).getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  @override
  Future<void> updateNotes(String subjectDid, String? notes) async {
    await (_database.update(
      _database.rCards,
    )..where((t) => t.subjectDid.equals(subjectDid))).write(
      db.RCardsCompanion(
        notes: Value(notes?.trim().isEmpty == true ? null : notes),
      ),
    );
  }

  @override
  Future<void> deleteBySubjectDid(String subjectDid) async {
    await (_database.delete(
      _database.rCards,
    )..where((t) => t.subjectDid.equals(subjectDid))).go();
  }

  ReceivedRCard _mapRow(db.RCardRow row) {
    return ReceivedRCard(
      subjectDid: row.subjectDid,
      vcBlob: row.vcBlob,
      issuerDid: row.issuerDid,
      version: row.version,
      issuanceDate: row.issuanceDate,
      receivedAt: row.receivedAt,
      notes: row.notes,
      threadId: row.threadId,
      contactChannelDid: row.contactChannelDid,
    );
  }
}
