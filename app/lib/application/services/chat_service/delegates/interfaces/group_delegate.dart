import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../../../domain/models/contacts/contact.dart';

/// Interface for handling group-related operations within the chat service.
abstract class GroupDelegate {
  Future<Group?> refreshGroup(String groupId);
  Future<void> updateGroupContactPendingStatus(Contact contact, Group group);
}
