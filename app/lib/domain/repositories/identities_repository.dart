import '../models/identity/identity.dart';

/// IdentitiesRepository
///
/// Provides persistence operations for Identity entities.
///
/// Methods:
/// - `listIdentities()` - List all persisted identities.
/// - `addIdentity(identity)` - Persist a new identity and return the stored
///   instance.
/// - `updateIdentity(identity)` - Update an existing identity.
/// - `deleteIdentity(id)` - Remove an identity by id.
abstract interface class IdentitiesRepository {
  /// Retrieve all persisted identities.
  ///
  /// Returns:
  /// - `Future<List<Identity>>` that completes with the list of stored
  ///  identities.
  Future<List<Identity>> listIdentities();

  /// Persist a new identity.
  ///
  /// [identity] - The Identity to add.
  ///
  /// Returns:
  /// - `Future<Identity>` that completes with the stored identity
  Future<Identity> addIdentity(Identity identity);

  /// Update an existing identity in storage.
  ///
  /// [identity] - The identity with updated fields.
  Future<void> updateIdentity(Identity identity);

  /// Delete an identity by id.
  ///
  /// [id] - Identifier of the identity to remove.
  ///
  /// Returns:
  /// - `Future<void>` completes when deletion finishes.
  Future<void> deleteIdentity(String id);
}
