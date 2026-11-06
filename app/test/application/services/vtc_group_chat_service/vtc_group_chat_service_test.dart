import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_group_chat.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';

import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';
import '../../../mocks/fake_app_logger.dart';

const _communityDid = 'did:webvh:QmVtc:vtc.example';
const _groupDid = 'did:webvh:QmGroup:vtc.example:group-dids:g1';
const _memberDid = 'did:web:mpx.example:user:member';
const _ownerDid = 'did:web:mpx.example:user:owner';

/// The member's VTA and community, as far as group chats ask them.
class _FakeVtcService extends Fake implements VtcService {
  List<String> managers = const [];
  List<VtcGroupMember> members = const [
    VtcGroupMember(
      entryId: 'entry-member',
      state: 'active',
      credentialId: 'urn:uuid:card',
    ),
  ];
  GroupAdmissionException? refusal;
  bool isCommunityDown = false;
  bool hidesMembers = false;
  GroupChatLink? link;

  VtcGroup get group => VtcGroup(
    groupId: 'g1',
    groupDid: _groupDid,
    name: 'Identity WG',
    isDynamic: false,
    visibility: GroupAudience.members,
    showMembers: hidesMembers
        ? GroupAudience.admins
        : GroupAudience.groupMembers,
    managers: managers,
  );

  @override
  Future<GroupAdmission> verifyGroupJoin(
    GroupJoinProof proof, {
    required String communityDid,
    required String groupDid,
    required String memberDid,
  }) async {
    if (refusal case final refusal?) throw refusal;
    return GroupAdmission(
      holderDid: 'did:webvh:persona',
      credentialId: 'urn:uuid:card',
      validUntil: DateTime.utc(2026, 12),
    );
  }

  @override
  Future<List<VtcGroupMember>> groupMembers(
    String communityDid, {
    required String groupId,
  }) async {
    if (isCommunityDown) {
      throw MeetingPlaceVtcSDKException.transportFailed('down');
    }
    return members;
  }

  @override
  Future<VtcGroupListing> communityGroup(
    String communityDid, {
    required String groupId,
  }) async {
    if (isCommunityDown) {
      throw MeetingPlaceVtcSDKException.transportFailed('down');
    }
    return VtcGroupListing(group: group, standing: GroupStanding.member);
  }

  /// The communities the member belongs to, and each one's groups.
  List<VtcCommunity> communities = const [];
  Map<String, List<VtcGroupListing>> groupsOf = const {};

  @override
  Future<List<VtcCommunity>> memberships() async => communities;

  @override
  Future<List<VtcGroupListing>> memberGroups(String communityDid) async =>
      groupsOf[communityDid] ?? const [];

  @override
  Future<GroupChatLink?> groupChatLink(String groupDid) async => link;

  @override
  Future<int> collectGroupCredentials(
    String communityDid, {
    required Set<String> groupDids,
  }) async => 0;

  @override
  Future<bool> holdsGroupCredential(
    String communityDid, {
    required String groupDid,
  }) async => true;
}

/// Records what the chat's owner decided.
class _FakeSdk extends Fake implements MeetingPlaceMatrixSDK {
  final approved = <String>[];
  final rejected = <String>[];
  final removed = <String>[];
  final moderators = <String, bool>{};
  ConnectionOffer? offerToFind;

  @override
  Future<Channel> approveConnectionRequest(
    ApproveConnectionRequestParams params,
  ) async {
    approved.add(params.channel.otherPartyPermanentChannelDid!);
    return params.channel;
  }

  @override
  Future<Group> rejectConnectionRequest({required Channel channel}) async {
    rejected.add(channel.otherPartyPermanentChannelDid!);
    return Group(
      id: 'chat-1',
      did: _groupDid,
      offerLink: 'offer://chat',
      created: DateTime.utc(2026, 11),
      members: const [],
    );
  }

  @override
  Future<void> removeMemberFromGroup(
    RemoveMemberFromGroupRequest request,
  ) async => removed.add(request.memberDid);

  @override
  Future<void> setGroupModerator(SetGroupModeratorRequest request) async =>
      moderators[request.memberDid] = request.isModerator;

  @override
  Future<FindOfferResult> findOffer({required String mnemonic}) async =>
      FindOfferResult(connectionOffer: offerToFind);

  Set<String> chatModerators = const {};

  @override
  Future<Set<String>> groupModerators(Channel channel) async => chatModerators;
}

/// Records the chats it is asked to join instead of joining them.
class _JoinRecordingService extends VtcGroupChatService {
  _JoinRecordingService(super.ref, {super.repository});

  final joined = <(String, String, String)>[];

  /// Groups whose chat cannot be joined yet.
  Set<String> notYetJoinable = const {};

  @override
  Future<void> joinChat(
    String communityDid,
    VtcGroup group, {
    required Identity identity,
  }) async {
    if (notYetJoinable.contains(group.groupId)) {
      throw const VtcGroupChatException(VtcGroupChatFailure.notLinked);
    }
    joined.add((communityDid, group.groupId, identity.id));
  }
}

VtcGroupListing _listing(
  String groupId, {
  GroupStanding standing = GroupStanding.member,
}) => VtcGroupListing(
  group: VtcGroup(
    groupId: groupId,
    groupDid: groupId == 'g1' ? _groupDid : '$_groupDid-$groupId',
    name: groupId,
    isDynamic: true,
    visibility: GroupAudience.members,
    showMembers: GroupAudience.groupMembers,
  ),
  standing: standing,
);

Channel _chatChannel() => Channel(
  offerLink: 'offer://chat',
  publishOfferDid: 'did:key:oob',
  mediatorDid: 'did:web:mediator.example',
  status: ChannelStatus.inaugurated,
  type: ChannelType.group,
  transport: ChannelTransport.matrix,
  isConnectionInitiator: false,
  contactCard: FakeContacts.sdkContactCard,
  permanentChannelDid: _memberDid,
  otherPartyPermanentChannelDid: _groupDid,
);

Channel _joinRequest({String memberDid = _memberDid}) => Channel(
  offerLink: 'offer://chat',
  publishOfferDid: 'did:key:oob',
  mediatorDid: 'did:web:mediator.example',
  status: ChannelStatus.waitingForApproval,
  type: ChannelType.group,
  transport: ChannelTransport.matrix,
  isConnectionInitiator: true,
  contactCard: FakeContacts.sdkContactCard,
  permanentChannelDid: _groupDid,
  otherPartyPermanentChannelDid: memberDid,
);

final _proof = const GroupJoinProof(
  presentation: {'type': 'VerifiablePresentation'},
  authority: {'type': 'AuthorityCredential'},
).toAttachments();

void main() {
  late _FakeVtcService vtc;
  late _FakeSdk sdk;
  late SecureStorageVtcRepository repository;
  late VtcGroupChatService service;

  const ownedChat = VtcGroupChat(
    chatGroupId: 'chat-1',
    communityDid: _communityDid,
    groupId: 'g1',
    groupDid: _groupDid,
    name: 'Identity WG',
    isOwner: true,
  );

  Future<VtcGroupChat> stored() async => (await repository.groupChats()).single;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    vtc = _FakeVtcService();
    sdk = _FakeSdk();
    repository = SecureStorageVtcRepository();
    await repository.saveGroupChat(ownedChat);
    final container = ProviderContainer(
      overrides: [
        vtcServiceProvider.overrideWithValue(vtc),
        meetingPlaceSdkProvider.overrideWith((ref) async => sdk),
        appLoggerProvider.overrideWithValue(FakeAppLogger()),
        vtcGroupChatServiceProvider.overrideWith(
          (ref) => VtcGroupChatService(ref, repository: repository),
        ),
      ],
    );
    addTearDown(container.dispose);
    service = container.read(vtcGroupChatServiceProvider);
  });

  group('VtcGroupChatService.decideJoinRequest', () {
    test('lets in a member of the group, and remembers who they are', () async {
      await service.decideJoinRequest(_joinRequest(), _proof);

      expect(sdk.approved, [_memberDid]);
      expect(sdk.moderators, isEmpty);
      expect((await stored()).members, {_memberDid: 'entry-member'});
    });

    test('lets in a manager of the group as a moderator', () async {
      vtc.managers = const ['entry-member'];

      await service.decideJoinRequest(_joinRequest(), _proof);

      expect(sdk.approved, [_memberDid]);
      expect(sdk.moderators, {_memberDid: true});
      expect((await stored()).moderators, {_memberDid});
    });

    test('refuses a request without proof', () async {
      await service.decideJoinRequest(_joinRequest(), const []);

      expect(sdk.rejected, [_memberDid]);
      expect(sdk.approved, isEmpty);
    });

    test('refuses a proof that does not hold', () async {
      vtc.refusal = const GroupAdmissionException(
        GroupAdmissionRefusal.notThisGroup,
      );

      await service.decideJoinRequest(_joinRequest(), _proof);

      expect(sdk.rejected, [_memberDid]);
    });

    test('refuses a member the community no longer lists', () async {
      vtc.members = const [
        VtcGroupMember(
          entryId: 'entry-member',
          state: 'removed',
          credentialId: 'urn:uuid:card',
        ),
      ];

      await service.decideJoinRequest(_joinRequest(), _proof);

      expect(sdk.rejected, [_memberDid]);
      expect(sdk.approved, isEmpty);
    });

    test('refuses a credential the group has since renewed', () async {
      vtc.members = const [
        VtcGroupMember(
          entryId: 'entry-member',
          state: 'active',
          credentialId: 'urn:uuid:renewed',
        ),
      ];

      await service.decideJoinRequest(_joinRequest(), _proof);

      expect(sdk.rejected, [_memberDid]);
    });

    test('leaves the request waiting while the community is down', () async {
      vtc.isCommunityDown = true;

      await service.decideJoinRequest(_joinRequest(), _proof);

      expect(sdk.approved, isEmpty);
      expect(sdk.rejected, isEmpty);
    });

    test('leaves the request waiting while the grant cannot be '
        'checked', () async {
      vtc.refusal = const GroupAdmissionException(
        GroupAdmissionRefusal.authorityStatusUnknown,
      );

      await service.decideJoinRequest(_joinRequest(), _proof);

      expect(sdk.approved, isEmpty);
      expect(sdk.rejected, isEmpty);
    });

    test('leaves requests to other chats alone', () async {
      await repository.removeGroupChat('chat-1');

      await service.decideJoinRequest(_joinRequest(), const []);

      expect(sdk.approved, isEmpty);
      expect(sdk.rejected, isEmpty);
    });
  });

  group('VtcGroupChatService.syncChats', () {
    setUp(() async {
      await repository.saveGroupChat(
        ownedChat.copyWith(
          members: {_memberDid: 'entry-member', _ownerDid: 'entry-owner'},
          moderators: {_ownerDid},
        ),
      );
    });

    test('removes those who left the group', () async {
      vtc.members = const [
        VtcGroupMember(entryId: 'entry-owner', state: 'active'),
      ];
      vtc.managers = const ['entry-owner'];

      await service.syncChats();

      expect(sdk.removed, [_memberDid]);
      expect((await stored()).members, {_ownerDid: 'entry-owner'});
    });

    test("follows the group's managers", () async {
      vtc.members = const [
        VtcGroupMember(entryId: 'entry-owner', state: 'active'),
        VtcGroupMember(entryId: 'entry-member', state: 'active'),
      ];
      vtc.managers = const ['entry-member'];

      await service.syncChats();

      expect(sdk.moderators, {_memberDid: true, _ownerDid: false});
      expect((await stored()).moderators, {_memberDid});
      expect(sdk.removed, isEmpty);
    });

    test('changes nothing while the community is down', () async {
      vtc.isCommunityDown = true;

      await service.syncChats();

      expect(sdk.removed, isEmpty);
      expect(sdk.moderators, isEmpty);
    });
  });

  group('VtcGroupChatService.syncChats posting', () {
    test("reads who may post from the community's link again", () async {
      vtc.link = const GroupChatLink(
        mnemonic: 'identity-wg',
        controlPlaneDid: 'did:web:control-plane.example',
        posting: GroupChatPosting.managers,
      );

      await service.syncChats();

      expect((await stored()).posting, GroupChatPosting.managers);
    });

    test('keeps who may post when the link is gone', () async {
      await repository.saveGroupChat(
        ownedChat.copyWith(posting: GroupChatPosting.managers),
      );

      await service.syncChats();

      expect((await stored()).posting, GroupChatPosting.managers);
    });
  });

  group('VtcGroupChatService.postingIn', () {
    test('lets everyone post where the link lets everyone', () async {
      expect(
        await service.postingIn(_chatChannel(), chatGroupId: 'chat-1'),
        isNull,
      );
    });

    test("lets only the chat's moderators post where only managers "
        'do', () async {
      await repository.saveGroupChat(
        ownedChat.copyWith(posting: GroupChatPosting.managers),
      );
      sdk.chatModerators = {_ownerDid};

      final posting = await service.postingIn(
        _chatChannel(),
        chatGroupId: 'chat-1',
      );

      expect(posting!.canPost, isFalse);
      expect(posting.allows(_ownerDid), isTrue);
      expect(posting.allows(_memberDid), isFalse);
    });

    test('knows nothing of a chat that follows no group', () async {
      expect(
        await service.postingIn(_chatChannel(), chatGroupId: 'other'),
        isNull,
      );
    });
  });

  group('VtcGroupChatService.joinGroupChats', () {
    late _JoinRecordingService joining;
    final member = FakeIdentities.primaryIdentity;

    setUp(() {
      vtc.communities = [
        VtcCommunity(
          communityDid: _communityDid,
          personaDid: member.did,
          contextId: 'mpx-1',
        ),
      ];
      final container = ProviderContainer(
        overrides: [
          vtcServiceProvider.overrideWithValue(vtc),
          meetingPlaceSdkProvider.overrideWith((ref) async => sdk),
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          identitiesServiceProvider.overrideWith(
            () => FakeIdentitiesService(
              IdentitiesServiceState(identities: [member]),
            ),
          ),
          vtcGroupChatServiceProvider.overrideWith(
            (ref) => _JoinRecordingService(ref, repository: repository),
          ),
        ],
      );
      addTearDown(container.dispose);
      joining =
          container.read(vtcGroupChatServiceProvider) as _JoinRecordingService;
    });

    test("joins the chats of the member's groups as the identity that is "
        'the member, but not one it has', () async {
      vtc.groupsOf = {
        _communityDid: [_listing('g1'), _listing('announcements')],
      };

      await joining.joinGroupChats();

      expect(joining.joined, [(_communityDid, 'announcements', member.id)]);
    });

    test('joins only groups the member is in', () async {
      vtc.groupsOf = {
        _communityDid: [_listing('requested', standing: GroupStanding.pending)],
      };

      await joining.joinGroupChats();

      expect(joining.joined, isEmpty);
    });

    test('tries a chat it could not join again next time', () async {
      vtc.groupsOf = {
        _communityDid: [_listing('announcements')],
      };
      joining.notYetJoinable = {'announcements'};

      await joining.joinGroupChats();
      joining.notYetJoinable = const {};
      await joining.joinGroupChats();

      expect(joining.joined, [(_communityDid, 'announcements', member.id)]);
    });

    test('leaves a community whose member is not on this phone', () async {
      vtc.communities = const [
        VtcCommunity(
          communityDid: _communityDid,
          personaDid: 'did:webvh:elsewhere',
          contextId: 'mpx-2',
        ),
      ];
      vtc.groupsOf = {
        _communityDid: [_listing('announcements')],
      };

      await joining.joinGroupChats();

      expect(joining.joined, isEmpty);
    });
  });

  group('VtcGroupChatService.createChat', () {
    test('refuses a member who does not manage the group', () async {
      vtc.managers = const [];
      const notManaged = VtcGroup(
        groupId: 'g1',
        groupDid: _groupDid,
        name: 'Identity WG',
        isDynamic: false,
        visibility: GroupAudience.members,
        showMembers: GroupAudience.groupMembers,
      );
      final notManagingVtc = _NotManagingVtc();

      final container = ProviderContainer(
        overrides: [
          vtcServiceProvider.overrideWithValue(notManagingVtc),
          meetingPlaceSdkProvider.overrideWith((ref) async => sdk),
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(vtcGroupChatServiceProvider)
            .createChat(
              _communityDid,
              notManaged,
              identity: FakeIdentities.primaryIdentity,
            ),
        throwsA(
          isA<VtcGroupChatException>().having(
            (e) => e.failure,
            'failure',
            VtcGroupChatFailure.notAManager,
          ),
        ),
      );
    });

    test('refuses a group that hides its members', () async {
      vtc.hidesMembers = true;

      await expectLater(
        service.createChat(
          _communityDid,
          vtc.group,
          identity: FakeIdentities.primaryIdentity,
        ),
        throwsA(
          isA<VtcGroupChatException>().having(
            (e) => e.failure,
            'failure',
            VtcGroupChatFailure.hidesMembers,
          ),
        ),
      );
    });

    test('refuses a group the community already linked a chat to', () async {
      vtc.link = const GroupChatLink(
        mnemonic: 'identity-wg',
        controlPlaneDid: 'did:web:control-plane.example',
      );

      await expectLater(
        service.createChat(
          _communityDid,
          vtc.group,
          identity: FakeIdentities.primaryIdentity,
        ),
        throwsA(
          isA<VtcGroupChatException>().having(
            (e) => e.failure,
            'failure',
            VtcGroupChatFailure.alreadyLinked,
          ),
        ),
      );
    });
  });

  group('VtcGroupChatService.joinChat', () {
    test('refuses when the community linked no chat', () async {
      await expectLater(
        service.joinChat(
          _communityDid,
          vtc.group,
          identity: FakeIdentities.primaryIdentity,
        ),
        throwsA(
          isA<VtcGroupChatException>().having(
            (e) => e.failure,
            'failure',
            VtcGroupChatFailure.notLinked,
          ),
        ),
      );
    });
  });
}

/// A member who does not manage the group: the community shows no
/// managers.
class _NotManagingVtc extends _FakeVtcService {
  @override
  VtcGroup get group => const VtcGroup(
    groupId: 'g1',
    groupDid: _groupDid,
    name: 'Identity WG',
    isDynamic: false,
    visibility: GroupAudience.members,
    showMembers: GroupAudience.groupMembers,
  );
}
