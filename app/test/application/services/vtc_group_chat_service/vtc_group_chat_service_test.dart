import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_community.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_group_chat.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/vtc_repository/secure_storage_vtc_repository.dart';

import '../../../fakes/fake_connection_offers.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_contacts_service.dart';
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

  /// The code the community refuses to list the group's members with.
  String? membersRefusal;

  /// Whether the group's authority shows as revoked, and those checked.
  bool isAuthorityRevoked = false;
  final authoritiesChecked = <Map<String, dynamic>>[];

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
    if (membersRefusal case final code?) {
      throw MeetingPlaceVtcSDKException.refused(code);
    }
    return members;
  }

  @override
  Future<bool> isGroupAuthorityRevoked(Map<String, dynamic> authority) async {
    authoritiesChecked.add(authority);
    return isAuthorityRevoked;
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
  List<VtcCommunity> memberCommunities = const [];
  Map<String, List<VtcGroupListing>> groupsOf = const {};

  @override
  Future<List<VtcCommunity>> memberships() async => memberCommunities;

  @override
  Future<VtcCommunity?> community(String communityDid) async =>
      memberCommunities
          .where((community) => community.communityDid == communityDid)
          .firstOrNull;

  @override
  Future<List<VtcGroupListing>> memberGroups(String communityDid) async =>
      groupsOf[communityDid] ?? const [];

  int linkLookups = 0;

  @override
  Future<GroupChatLink?> groupChatLink(String groupDid) async {
    linkLookups++;
    return link;
  }

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

  /// Whether members may post, by the chat it was set for.
  final membersCanPost = <String, bool>{};
  bool isChatUnreachable = false;

  @override
  Future<void> setGroupMembersCanPost(
    SetGroupMembersCanPostRequest request,
  ) async {
    if (isChatUnreachable) {
      throw MeetingPlaceCoreSDKException(
        message: 'chat unreachable',
        code: 'generic',
        innerException: StateError('chat unreachable'),
      );
    }
    membersCanPost[request.groupId] = request.membersCanPost;
  }

  @override
  Future<FindOfferResult> findOffer({required String mnemonic}) async =>
      FindOfferResult(connectionOffer: offerToFind);

  Set<String> chatModerators = const {};

  @override
  Future<Set<String>> groupModerators(Channel channel) async => chatModerators;

  /// The chats Meeting Place holds, by their id.
  Map<String, Group> groups = const {};

  @override
  Future<Group?> findGroupById(String groupId) async => groups[groupId];

  /// The offers Meeting Place holds, by their link.
  Map<String, ConnectionOffer> offers = const {};

  @override
  Future<ConnectionOffer?> findConnectionOffer(String offerLink) async =>
      offers[offerLink];

  /// The channels Meeting Place holds, by the other party's DID.
  Map<String, Channel> channels = {};
  final channelLookups = <String>[];

  @override
  Future<Channel?> findChannelByOtherPartyPermanentDid(String did) async {
    channelLookups.add(did);
    return channels[did];
  }

  /// The channels left, by the other party's DID.
  final left = <String>[];

  @override
  Future<void> leaveChannel(Channel channel) async =>
      left.add(channel.otherPartyPermanentChannelDid!);
}

/// Records the contacts it is asked to delete instead of deleting them.
class _DeletingContactsService extends FakeContactsService {
  _DeletingContactsService(List<Contact> contacts) : super(contacts: contacts);

  final deleted = <String>[];

  @override
  Future<void> deleteContacts(List<Contact> contacts) async =>
      deleted.addAll(contacts.map((contact) => contact.id));
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

Channel _ownerChannel() => Channel(
  offerLink: 'offer://chat',
  publishOfferDid: 'did:key:oob',
  mediatorDid: 'did:web:mediator.example',
  status: ChannelStatus.inaugurated,
  type: ChannelType.group,
  transport: ChannelTransport.matrix,
  isConnectionInitiator: true,
  contactCard: FakeContacts.sdkContactCard,
  permanentChannelDid: _ownerDid,
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

const _authority = {'type': 'AuthorityCredential'};

final _proof = const GroupJoinProof(
  presentation: {'type': 'VerifiablePresentation'},
  authority: _authority,
).toAttachments();

const _membersNotFound = 'vtc/groups/members/list:notFound';

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

    test('makes the chat read-only before letting in a member where only '
        'managers post', () async {
      await repository.saveGroupChat(
        ownedChat.copyWith(posting: GroupChatPosting.managers),
      );

      await service.decideJoinRequest(_joinRequest(), _proof);

      expect(sdk.membersCanPost, {'chat-1': false});
      expect(sdk.approved, [_memberDid]);
    });

    test('leaves the request waiting while the chat cannot be made to hold '
        'to who may post', () async {
      sdk.isChatUnreachable = true;

      await service.decideJoinRequest(_joinRequest(), _proof);

      expect(sdk.approved, isEmpty);
      expect(sdk.rejected, isEmpty);
    });

    test("remembers the group's authority the request carried", () async {
      await service.decideJoinRequest(_joinRequest(), _proof);

      expect((await stored()).authority, _authority);
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

    test('decides a request left waiting again at the next sync', () async {
      vtc.isCommunityDown = true;
      await service.decideJoinRequest(_joinRequest(), _proof);
      expect(sdk.approved, isEmpty);

      vtc.isCommunityDown = false;
      sdk.channels = {_memberDid: _joinRequest()};
      await service.syncChats();

      expect(sdk.approved, [_memberDid]);
      expect((await stored()).members, {_memberDid: 'entry-member'});
    });

    test(
      'forgets a request left waiting once it is decided elsewhere',
      () async {
        vtc.isCommunityDown = true;
        await service.decideJoinRequest(_joinRequest(), _proof);

        vtc.isCommunityDown = false;
        await service.syncChats();
        await service.syncChats();

        expect(sdk.channelLookups, [_memberDid]);
        expect(sdk.approved, isEmpty);
      },
    );

    test('keeps no request to a chat it does not own', () async {
      await repository.removeGroupChat('chat-1');
      await service.decideJoinRequest(_joinRequest(), _proof);

      await service.syncChats();

      expect(sdk.channelLookups, isEmpty);
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

    group('when the community no longer finds the group', () {
      late _DeletingContactsService contacts;
      final chatContact = FakeContacts.groupContact.copyWith(
        channelDid: _groupDid,
      );

      setUp(() async {
        vtc.membersRefusal = _membersNotFound;
        await repository.saveGroupChat(
          (await stored()).copyWith(authority: _authority),
        );
        contacts = _DeletingContactsService([chatContact]);
        final container = ProviderContainer(
          overrides: [
            vtcServiceProvider.overrideWithValue(vtc),
            meetingPlaceSdkProvider.overrideWith((ref) async => sdk),
            appLoggerProvider.overrideWithValue(FakeAppLogger()),
            contactsServiceProvider.overrideWith(() => contacts),
            vtcGroupChatServiceProvider.overrideWith(
              (ref) => VtcGroupChatService(ref, repository: repository),
            ),
          ],
        );
        addTearDown(container.dispose);
        service = container.read(vtcGroupChatServiceProvider);
      });

      test('removes everyone once the community deleted it', () async {
        vtc.isAuthorityRevoked = true;

        await service.syncChats();

        expect(sdk.removed, unorderedEquals([_memberDid, _ownerDid]));
      });

      test('leaves the chat as its owner once the community deleted it, '
          'with its contact', () async {
        vtc.isAuthorityRevoked = true;

        await service.syncChats();

        expect(contacts.deleted, [chatContact.id]);
        expect(await repository.groupChats(), isEmpty);
      });

      test('leaves the channel of a deleted chat without a contact', () async {
        contacts = _DeletingContactsService(const []);
        vtc.isAuthorityRevoked = true;
        sdk.channels = {_groupDid: _ownerChannel()};

        await service.syncChats();

        expect(contacts.deleted, isEmpty);
        expect(sdk.left, [_groupDid]);
        expect(await repository.groupChats(), isEmpty);
      });

      test('keeps everyone while it only hides the group', () async {
        await service.syncChats();

        expect(vtc.authoritiesChecked, [_authority]);
        expect(sdk.removed, isEmpty);
        expect((await stored()).members, hasLength(2));
      });

      test(
        "keeps everyone when it never learnt the group's authority",
        () async {
          await repository.saveGroupChat(
            ownedChat.copyWith(members: {_memberDid: 'entry-member'}),
          );

          await service.syncChats();

          expect(vtc.authoritiesChecked, isEmpty);
          expect(sdk.removed, isEmpty);
        },
      );

      test('keeps everyone when the community refuses otherwise', () async {
        vtc
          ..membersRefusal = 'vtc/groups/members/list:cursorInvalid'
          ..isAuthorityRevoked = true;

        await service.syncChats();

        expect(vtc.authoritiesChecked, isEmpty);
        expect(sdk.removed, isEmpty);
      });
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

    test('has a chat this phone owns hold to who may post', () async {
      vtc.link = const GroupChatLink(
        mnemonic: 'identity-wg',
        controlPlaneDid: 'did:web:control-plane.example',
        posting: GroupChatPosting.managers,
      );

      await service.syncChats();

      expect(sdk.membersCanPost, {'chat-1': false});
    });

    test('leaves who may post to the owner in a chat this phone '
        'joined', () async {
      await repository.saveGroupChat(
        const VtcGroupChat(
          chatGroupId: 'chat-1',
          communityDid: _communityDid,
          groupId: 'g1',
          groupDid: _groupDid,
          name: 'Identity WG',
          isOwner: false,
        ),
      );

      await service.syncChats();

      expect(sdk.membersCanPost, isEmpty);
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

  group('VtcGroupChatService.chatOfferLinks', () {
    Group chatGroup(String id) => Group(
      id: id,
      did: '$_groupDid-$id',
      offerLink: 'offer://$id',
      created: DateTime.utc(2026, 11),
      members: const [],
    );

    setUp(() async {
      await repository.saveGroupChat(
        const VtcGroupChat(
          chatGroupId: 'chat-2',
          communityDid: _communityDid,
          groupId: 'g2',
          groupDid: '$_groupDid-g2',
          name: 'Board',
          isOwner: false,
        ),
      );
      await repository.saveGroupChat(
        const VtcGroupChat(
          chatGroupId: 'chat-elsewhere',
          communityDid: 'did:webvh:QmOther:vtc.example',
          groupId: 'g1',
          groupDid: 'did:webvh:QmOther:vtc.example:group-dids:g1',
          name: 'Elsewhere',
          isOwner: false,
        ),
      );
      sdk.groups = {
        for (final id in ['chat-1', 'chat-2', 'chat-elsewhere'])
          id: chatGroup(id),
      };
    });

    test("names the chats of the community's groups only", () async {
      expect(await service.chatOfferLinks(_communityDid), {
        'offer://chat-1',
        'offer://chat-2',
      });
    });

    test('leaves out a chat Meeting Place no longer holds', () async {
      sdk.groups = {'chat-2': chatGroup('chat-2')};

      expect(await service.chatOfferLinks(_communityDid), {'offer://chat-2'});
    });
  });

  group('VtcGroupChatService.chatLink', () {
    final chatGroup = Group(
      id: 'chat-1',
      did: _groupDid,
      offerLink: 'offer://chat',
      created: DateTime.utc(2026, 11),
      members: const [],
    );

    test('rebuilds the link of a chat this phone owns', () async {
      sdk.groups = {'chat-1': chatGroup};
      sdk.offers = {'offer://chat': FakeConnectionOffers.groupOfferOwnedByMe};

      final link = await service.chatLink(_groupDid);

      expect(link?.mnemonic, 'my-group-passphrase');
      expect(link?.posting, GroupChatPosting.everyone);
    });

    test('is null for a chat this phone does not own', () async {
      await repository.saveGroupChat(
        const VtcGroupChat(
          chatGroupId: 'chat-1',
          communityDid: _communityDid,
          groupId: 'g1',
          groupDid: _groupDid,
          name: 'Identity WG',
          isOwner: false,
        ),
      );
      sdk.groups = {'chat-1': chatGroup};
      sdk.offers = {'offer://chat': FakeConnectionOffers.groupOfferOwnedByMe};

      expect(await service.chatLink(_groupDid), isNull);
    });

    test('is null when Meeting Place no longer holds the offer', () async {
      sdk.groups = {'chat-1': chatGroup};

      expect(await service.chatLink(_groupDid), isNull);
    });
  });

  group('VtcGroupChatService.joinGroupChats', () {
    late _JoinRecordingService joining;
    late _DeletingContactsService contacts;
    final member = FakeIdentities.primaryIdentity.copyWith(
      vtaContextId: 'mpx-1',
      vtaProfileId: '01PROFILE',
    );
    final membership = VtcCommunity(
      communityDid: _communityDid,
      personaDid: member.did,
      contextId: 'mpx-1',
    );
    const joinedChat = VtcGroupChat(
      chatGroupId: 'chat-2',
      communityDid: _communityDid,
      groupId: 'g2',
      groupDid: '$_groupDid-g2',
      name: 'Announcements',
      isOwner: false,
    );
    final chatContact = FakeContacts.groupContact.copyWith(
      channelDid: joinedChat.groupDid,
    );

    setUp(() {
      vtc.link = const GroupChatLink(
        mnemonic: 'group-chat',
        controlPlaneDid: '',
      );
      vtc.memberCommunities = [membership];
      contacts = _DeletingContactsService([chatContact]);
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
          contactsServiceProvider.overrideWith(() => contacts),
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

    test('names the identity that is the member as the one to act', () async {
      expect((await joining.memberIdentity(_communityDid))?.id, member.id);
      expect(await joining.memberIdentity('did:webvh:QmOther:x'), isNull);
    });

    test('names the identity a persona of its own joined as', () async {
      vtc.memberCommunities = const [
        VtcCommunity(
          communityDid: _communityDid,
          personaDid: 'did:webvh:QmClub:host.example',
          contextId: 'mpx-1',
        ),
      ];

      expect((await joining.memberIdentity(_communityDid))?.id, member.id);
    });

    test('leaves a community whose member is not on this phone', () async {
      vtc.memberCommunities = const [
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

    test('leaves the chats joined of a community the member left, with '
        'their contacts, but keeps those it owns', () async {
      await repository.saveGroupChat(joinedChat);
      vtc.memberCommunities = const [];

      await joining.joinGroupChats();

      expect(contacts.deleted, [chatContact.id]);
      expect((await stored()).chatGroupId, ownedChat.chatGroupId);
    });

    test('leaves the channel of a chat joined without a contact', () async {
      await repository.saveGroupChat(
        const VtcGroupChat(
          chatGroupId: 'chat-3',
          communityDid: _communityDid,
          groupId: 'g1',
          groupDid: _groupDid,
          name: 'Identity WG',
          isOwner: false,
        ),
      );
      sdk.channels = {_groupDid: _chatChannel()};
      vtc.memberCommunities = const [];

      await joining.joinGroupChats();

      expect(contacts.deleted, isEmpty);
      expect(sdk.left, [_groupDid]);
      expect((await stored()).chatGroupId, ownedChat.chatGroupId);
    });

    test('keeps the chats joined of a community the member is in', () async {
      await repository.saveGroupChat(joinedChat);

      await joining.joinGroupChats();

      expect(contacts.deleted, isEmpty);
      expect(await repository.groupChats(), hasLength(2));
    });

    test('joins the chat again once a new identity is the member of the '
        'community it left', () async {
      await repository.saveGroupChat(joinedChat);
      vtc.memberCommunities = const [];
      await joining.joinGroupChats();

      vtc.memberCommunities = [membership];
      vtc.groupsOf = {
        _communityDid: [_listing('g2')],
      };
      await joining.joinGroupChats();

      expect(joining.joined, [(_communityDid, 'g2', member.id)]);
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
    test("refuses an offer that names another group's DID", () async {
      vtc.link = const GroupChatLink(
        mnemonic: 'my-group-passphrase',
        // This app's control plane, as the tests build it: none.
        controlPlaneDid: '',
      );
      sdk.offerToFind = FakeConnectionOffers.groupOfferOwnedByMe;

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
            VtcGroupChatFailure.notTheGroupsChat,
          ),
        ),
      );
    });

    test('joins a chat once while a join of it is under way', () async {
      final joins = [
        for (var i = 0; i < 2; i++)
          service.joinChat(
            _communityDid,
            vtc.group,
            identity: FakeIdentities.primaryIdentity,
          ),
      ];

      for (final join in joins) {
        await expectLater(join, throwsA(isA<VtcGroupChatException>()));
      }
      expect(vtc.linkLookups, 1);
    });

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
