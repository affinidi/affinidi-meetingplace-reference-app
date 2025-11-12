import '../models/contacts/contact.dart';

/// ContactsRepository
///
/// Provides persistence operations for Contact entities.
///
/// Methods:
/// - `listContacts()` - List all persisted contacts.
/// - `addContact(contact)` - Persist a contact and return the stored
///   instance.
/// - `deleteContact(contact)` - Remove a contact.
/// - `updateContact(contact)` - Update an existing contact.
abstract interface class ContactsRepository {
  /// Retrieve all persisted contacts.
  ///
  /// Returns:
  /// - `Future<List<Contact>>` that completes with the list of stored contacts.
  Future<List<Contact>> listContacts();

  /// Persist a new contact.
  ///
  /// [contact] - The Contact to add.
  ///
  /// Returns:
  /// - `Future<Contact>` that completes with the stored contact.
  Future<Contact> addContact(Contact contact);

  /// Delete a contact from storage.
  ///
  /// [contact] - The contact to remove.
  ///
  /// Returns:
  /// - `Future<void>` completes when deletion finishes.
  Future<void> deleteContact(Contact contact);

  /// Update an existing contact in storage.
  ///
  /// [contact] - The contact with updated fields.
  ///
  /// Returns:
  /// - `Future<void>` completes when the update finishes.
  Future<void> updateContact(Contact contact);
}
