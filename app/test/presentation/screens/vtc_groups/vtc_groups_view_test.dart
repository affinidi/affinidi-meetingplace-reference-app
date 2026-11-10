import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_group_chat_service/vtc_group_chat_service.dart';
import 'package:mpx_flutter_reference_app/application/services/vtc_service/vtc_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/domain/models/vtc/vtc_group_chat.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/vtc_groups/vtc_groups_view.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_identities_service.dart';
import '../../../mocks/fake_app_logger.dart';

const _communityDid = 'did:webvh:QmVtc:vtc.example';
const _managedDid = 'did:webvh:QmManaged:vtc.example:group-dids:g1';
const _linkedDid = 'did:webvh:QmLinked:vtc.example:group-dids:g2';

const _managed = VtcGroup(
  groupId: 'g1',
  groupDid: _managedDid,
  name: 'Identity WG',
  description: 'Working on identity.',
  isDynamic: false,
  visibility: GroupAudience.members,
  showMembers: GroupAudience.groupMembers,
  managers: ['entry-me'],
);

const _linked = VtcGroup(
  groupId: 'g2',
  groupDid: _linkedDid,
  name: 'Book club',
  isDynamic: false,
  visibility: GroupAudience.members,
  showMembers: GroupAudience.groupMembers,
);

class _FakeVtcService extends Fake implements VtcService {
  bool isVtaMissing = false;
  bool isNotYetMember = false;
  int reads = 0;

  /// Holds the pickup of the groups' credentials until completed.
  Completer<void>? pickup;

  @override
  Future<List<VtcGroupListing>> memberGroups(String communityDid) async {
    reads++;
    if (isVtaMissing) throw const VtaNotLinkedException();
    if (isNotYetMember) throw const NotACommunityMemberException();
    return const [
      VtcGroupListing(group: _managed, standing: GroupStanding.member),
      VtcGroupListing(group: _linked, standing: GroupStanding.member),
    ];
  }

  @override
  Future<int> collectGroupCredentials(
    String communityDid, {
    required Set<String> groupDids,
  }) async {
    await pickup?.future;
    return 0;
  }

  @override
  Future<DateTime?> groupCredentialValidUntil(
    String communityDid, {
    required String groupDid,
  }) async => groupDid == _managedDid ? DateTime.utc(2026, 12, 9) : null;

  @override
  Future<GroupChatLink?> groupChatLink(String groupDid) async =>
      groupDid == _linkedDid
      ? const GroupChatLink(
          mnemonic: 'book-club',
          controlPlaneDid: 'did:web:control-plane.example',
        )
      : null;
}

class _FakeChats extends Fake implements VtcGroupChatService {
  final created = <String>[];
  final postings = <GroupChatPosting>[];
  final joined = <String>[];
  VtcGroupChatFailure? joinFailure;

  /// The identity that is the member here: not the current one.
  Identity? member = FakeIdentities.secondaryIdentity;

  /// The identities the chats were created and joined as, by their id.
  final actedAs = <String>[];

  /// The chats this phone owns or joined.
  final stored = <VtcGroupChat>[];

  /// Whether joining the member's chats joins the linked one.
  bool joinsLinked = false;
  int joinedAll = 0;

  @override
  Future<List<VtcGroupChat>> chats() async => [...stored];

  @override
  Future<void> joinGroupChats() async {
    joinedAll++;
    if (!joinsLinked) return;
    stored.add(
      const VtcGroupChat(
        chatGroupId: 'chat-g2',
        communityDid: _communityDid,
        groupId: 'g2',
        groupDid: _linkedDid,
        name: 'Book club',
        isOwner: false,
      ),
    );
  }

  @override
  Future<Identity?> memberIdentity(String communityDid) async => member;

  @override
  Future<GroupChatLink> createChat(
    String communityDid,
    VtcGroup group, {
    required Identity identity,
    GroupChatPosting posting = GroupChatPosting.everyone,
  }) async {
    created.add(group.groupId);
    postings.add(posting);
    actedAs.add(identity.id);
    return GroupChatLink(
      mnemonic: 'identity-wg',
      controlPlaneDid: 'did:web:control-plane.example',
      posting: posting,
    );
  }

  @override
  Future<void> joinChat(
    String communityDid,
    VtcGroup group, {
    required Identity identity,
  }) async {
    if (joinFailure case final failure?) {
      throw VtcGroupChatException(failure);
    }
    joined.add(group.groupId);
    actedAs.add(identity.id);
  }
}

void main() {
  late _FakeVtcService vtc;
  late _FakeChats chats;

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vtcServiceProvider.overrideWithValue(vtc),
          vtcGroupChatServiceProvider.overrideWithValue(chats),
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          identitiesServiceProvider.overrideWith(
            () => FakeIdentitiesService(
              IdentitiesServiceState(
                currentIdentity: FakeIdentities.primaryIdentity,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: VtcGroupsView(
              communityDid: _communityDid,
              communityName: 'Football club',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Key key) async {
    await tester.ensureVisible(find.byKey(key));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  setUp(() {
    vtc = _FakeVtcService();
    chats = _FakeChats();
  });

  testWidgets('offers a manager to create the chat, and a member to join '
      'a linked one', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Identity WG'), findsOneWidget);
    expect(find.text('Manager'), findsOneWidget);
    expect(find.byKey(const Key('vtc_group_create_g1')), findsOneWidget);
    expect(find.byKey(const Key('vtc_group_join_g2')), findsOneWidget);
    expect(find.text('Valid until Dec 9, 2026'), findsOneWidget);
  });

  testWidgets('offers the chats before the credentials are picked up', (
    tester,
  ) async {
    vtc.pickup = Completer<void>();
    await pumpScreen(tester);

    expect(find.byKey(const Key('vtc_group_create_g1')), findsOneWidget);
    expect(find.byKey(const Key('vtc_group_join_g2')), findsOneWidget);
    expect(find.text('Valid until Dec 9, 2026'), findsNothing);

    vtc.pickup!.complete();
    await tester.pumpAndSettle();

    expect(find.text('Valid until Dec 9, 2026'), findsOneWidget);
  });

  testWidgets('offers the members of groups that show them', (tester) async {
    await pumpScreen(tester);

    expect(find.byKey(const Key('vtc_group_members_g1')), findsOneWidget);
    expect(find.byKey(const Key('vtc_group_members_g2')), findsOneWidget);
  });

  testWidgets('shows the link to publish once the chat is created', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tapVisible(tester, const Key('vtc_group_create_g1'));
    await tester.tap(find.byKey(const Key('vtc_group_posting_everyone')));
    await tester.pumpAndSettle();

    expect(chats.created, ['g1']);
    expect(find.text("Publish the chat's link"), findsOneWidget);
    final service = tester.widget<SelectableText>(
      find.byKey(const Key('vtc_group_chat_link_service')),
    );
    expect(service.data, contains('MeetingPlaceGroup'));
    expect(service.data, contains('identity-wg'));
    expect(service.data, contains('$_managedDid#meeting-place'));
  });

  testWidgets('asks who may post, and links only managers posting', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tapVisible(tester, const Key('vtc_group_create_g1'));
    expect(find.text('Who can post in this chat?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('vtc_group_posting_managers')));
    await tester.pumpAndSettle();

    expect(chats.postings, [GroupChatPosting.managers]);
    final service = tester.widget<SelectableText>(
      find.byKey(const Key('vtc_group_chat_link_service')),
    );
    expect(service.data, contains('"post": "managers"'));
  });

  testWidgets('creates no chat when the question is dismissed', (tester) async {
    await pumpScreen(tester);

    await tapVisible(tester, const Key('vtc_group_create_g1'));
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(chats.created, isEmpty);
  });

  testWidgets('creates and joins as the identity that is the member, not '
      'the current one', (tester) async {
    await pumpScreen(tester);

    await tapVisible(tester, const Key('vtc_group_create_g1'));
    await tester.tap(find.byKey(const Key('vtc_group_posting_everyone')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tapVisible(tester, const Key('vtc_group_join_g2'));

    expect(chats.actedAs, [
      FakeIdentities.secondaryIdentity.id,
      FakeIdentities.secondaryIdentity.id,
    ]);
  });

  testWidgets('joins as nobody when the member is not on this phone', (
    tester,
  ) async {
    chats.member = null;
    await pumpScreen(tester);

    await tapVisible(tester, const Key('vtc_group_join_g2'));

    expect(chats.joined, isEmpty);
    expect(
      find.text(
        "The identity that is your membership of this community isn't on "
        'this phone.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('joins a linked chat without asking', (tester) async {
    chats.joinsLinked = true;
    await pumpScreen(tester);

    expect(chats.joinedAll, 1);
    expect(find.byKey(const Key('vtc_group_join_g2')), findsNothing);
    expect(chats.joined, isEmpty);
  });

  testWidgets('joins a linked chat', (tester) async {
    await pumpScreen(tester);

    await tapVisible(tester, const Key('vtc_group_join_g2'));

    expect(chats.joined, ['g2']);
    expect(find.byKey(const Key('vtc_group_join_g2')), findsNothing);
  });

  testWidgets('says why a join did not go ahead', (tester) async {
    chats.joinFailure = VtcGroupChatFailure.noGroupCredential;
    await pumpScreen(tester);

    await tapVisible(tester, const Key('vtc_group_join_g2'));

    expect(
      find.text(
        "Your VTA doesn't have this group's membership credential yet. "
        'Try again later.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('says the membership is not confirmed yet instead of '
      'failing', (tester) async {
    vtc.isNotYetMember = true;

    await pumpScreen(tester);

    expect(
      find.text(
        "This phone hasn't confirmed your membership yet. Open the community "
        'to check, then try again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('asks to link a VTA when none is', (tester) async {
    vtc.isVtaMissing = true;

    await pumpScreen(tester);

    expect(find.text('Link your VTA to see your groups.'), findsOneWidget);
  });

  testWidgets('reads the groups again when pulled down, also after a '
      'failure', (tester) async {
    vtc.isVtaMissing = true;
    await pumpScreen(tester);
    vtc.isVtaMissing = false;

    await tester.fling(
      find.text('Link your VTA to see your groups.'),
      const Offset(0, 300),
      1000,
    );
    await tester.pumpAndSettle();

    expect(vtc.reads, 2);
    expect(find.text('Identity WG'), findsOneWidget);
  });
}
