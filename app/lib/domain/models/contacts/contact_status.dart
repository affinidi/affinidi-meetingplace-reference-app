/// Represents the various states a contact can have in the system.
///
/// This enum defines the possible status values that can be assigned to a
/// contact, allowing the application to track and manage different contact
/// states throughout their lifecycle.
enum ContactStatus {
  pendingApproval(1),
  pendingInauguration(2),
  approved(3),
  rejected(4),
  error(5),
  deleted(6),
  unknown(0),
  active(7);

  const ContactStatus(this.value);

  final int value;
}
