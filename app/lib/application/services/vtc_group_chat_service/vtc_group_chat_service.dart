import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../domain/models/identity/identity.dart';
import '../../../domain/models/vtc/vtc_chat_posting.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/models/vtc/vtc_group_chat.dart';
import '../../../domain/repositories/vtc_repository.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/extensions/vtc_exception_extensions.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';
import '../connections_service/connections_service.dart';
import '../connections_service/publish_offer_params.dart';
import '../identities_service/identities_service.dart';
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

  /// The identity that is the member of the community is not on this
  /// phone, so no other identity may act for it in the group's chat.
  memberNotHere,
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
/// chat makes for itself; the link also says who may post. A member joins
/// the chat of each group they are in on their own, once.
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
  Future<void>? _joining;

  /// Requests to join a chat this phone owns that could not be decided yet,
  /// such as while the community was unreachable, by the requester's DID.
  /// Meeting Place hands a request's proof over once, so it is kept here to
  /// decide again at the next sync.
  final _undecided = <String, ChannelAttachmentEvent>{};

  /// Joins under way, by the group's DID.
  final _joiningChats = <String, Future<void>>{};

  final _chatsChanged = StreamController<void>.broadcast();

  /// Fires when this phone records a chat it created or joined, so lists of
  /// a community's channels read them again: the chat's contact can be made
  /// before the chat is recorded.
  Stream<void> get chatsChanged => _chatsChanged.stream;

  VtcService get _vtc => _ref.read(vtcServiceProvider);

  AppLogger get _logger => _ref.read(appLoggerProvider);

  /// Every chat this phone owns or joined that follows a community group.
  Future<List<VtcGroupChat>> chats() => _repository.groupChats();

  /// Whether this phone owns the chat [chatGroupId] and it follows a
  /// community group: its members are let in by the group's credential as
  /// they ask, never approved by hand.
  Future<bool> admitsByCredential(String chatGroupId) async =>
      (await _repository.groupChats()).any(
        (chat) => chat.isOwner && chat.chatGroupId == chatGroupId,
      );

  /// The identity on this phone that is the member of [communityDid], which
  /// creates and joins the chats of its groups whichever identity is
  /// current: null when the phone holds no membership of it, or the
  /// identity is not on this phone.
  Future<Identity?> memberIdentity(String communityDid) async {
    final community = await _vtc.community(communityDid);
    if (community == null || !community.isMember) return null;
    return _identityOf(community);
  }

  /// The identity whose VTA context holds [community]'s persona: its own
  /// DID, or a persona it joined this community with alone.
  Identity? _identityOf(VtcCommunity community) => _ref
      .read(identitiesServiceProvider)
      .identities
      .where((identity) => identity.vtaContextId == community.contextId)
      .firstOrNull;

  /// Creates the chat of the group [group] of [communityDid] as [identity],
  /// known by the group's DID, where [posting] may post, and returns the link
  /// the community must publish for members to find it and to set who may
  /// post.
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
    GroupChatPosting posting = GroupChatPosting.everyone,
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
        // The control plane refuses an offer without a description, and a
        // group need not have one.
        description: switch (current.description?.trim()) {
          final description? when description.isNotEmpty => description,
          _ => current.name,
        },
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
        posting: posting,
      ),
    );
    _chatsChanged.add(null);
    return GroupChatLink(
      mnemonic: offer.mnemonic,
      controlPlaneDid: environment.controlPlaneDid,
      posting: posting,
    );
  }

  /// The link the community must publish for the chat of the group
  /// [groupDid] this phone owns, as [createChat] returned it: null when the
  /// phone owns no such chat, or Meeting Place no longer holds its offer.
  Future<GroupChatLink?> chatLink(String groupDid) async {
    final chat = (await _repository.groupChats())
        .where((chat) => chat.isOwner && chat.groupDid == groupDid)
        .firstOrNull;
    if (chat == null) return null;
    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    final group = await sdk.findGroupById(chat.chatGroupId);
    if (group == null) return null;
    final offer = await sdk.findConnectionOffer(group.offerLink);
    if (offer == null) return null;
    return GroupChatLink(
      mnemonic: offer.mnemonic,
      controlPlaneDid: _ref.read(environmentProvider).controlPlaneDid,
      posting: chat.posting,
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
  ///
  /// A join of the group's chat already under way, such as one started
  /// without asking, is waited for rather than asked again: a second request
  /// would put the member to the owner twice.
  Future<void> joinChat(
    String communityDid,
    VtcGroup group, {
    required Identity identity,
  }) => _joiningChats[group.groupDid] ??=
      _joinChat(communityDid, group, identity: identity).whenComplete(() {
        // Not the removed join itself, which whenComplete would wait for.
        _joiningChats.remove(group.groupDid);
      });

  Future<void> _joinChat(
    String communityDid,
    VtcGroup group, {
    required Identity identity,
  }) async {
    // The link first: a group without a chat yet, the common case each time
    // the member's chats are joined, asks nothing of the VTA.
    final link = await _vtc.groupChatLink(group.groupDid);
    if (link == null) {
      throw const VtcGroupChatException(VtcGroupChatFailure.notLinked);
    }
    if (link.controlPlaneDid !=
        _ref.read(environmentProvider).controlPlaneDid) {
      throw const VtcGroupChatException(VtcGroupChatFailure.otherMeetingPlace);
    }

    // The community delivers the credential once: picked up from the
    // mailbox only when the VTA does not keep it yet, as opening the
    // mailbox is slow.
    if (!await _vtc.holdsGroupCredential(
      communityDid,
      groupDid: group.groupDid,
    )) {
      await _collectCredentials(communityDid, {group.groupDid});
      if (!await _vtc.holdsGroupCredential(
        communityDid,
        groupDid: group.groupDid,
      )) {
        throw const VtcGroupChatException(
          VtcGroupChatFailure.noGroupCredential,
        );
      }
    }

    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    final offer = (await sdk.findOffer(
      mnemonic: link.mnemonic,
    )).connectionOffer;
    // The phrase comes from the group's own DID document, which only the
    // community writes, so the offer it finds is the chat the community
    // linked. The control plane names no group DID when an offer is found
    // (it arrives once the member is let in); one that names another
    // group's DID is not this group's chat.
    if (offer is! GroupConnectionOffer ||
        (offer.groupDid != null && offer.groupDid != group.groupDid)) {
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
        posting: link.posting,
      ),
    );
    _chatsChanged.add(null);
  }

  /// Joins, as the identity that is the member, the linked chat of every
  /// group the member is in, in each community they belong to: a group the
  /// community puts every member in, such as announcements, is in their
  /// chats without asking. A group's chat is joined once, so one the member
  /// left stays left. Idempotent while running.
  ///
  /// A chat that cannot be joined now, such as one not linked yet or whose
  /// credential is not delivered yet, is tried again on the next call.
  Future<void> joinGroupChats() {
    return _joining ??= _joinGroupChats().whenComplete(() => _joining = null);
  }

  Future<void> _joinGroupChats() async {
    final watch = Stopwatch()..start();
    final joined = {
      for (final chat in await _repository.groupChats()) chat.groupDid,
    };
    for (final community in await _vtc.memberships()) {
      final identity = _identityOf(community);
      if (identity == null) continue;
      final List<VtcGroupListing> listings;
      try {
        listings = await _vtc.memberGroups(community.communityDid);
      } on VtaNotLinkedException {
        return;
      } on MeetingPlaceVtcSDKException catch (error) {
        _logFailure('reading groups', error.logCode);
        continue;
      }
      _logStep('Read groups', watch);
      final candidates = [
        for (final VtcGroupListing(:group, :standing) in listings)
          if (standing == GroupStanding.member &&
              !joined.contains(group.groupDid))
            group,
      ];
      // Which have a chat linked, read all at once; then the credentials of
      // those, picked up in one visit to the mailbox, not one per group.
      final linked = [
        for (final (group, isLinked) in await Future.wait([
          for (final group in candidates)
            _vtc
                .groupChatLink(group.groupDid)
                .then((link) => (group, link != null))
                .catchError((Object _) => (group, false)),
        ]))
          if (isLinked) group,
      ];
      _logStep('Read chat links', watch);
      if (linked.isEmpty) continue;
      // The mailbox is slow to open: visited only for the credentials the
      // VTA does not keep yet.
      final missing = [
        for (final (group, holds) in await Future.wait([
          for (final group in linked)
            _vtc
                .holdsGroupCredential(
                  community.communityDid,
                  groupDid: group.groupDid,
                )
                .then((holds) => (group, holds))
                .catchError((Object _) => (group, false)),
        ]))
          if (!holds) group,
      ];
      _logStep('Read held credentials', watch);
      if (missing.isNotEmpty) {
        await _collectCredentials(community.communityDid, {
          for (final group in missing) group.groupDid,
        });
        _logStep('Collected credentials', watch);
      }
      for (final group in linked) {
        try {
          _logger.info('Joining a group chat automatically', name: _logKey);
          await joinChat(community.communityDid, group, identity: identity);
          joined.add(group.groupDid);
          _logStep('Joined a group chat automatically', watch);
        } on VtcGroupChatException catch (error) {
          // Not linked or not deliverable yet: tried again next time. The
          // reason is logged, as nothing else tells why a member is not in.
          if (error.failure != VtcGroupChatFailure.notLinked) {
            _logFailure('joining a group chat', error.failure.name);
          }
        } on Exception catch (error) {
          _logFailure('joining a group chat', error.runtimeType);
        }
      }
    }
  }

  /// Picks up the credentials of the groups [groupDids] of [communityDid]
  /// the community delivered, best effort: one not picked up now is next
  /// time.
  Future<void> _collectCredentials(
    String communityDid,
    Set<String> groupDids,
  ) async {
    try {
      await _vtc.collectGroupCredentials(communityDid, groupDids: groupDids);
    } on MeetingPlaceVtcSDKException catch (error) {
      _logFailure('collecting group credentials', error.logCode);
    }
  }

  /// Who may post in the community group chat [chatGroupId], which the
  /// member on this phone talks in as [channel]: null when everyone may, or
  /// the chat follows no community group.
  ///
  /// Throws the Meeting Place error when the chat cannot be read.
  Future<VtcChatPosting?> postingIn(
    Channel channel, {
    required String chatGroupId,
  }) async {
    final chat = (await _repository.groupChats())
        .where((chat) => chat.chatGroupId == chatGroupId)
        .firstOrNull;
    if (chat == null || chat.posting == GroupChatPosting.everyone) {
      return null;
    }
    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    return VtcChatPosting(
      posters: await sdk.groupModerators(channel),
      memberDid: channel.permanentChannelDid!,
    );
  }

  /// The offer links of the chats of [communityDid]'s groups this phone
  /// owns or joined: a contact whose offer link is among them is one of the
  /// community's channels. A chat Meeting Place no longer holds is left out.
  Future<Set<String>> chatOfferLinks(String communityDid) async {
    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    return {
      for (final chat in await _repository.groupChats())
        if (chat.communityDid == communityDid)
          if (await sdk.findGroupById(chat.chatGroupId) case final group?)
            group.offerLink,
    };
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
    final request = ChannelAttachmentEvent(
      channel: channel,
      attachments: attachments,
    );
    final bool isWaiting;
    try {
      isWaiting = await _decideJoinRequest(channel, attachments, memberDid);
    } on Exception {
      _undecided[memberDid] = request;
      rethrow;
    }
    if (isWaiting) {
      _undecided[memberDid] = request;
    } else {
      _undecided.remove(memberDid);
    }
  }

  /// Decides again the requests to join that could not be decided when they
  /// arrived, each as its channel stands now: one decided since, or gone,
  /// is forgotten.
  Future<void> _decideWaitingRequests(MeetingPlaceCoreSDK sdk) async {
    for (final MapEntry<String, ChannelAttachmentEvent>(
          key: memberDid,
          value: request,
        )
        in [..._undecided.entries]) {
      final channel = await sdk.findChannelByOtherPartyPermanentDid(memberDid);
      if (channel == null ||
          channel.status != ChannelStatus.waitingForApproval) {
        _undecided.remove(memberDid);
        continue;
      }
      try {
        await decideJoinRequest(channel, request.attachments);
      } on Exception catch (error) {
        _logFailure('deciding a join request', error.runtimeType);
      }
    }
  }

  /// Lets in or refuses the request of [memberDid], and whether it is left
  /// waiting instead: false once decided, or when it is not a request to a
  /// chat this phone owns.
  Future<bool> _decideJoinRequest(
    Channel channel,
    List<Attachment> attachments,
    String memberDid,
  ) async {
    final chat = (await _repository.groupChats())
        .where(
          (chat) =>
              chat.isOwner && chat.groupDid == channel.permanentChannelDid,
        )
        .firstOrNull;
    if (chat == null) return false;

    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    final proof = GroupJoinProof.fromAttachments(attachments);
    if (proof == null) {
      await sdk.rejectConnectionRequest(channel: channel);
      return false;
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
        return true;
      }
      await sdk.rejectConnectionRequest(channel: channel);
      return false;
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
      _logFailure('confirming a membership', error.logCode);
      return true;
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
      return false;
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
    return false;
  }

  /// Brings every chat this phone owns or joined in step with its group:
  /// reads who may post from the community's link again, and, in a chat
  /// this phone owns, removes those the community no longer lists as active
  /// members, and makes the group's managers, and only them, moderators.
  ///
  /// A chat whose group cannot be read now is left as it is. Requests to
  /// join left waiting are decided again first.
  Future<void> syncChats() async {
    final sdk = await _ref.read(meetingPlaceSdkProvider.future);
    await _decideWaitingRequests(sdk);
    for (final chat in await _repository.groupChats()) {
      try {
        final current = await _readPosting(chat);
        if (current.isOwner && current.members.isNotEmpty) {
          await _sync(sdk, current);
        }
      } on MeetingPlaceVtcSDKException catch (error) {
        _logFailure('reading a group', error.logCode);
      } on Exception catch (error) {
        _logFailure('resolving a group', error.runtimeType);
      }
    }
  }

  /// [chat] with who may post as the community's link says now, kept when
  /// it changed. A link the community withdrew changes nothing.
  Future<VtcGroupChat> _readPosting(VtcGroupChat chat) async {
    final link = await _vtc.groupChatLink(chat.groupDid);
    if (link == null || link.posting == chat.posting) return chat;
    final updated = chat.copyWith(posting: link.posting);
    await _repository.saveGroupChat(updated);
    return updated;
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

  /// Logs [step] of joining the member's chats with the time since it began.
  void _logStep(String step, Stopwatch watch) => _logger.info(
    '$step after ${watch.elapsedMilliseconds} ms',
    name: _logKey,
  );

  void _logFailure(String action, Object code) =>
      _logger.warning('Failed $action: $code', name: _logKey);
}

/// The app's [VtcGroupChatService].
final vtcGroupChatServiceProvider = Provider<VtcGroupChatService>(
  VtcGroupChatService.new,
  name: 'vtcGroupChatServiceProvider',
);
