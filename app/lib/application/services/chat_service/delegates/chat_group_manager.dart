import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../../domain/models/contacts/contact.dart';
import '../../../../domain/models/contacts/contact_status.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../contacts_service/contacts_service.dart';
import 'interfaces/group_managing.dart';

/// Handles group management SDK and contacts interactions.
class ChatGroupManager implements GroupManaging {
  ChatGroupManager({required this._ref});

  final Ref _ref;

  @override
  Future<Group?> refreshGroup(String groupId) async {
    final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
    return coreSdk.getGroupById(groupId);
  }

  @override
  Future<void> updateGroupContactPendingStatus(
    Contact contact,
    Group group,
  ) async {
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

  @override
  Future<void> removeMember({
    required String groupId,
    required String memberDid,
  }) async {
    final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
    await coreSdk.removeMemberFromGroup(groupId: groupId, memberDid: memberDid);
  }
}
