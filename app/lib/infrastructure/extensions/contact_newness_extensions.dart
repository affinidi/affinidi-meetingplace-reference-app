import '../../domain/models/contacts/contact.dart';
import '../../domain/models/contacts/contact_status.dart';

extension ContactNewnessExtensions on Contact {
  bool get isNewUnopenedChannel {
    final isActiveOrApproved =
        status == ContactStatus.active || status == ContactStatus.approved;

    return isActiveOrApproved &&
        badgeCount == 0 &&
        currentMessageSeqNo == 0 &&
        !hasBeenOpened;
  }
}
