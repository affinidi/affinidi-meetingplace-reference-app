import '../../domain/models/contacts/contact.dart';
import '../../domain/models/contacts/contact_status.dart';
import 'contact_newness_extensions.dart';

extension ContactsList on List<Contact> {
  int get badgeCount {
    final pendingApprovalCount = where(
      (contact) => contact.status == ContactStatus.pendingApproval,
    ).length;

    final newUnopenedChannelCount = where(
      (contact) => contact.isNewUnopenedChannel,
    ).length;

    final totalBadgeCount = map(
      (contact) => contact.badgeCount,
    ).fold<int>(0, (a, b) => a + b);

    return pendingApprovalCount + newUnopenedChannelCount + totalBadgeCount;
  }
}
