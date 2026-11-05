import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/identity/identity.dart';
import '../../../domain/models/vtc/vtc_group_chat.dart';
import '../../../domain/repositories/vtc_repository.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import '../connections_service/connections_service.dart';
import '../connections_service/publish_offer_params.dart';
import '../vtc_service/vtc_service.dart';

/// Why a community group chat could not be created or joined.
enum VtcGroupChatFailure {
  /// Only a manager of the group can create its chat.
  notAManager,

  /// The group hides its members from one another, as a chat cannot.
  hidesMembers,

  /// The community already linked a chat to the group.
  alreadyLinked,

  /// The community has not linked a chat to the group yet.
  notLinked,

  /// The linked chat is on another Meeting Place than this app's.
  otherMeetingPlace,

  /// The linked offer is not this group's chat, or is gone.
  notTheGroupsChat,

  /// The member's VTA keeps no credential of the group yet.
  noGroupCredential,
}

/// A community group chat that could not be created or joined.
class VtcGroupChatException implements Exception {
  /// Creates a [VtcGroupChatException].
  const VtcGroupChatException(this.failure);

  /// Why.
  final VtcGroupChatFailure failure;

  @override
  String toString() => 'VtcGroupChatException(${failure.name})';
}

/// Group chats that follow community groups: created by a group's manager
/// under the group's DID, joined by its members with the group's
/// credential, and kept in step with the group by the owner's phone.
///
/// The chat's owner lets a member in only when the group's credential they
/// present holds and the community still lists them as an active member,
/// removes them when the community no longer does, and makes the group's
/// managers the chat's moderators. A chat is found through the link the
/// community publishes in the group's DID document, never through a link a
/// chat makes for itself.
///
/// Never logs a DID, a credential or a member.
class VtcGroupChatService {
  /// Creates a [VtcGroupChatService].
  VtcGroupChatService(this._ref, {VtcRepository? repository})
    : _repository = repository ?? SecureStorageVtcRepository();

  static const _logKey = 'VtcGroupChatService';

  final Ref _ref;
  final VtcRepository _repository;
  StreamSubscription<ChannelAttachmentEvent>? _joinRequests;

  VtcService get _vtc => _ref.read(vtcServiceProvider);

  AppLogger get _logger => _ref.read(appLoggerProvider);

  /// Every chat this phone owns or joined that follows a community group.
  Future<List<VtcGroupChat>> chats() => _repository.groupChats();

  /// Creates the chat of the group [group] of [communityDid] as [identity],
  /// known by the group's DID, and returns the link the community must
  /// publish for members to find it.
  ///
  /// Throws [VtcGroupChatException] when the member does not manage the
  /// group, the group hides its members, or the community already linked a
  /// chat; [MeetingPlaceVtcSDKException] when the VTA or the community
  /// cannot be reached; and the Meeting Place error when publishing fails,
  /// such as when the group's chat exists already.
  Future<GroupChatLink> createChat(
    String communityDid,
    VtcGroup group, {
    required Identity identity,
  }) async {
    final current = (await _vtc.communityGroup(
      communityDid,
      groupId: group.groupId,
    )).group;
    if (!current.isManagedByCaller) {
      throw const VtcGroupChatException(VtcGroupChatFailure.notAManager);
    }
    if (!current.showsMembersToMembers) {
      throw const VtcGroupChatException(VtcGroupChatFailure.hidesMembers);
    }
    if (await _vtc.groupChatLink(current.groupDid) != null) {
      throw const VtcGroupChatException(VtcGroupChatFailure.alreadyLinked);
    }

    final environment = _ref.read(environmentProvider);
    final connections = _ref.read(connectionsServiceProvider.notifier);
    // Who may join is the credential's to decide, not the phrase's: the
    // offer neither expires nor runs out, so the link stays true.
    await connections.publishOffer(
      PublishOfferParams(
        headline: current.name,
        description: current.description ?? '',
        isGroupOffer: true,
        selectedMediatorDid: environment.defaultMediatorDid,
        transport: ChannelTransport.matrix,
        groupDid: current.groupDid,
      ),
      identity: identity,
    );
    final offer =
        _ref.read(connectionsServiceProvider).publishedOffer
            as GroupConnectionOffer;
    await _repository.saveGroupChat(
      VtcGroupChat(
        chatGroupId: offer.groupId,
        communityDid: communityDid,
        groupId: current.groupId,
        groupDid: current.groupDid,
        name: current.name,
        isOwner: true,
      ),
    );
    return GroupChatLink(
      mnemonic: offer.mnemonic,
      controlPlaneDid: environment.controlPlaneDid,
    );
  }

  /// Asks to join the chat of the group [group] of [communityDid] as
  /// [identity], proving membership with the group's credential.
  ///
  /// Throws [VtcGroupChatException] when the community linked no chat, the
  /// linked offer is not the group's chat on this app's Meeting Place, or
  /// the member's VTA keeps no credential of the group;
  /// [MeetingPlaceVtcSDKException] when the VTA or the community cannot be
  /// reached; and the Meeting Place error when accepting fails.
  Future<void> joinChat(
    String communityDid,
    VtcGroup group, {
    required Identity identity,
  }) async {
    // The community delivers the credential once; pick it up if waiting.
    try {
      await _vtc.collectGroupCredentials(
        communityDid,
        groupDids: {group.groupDid},
      );
    } on MeetingPlaceVtcSDKException catch (error) {
      _logFailure('collecting group credentials', error.code.name);
    }
    if (!await _vtc.holdsGroupCredential(
      communityDid,
      groupDid: group.groupDid,
    )) {
      throw const VtcGroupChatException(VtcGroupChatFailure.noGroupCredential);
    }

    final link = await _vtc.groupChatLink(group.groupDid);
    if (link == null) {
      throw const VtcGroupChatException(VtcGroupChatFailure.notLinked);
    }
    if (link.controlPlaneDid !=
        _ref.read(environmentProvider).controlPlaneDid) {
      throw const VtcGroupChatException(VtcGroupChatFailure.otherMeetingPlace);
    }
    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    final offer = (await sdk.findOffer(
      mnemonic: link.mnemonic,
    )).connectionOffer;
    // Only an offer for the group's own DID is the group's chat.
    if (offer is! GroupConnectionOffer || offer.groupDid != group.groupDid) {
      throw const VtcGroupChatException(VtcGroupChatFailure.notTheGroupsChat);
    }

    await _ref
        .read(connectionsServiceProvider.notifier)
        .acceptOffer(
          offer,
          identity: identity,
          buildGroupJoinAttachments: (memberDid) async {
            final proof = await _vtc.proveGroupMembership(
              communityDid,
              groupDid: group.groupDid,
              memberDid: memberDid,
            );
            if (proof == null) {
              throw const VtcGroupChatException(
                VtcGroupChatFailure.noGroupCredential,
              );
            }
            return proof.toAttachments();
          },
        );
    await _repository.saveGroupChat(
      VtcGroupChat(
        chatGroupId: offer.groupId,
        communityDid: communityDid,
        groupId: group.groupId,
        groupDid: group.groupDid,
        name: group.name,
        isOwner: false,
      ),
    );
  }

  /// Starts deciding requests to join the chats this phone owns as they
  /// arrive. Idempotent.
  Future<void> start() async {
    if (_joinRequests != null) return;
    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    _joinRequests = sdk.channelAttachments.listen(
      (event) => unawaited(
        decideJoinRequest(event.channel, event.attachments).catchError(
          (Object error) =>
              _logFailure('deciding a join request', error.runtimeType),
        ),
      ),
    );
  }

  /// Stops deciding requests to join.
  Future<void> stop() async {
    await _joinRequests?.cancel();
    _joinRequests = null;
  }

  /// Lets the requester of [channel] into the community group chat it asks
  /// to join when [attachments] prove them a member of the group and the
  /// community still lists them as one, and refuses them otherwise.
  ///
  /// Leaves the request waiting when the community or the VTA cannot be
  /// reached, to be decided again. Ignores requests to other chats.
  Future<void> decideJoinRequest(
    Channel channel,
    List<Attachment> attachments,
  ) async {
    final memberDid = channel.otherPartyPermanentChannelDid;
    if (!channel.isGroup ||
        channel.status != ChannelStatus.waitingForApproval ||
        memberDid == null) {
      return;
    }
    final chat = (await _repository.groupChats())
        .where(
          (chat) =>
              chat.isOwner && chat.groupDid == channel.permanentChannelDid,
        )
        .firstOrNull;
    if (chat == null) return;

    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    final proof = GroupJoinProof.fromAttachments(attachments);
    if (proof == null) {
      await sdk.rejectConnectionRequest(channel: channel);
      return;
    }
    final GroupAdmission admission;
    try {
      admission = await _vtc.verifyGroupJoin(
        proof,
        communityDid: chat.communityDid,
        groupDid: chat.groupDid,
        memberDid: memberDid,
      );
    } on GroupAdmissionException catch (error) {
      if (error.reason == GroupAdmissionRefusal.authorityStatusUnknown) {
        _logFailure('checking a join request', error.reason.name);
        return;
      }
      await sdk.rejectConnectionRequest(channel: channel);
      return;
    }

    final List<VtcGroupMember> members;
    final VtcGroup group;
    try {
      members = await _vtc.groupMembers(
        chat.communityDid,
        groupId: chat.groupId,
      );
      group = (await _vtc.communityGroup(
        chat.communityDid,
        groupId: chat.groupId,
      )).group;
    } on MeetingPlaceVtcSDKException catch (error) {
      _logFailure('confirming a membership', error.code.name);
      return;
    }
    final entryId = members
        .where(
          (member) =>
              member.isActive && member.credentialId == admission.credentialId,
        )
        .firstOrNull
        ?.entryId;
    if (entryId == null) {
      await sdk.rejectConnectionRequest(channel: channel);
      return;
    }

    await sdk.approveConnectionRequest(
      ApproveConnectionRequestParams(channel: channel),
    );
    final isManager = group.managers?.contains(entryId) ?? false;
    if (isManager) {
      await _setModerator(sdk, chat, memberDid, isModerator: true);
    }
    await _repository.saveGroupChat(
      chat.copyWith(
        members: {...chat.members, memberDid: entryId},
        moderators: isManager ? {...chat.moderators, memberDid} : null,
      ),
    );
  }

  /// Brings every chat this phone owns in step with its group: removes
  /// those the community no longer lists as active members, and makes the
  /// group's managers, and only them, moderators.
  ///
  /// A chat whose group cannot be read now is left as it is.
  Future<void> syncChats() async {
    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    for (final chat in await _repository.groupChats()) {
      if (!chat.isOwner || chat.members.isEmpty) continue;
      try {
        await _sync(sdk, chat);
      } on MeetingPlaceVtcSDKException catch (error) {
        _logFailure('reading a group', error.code.name);
      }
    }
  }

  Future<void> _sync(MeetingPlaceCoreSDK sdk, VtcGroupChat chat) async {
    final active = {
      for (final member in await _vtc.groupMembers(
        chat.communityDid,
        groupId: chat.groupId,
      ))
        if (member.isActive) member.entryId,
    };
    final managers = {
      ...?(await _vtc.communityGroup(
        chat.communityDid,
        groupId: chat.groupId,
      )).group.managers,
    };

    final members = {...chat.members};
    final moderators = {...chat.moderators};
    for (final MapEntry(key: memberDid, value: entryId)
        in chat.members.entries) {
      if (!active.contains(entryId)) {
        await sdk.removeMemberFromGroup(
          RemoveMemberFromGroupRequest(
            groupId: chat.chatGroupId,
            memberDid: memberDid,
          ),
        );
        members.remove(memberDid);
        moderators.remove(memberDid);
        continue;
      }
      final isManager = managers.contains(entryId);
      if (isManager != moderators.contains(memberDid)) {
        await _setModerator(sdk, chat, memberDid, isModerator: isManager);
        isManager ? moderators.add(memberDid) : moderators.remove(memberDid);
      }
    }
    await _repository.saveGroupChat(
      chat.copyWith(members: members, moderators: moderators),
    );
  }

  Future<void> _setModerator(
    MeetingPlaceCoreSDK sdk,
    VtcGroupChat chat,
    String memberDid, {
    required bool isModerator,
  }) => sdk.setGroupModerator(
    SetGroupModeratorRequest(
      groupId: chat.chatGroupId,
      memberDid: memberDid,
      isModerator: isModerator,
    ),
  );

  void _logFailure(String action, Object code) =>
      _logger.warning('Failed $action: $code', name: _logKey);
}

/// The app's [VtcGroupChatService].
final vtcGroupChatServiceProvider = Provider<VtcGroupChatService>(
  VtcGroupChatService.new,
  name: 'vtcGroupChatServiceProvider',
);
