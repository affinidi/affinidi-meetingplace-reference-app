import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../../domain/models/contacts/contact.dart';
import '../../../../domain/models/contacts/contact_status.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../contacts_service/contacts_service.dart';
import 'interfaces/group_delegate.dart';

/// Encapsulates all group-related SDK interactions.
class AppGroupDelegate implements GroupDelegate {
  AppGroupDelegate({required Ref ref}) : _ref = ref;

  final Ref _ref;

  @override
  Future<Group?> refreshGroup(String groupId) async {
    final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
    return coreSdk.getGroupById(groupId);
  }

  @override
  Future<void> updateGroupContactPendingStatus(
    Contact contact,
    Group? group,
  ) async {
    if (group == null) return;

    final moreMembersPendingApproval = group.members.any(
      (m) => m.status == GroupMemberStatus.pendingApproval,
    );

    await _ref
        .read(contactsServiceProvider.notifier)
        .updateContact(
          contact.copyWith(
            status: moreMembersPendingApproval
                ? ContactStatus.pendingApproval
                : ContactStatus.active,
          ),
        );
  }
}
