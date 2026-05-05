import 'package:meeting_place_relationship/meeting_place_relationship.dart';

/// Persistence interface for received R-Cards.
///
/// Provides CRUD and stream-based access to [ReceivedRCard] entries stored
/// locally. All writes are idempotent: [upsertFromVdip] is a no-op when the
/// incoming VC blob matches the stored one.
abstract interface class RCardRepository {
  /// Inserts or updates the R-Card identified by [subjectDid].
  ///
  /// - Inserts a new row if none exists for [subjectDid].
  /// - Updates the row and increments [ReceivedRCard.version] if the VC blob
  ///   has changed.
  /// - Is a no-op when the canonicalized blob matches the stored copy.
  Future<void> upsertFromVdip({
    required String subjectDid,
    required String issuerDid,
    required String vcBlob,
    required DateTime issuanceDate,
    required String? threadId,
    required String? contactChannelDid,
    required DateTime receivedAt,
  });

  /// Returns a live stream of all stored R-Cards, ordered by
  /// `ReceivedRCard.receivedAt` descending.
  Stream<List<ReceivedRCard>> watchAll();

  /// Returns a snapshot of all stored R-Cards, ordered by
  /// `ReceivedRCard.receivedAt` descending.
  Future<List<ReceivedRCard>> listAll();

  /// Returns the R-Card for the given [subjectDid], or `null` if not found.
  Future<ReceivedRCard?> getBySubjectDid(String subjectDid);

  /// Persists user-written [notes] for the R-Card identified by [subjectDid].
  ///
  /// Pass `null` or an empty string to clear the notes.
  Future<void> updateNotes(String subjectDid, String? notes);

  /// Permanently deletes the R-Card identified by [subjectDid].
  Future<void> deleteBySubjectDid(String subjectDid);
}
