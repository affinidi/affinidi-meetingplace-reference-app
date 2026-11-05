import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_group_chat_service/vtc_group_chat_service.dart';

part 'vtc_groups_state.freezed.dart';

/// Where a community group's chat stands for the member.
enum VtcGroupChatStatus {
  /// Not known yet, or the group's DID could not be resolved.
  unknown,

  /// The group has no chat linked.
  none,

  /// The community linked a chat the member can ask to join.
  linked,

  /// The member owns the group's chat.
  owned,

  /// The member asked to join, or is in, the group's chat.
  joined,
}

/// Why the member's groups could not be shown.
enum VtcGroupsFailure {
  /// No VTA is linked, so the member's identity cannot ask.
  vtaMissing,

  /// The community or the VTA could not be reached.
  unreachable,
}

/// The member's groups in one community, and their chats.
@freezed
abstract class VtcGroupsState with _$VtcGroupsState {
  const factory VtcGroupsState({
    @Default(true) bool isLoading,
    @Default(<VtcGroupListing>[]) List<VtcGroupListing> groups,

    /// Each group's chat, by group id.
    @Default(<String, VtcGroupChatStatus>{})
    Map<String, VtcGroupChatStatus> chats,

    /// Groups with an action under way, by id.
    @Default(<String>{}) Set<String> busy,

    /// The link to publish for the chat just created, and its group's DID.
    GroupChatLink? createdLink,
    String? createdForGroupDid,
    VtcGroupsFailure? failure,

    /// Why the last create or join did not go ahead.
    VtcGroupChatFailure? chatFailure,

    /// Whether the last create or join failed for another reason.
    @Default(false) bool actionFailed,
  }) = _VtcGroupsState;
}
