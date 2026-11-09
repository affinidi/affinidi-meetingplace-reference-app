import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../domain/models/vtc/vtc_group_chat.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'vtc_groups_state.dart';

part 'vtc_groups_controller.g.dart';

const _logKey = 'VtcGroupsController';

/// The member's groups in the community [communityDid], each with its chat:
/// created by a manager, found through the link the community publishes,
/// and joined with the group's credential. Only a failure's code is
/// logged; never a group, a member or a DID.
@riverpod
class VtcGroupsController extends _$VtcGroupsController {
  late final VtcService _vtc = ref.read(vtcServiceProvider);
  late final VtcGroupChatService _chats = ref.read(vtcGroupChatServiceProvider);

  @override
  VtcGroupsState build(String communityDid) {
    Future.microtask(refresh);
    return const VtcGroupsState();
  }

  /// Reads the member's groups again, picks up any credential they issued,
  /// and finds each one's chat.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, failure: null);
    final List<VtcGroupListing> groups;
    try {
      groups = await _vtc.memberGroups(communityDid);
    } on VtaNotLinkedException {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        failure: VtcGroupsFailure.vtaMissing,
      );
      return;
    } on NotACommunityMemberException {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        failure: VtcGroupsFailure.notAMember,
      );
      return;
    } on MeetingPlaceVtcSDKException catch (error) {
      _log('reading groups', error.code.name);
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        failure: VtcGroupsFailure.unreachable,
      );
      return;
    }
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: false, groups: groups);

    try {
      await _vtc.collectGroupCredentials(
        communityDid,
        groupDids: {for (final listing in groups) listing.group.groupDid},
      );
    } on MeetingPlaceVtcSDKException catch (error) {
      _log('collecting group credentials', error.code.name);
    }
    final credentialsUntil = <String, DateTime>{};
    for (final listing in groups) {
      try {
        if (await _vtc.groupCredentialValidUntil(
              communityDid,
              groupDid: listing.group.groupDid,
            )
            case final until?) {
          credentialsUntil[listing.group.groupId] = until;
        }
      } on MeetingPlaceVtcSDKException catch (error) {
        _log('reading a group credential', error.code.name);
      }
    }
    final chats = await _chats.chats();
    final statuses = <String, VtcGroupChatStatus>{};
    for (final listing in groups) {
      final group = listing.group;
      final chat = chats
          .where((chat) => chat.groupDid == group.groupDid)
          .firstOrNull;
      statuses[group.groupId] = switch (chat) {
        VtcGroupChat(isOwner: true) => VtcGroupChatStatus.owned,
        VtcGroupChat() => VtcGroupChatStatus.joined,
        null => await _linkStatus(group.groupDid),
      };
    }
    if (!ref.mounted) return;
    state = state.copyWith(chats: statuses, credentialsUntil: credentialsUntil);
  }

  /// Creates the chat of [group] as the member's current identity, where
  /// [posting] may post.
  Future<void> createChat(
    VtcGroup group, {
    GroupChatPosting posting = GroupChatPosting.everyone,
  }) => _act(group, (identity) async {
    final link = await _chats.createChat(
      communityDid,
      group,
      identity: identity,
      posting: posting,
    );
    if (!ref.mounted) return;
    state = state.copyWith(
      createdLink: link,
      createdForGroupDid: group.groupDid,
      chats: {...state.chats, group.groupId: VtcGroupChatStatus.owned},
    );
  });

  /// Asks to join the chat of [group] as the member's current identity.
  Future<void> joinChat(VtcGroup group) => _act(group, (identity) async {
    await _chats.joinChat(communityDid, group, identity: identity);
    if (!ref.mounted) return;
    state = state.copyWith(
      chats: {...state.chats, group.groupId: VtcGroupChatStatus.joined},
    );
  });

  /// Forgets the link shown for the chat just created.
  void dismissCreatedLink() {
    state = state.copyWith(createdLink: null, createdForGroupDid: null);
  }

  Future<void> _act(
    VtcGroup group,
    Future<void> Function(Identity identity) action,
  ) async {
    final identity = ref.read(
      identitiesServiceProvider.currentIdentityOrPrimary,
    );
    if (identity == null || state.busy.contains(group.groupId)) return;
    state = state.copyWith(
      busy: {...state.busy, group.groupId},
      chatFailure: null,
      actionFailed: false,
    );
    try {
      await action(identity);
    } on VtcGroupChatException catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(chatFailure: error.failure);
    } on Exception catch (error) {
      _log('acting on a group chat', error.runtimeType);
      if (!ref.mounted) return;
      state = state.copyWith(actionFailed: true);
    } finally {
      if (ref.mounted) {
        state = state.copyWith(busy: {...state.busy}..remove(group.groupId));
      }
    }
  }

  Future<VtcGroupChatStatus> _linkStatus(String groupDid) async {
    try {
      return await _vtc.groupChatLink(groupDid) == null
          ? VtcGroupChatStatus.none
          : VtcGroupChatStatus.linked;
    } on Exception catch (error) {
      _log('resolving a group', error.runtimeType);
      return VtcGroupChatStatus.unknown;
    }
  }

  void _log(String action, Object code) => ref
      .read(appLoggerProvider)
      .warning('Failed $action: $code', name: _logKey);
}
