import '../../domain/models/contacts/contact.dart';
import '../../domain/models/contacts/contact_status.dart';

extension ContactsList on List<Contact> {
  int get badgeCount {
    // Count contacts with PendingApproval status
    final pendingApprovalCount =
        where((contact) => contact.status == ContactStatus.pendingApproval)
            .length;

    // Count contacts with Approved status and all seqNo/badgeCount == 0
    final approvedZeroBadgeCount = where(
      (contact) =>
          (contact.status == ContactStatus.approved ||
              contact.status == ContactStatus.active) &&
          contact.badgeCount == 0 &&
          contact.currentMessageSeqNo == 0,
    ).length;

    // Sum all badgeCount values
    final totalBadgeCount =
        map((contact) => contact.badgeCount).fold<int>(0, (a, b) => a + b);

    return pendingApprovalCount + approvedZeroBadgeCount + totalBadgeCount;
  }
}
