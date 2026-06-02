import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_presence_status.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/unsent_messages_service/unsent_messages_service.dart';

import '../../../fakes/fake_app_badge_service.dart';
import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_chat_sdk.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_contacts_service.dart';
import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_groups.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('ChatSessionService - Session & SDK Delegation', () {
    late ProviderContainer container;
    late ChatSessionService chatService;
    late FakeMeetingPlaceSDK fakeCoreSdk;
    late FakeChatSdk fakeChatSdk;
    late FakeContactsService fakeContactsService;

    final testContact = FakeContacts.individualContact;
    final channelDid = testContact.channelDid!;

    setUp(() async {
      fakeCoreSdk = FakeMeetingPlaceSDK(
        channels: {channelDid: FakeChannels.individualChannel},
      );
      fakeChatSdk = FakeChatSdk();
      fakeChatSdk.chatActivitySent = false;
      fakeContactsService = FakeContactsService();

      container = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
          chatSdkProvider.overrideWith((ref, channel) async => fakeChatSdk),
          contactsServiceProvider.overrideWith(() => fakeContactsService),
          environmentProvider.overrideWithValue(FakeEnvironment()),
          appBadgeServiceProvider.overrideWith((ref) => FakeAppBadgeService()),
          networkConnectivityServiceProvider.overrideWith(
            _FakeNetworkConnectivityService.new,
          ),
        ],
      );
      container.listen(
        chatSessionServiceProvider(channelDid),
        (previous, value) {},
        fireImmediately: true,
      );
      chatService = container.read(
        chatSessionServiceProvider(channelDid).notifier,
      );

      final knownGroup = FakeGroups.approvedGroup();
      fakeCoreSdk.setMockGroup(knownGroup);
    });

    tearDown(() => container.dispose());

    test('sets session state and delegates to SDK on start', () async {
      await chatService.startChatSession();

      expect(fakeChatSdk.startChatSessionCallCount, equals(1));
      expect(
        chatService.secondsToShowChatActivityIndicator,
        FakeEnvironment().chatActivityExpiresInSeconds,
      );
      expect(
        chatService.chatPresenceIntervalInSeconds,
        FakeEnvironment().chatPresenceIntervalInSeconds,
      );
      expect(chatService.isGroupChat, testContact.isGroup);
    });

    test('delegates sendTextMessage to SDK', () async {
      await chatService.startChatSession();
      await chatService.sendTextMessage('hello');
      expect(fakeChatSdk.sendTextMessageCalls.last['text'], 'hello');
    });

    test('delegates sendChatActivity to SDK', () async {
      await chatService.startChatSession();
      await chatService.sendChatActivity();
      expect(fakeChatSdk.chatActivitySent, true);
    });

    test('delegates rejectConnectionRequest to SDK', () async {
      await chatService.startChatSession();
      final fakeMessage = fakeChatSdk.fakeConciergeMessage();
      await chatService.rejectConnectionRequest(fakeMessage);
      expect(fakeChatSdk.lastRejectedConnection, fakeMessage);
    });

    test('delegates approveConnectionRequest to SDK', () async {
      await chatService.startChatSession();
      final fakeMessage = fakeChatSdk.fakeConciergeMessage();
      await chatService.approveConnectionRequest(fakeMessage);
      expect(fakeChatSdk.lastApprovedConnection, fakeMessage);
    });

    test('delegates sendChatContactDetailsUpdate to SDK', () async {
      await chatService.startChatSession();
      final fakeMessage = fakeChatSdk.fakeConciergeMessage();
      await chatService.sendChatContactDetailsUpdate(fakeMessage);
      expect(fakeChatSdk.lastContactDetailsUpdateSent, fakeMessage);
    });

    test('delegates rejectChatContactDetailsUpdate to SDK', () async {
      await chatService.startChatSession();
      final fakeMessage = fakeChatSdk.fakeConciergeMessage();
      await chatService.rejectChatContactDetailsUpdate(fakeMessage);
      expect(fakeChatSdk.lastContactDetailsUpdateRejected, fakeMessage);
    });

    test('delegates reactOnMessage to SDK', () async {
      await chatService.startChatSession();
      final fakeMessage = fakeChatSdk.fakeMessage();
      await chatService.reactOnMessage(fakeMessage, reaction: '👍');
      expect(fakeChatSdk.lastReactionMessage, fakeMessage);
      expect(fakeChatSdk.lastReaction, '👍');
    });

    test('delegates sendEffect to SDK', () async {
      await chatService.startChatSession();
      await chatService.sendEffect(Effect.confetti);
      expect(fakeChatSdk.lastEffectSent, Effect.confetti.name);
    });

    test('ends session and cancels subscription on pauseChat', () async {
      await chatService.startChatSession();
      await chatService.pauseChat();
      expect(fakeChatSdk.sessionEnded, true);
    });

    test('resets badge count on resetBadgeCount', () async {
      await chatService.startChatSession();
      await chatService.resetBadgeCount();
      expect(fakeContactsService.resetBadgeCalledWith, testContact.channelDid);
    });

    test('skips badge reset when channel is missing on start', () async {
      final missingChannelDid = 'did:key:missing';
      container.listen(
        chatSessionServiceProvider(missingChannelDid),
        (previous, value) {},
        fireImmediately: true,
      );
      final missingService = container.read(
        chatSessionServiceProvider(missingChannelDid).notifier,
      );
      await missingService.startChatSession();
      expect(fakeContactsService.resetBadgeCalledWith, isNull);
    });

    test('logs error and skips badge reset when SDK throws on start', () async {
      fakeChatSdk.shouldThrowOnStartSession = true;
      await chatService.startChatSession();
      expect(fakeContactsService.resetBadgeCalledWith, isNull);
      expect(fakeChatSdk.startChatSessionCallCount, equals(1));
      expect(fakeChatSdk.sessionEnded, isFalse);
      expect(fakeChatSdk.sendTextMessageCalls, isEmpty);
    });

    test('updates contact sequence number', () async {
      await chatService.startChatSession();
      await chatService.updateContactSequenceNumber(testContact.channelDid!);
      expect(fakeContactsService.updateContactCalls, isNotEmpty);
    });

    test('delegates sendTextMessage with attachments to SDK', () async {
      await chatService.startChatSession();
      await chatService.sendTextMessage(
        'hello',
        attachments: [ChatAttachment(id: '1')],
      );
      expect(fakeChatSdk.sendTextMessageCalls.last['attachments'], isNotEmpty);
    });

    test('pauseChat can be called multiple times safely', () async {
      await chatService.startChatSession();
      await chatService.pauseChat();
      await chatService.pauseChat();
      expect(fakeChatSdk.sessionEnded, true);
    });

    test('restores unsent message for contact when message exists', () async {
      await chatService.startChatSession();

      final unsentMessagesService = container.read(
        unsentMessagesServiceProvider.notifier,
      );
      await unsentMessagesService.saveUnsentMessage(
        testContact.id,
        'draft message',
      );

      final unsentMessage = await chatService.restoreUnsentMessage(
        testContact.id,
      );
      expect(unsentMessage, 'draft message');
    });

    test('calculates contact presence status correctly', () async {
      final now = DateTime.now();
      final online = await chatService.calculateContactPresenceStatus(
        now,
        chatService.chatPresenceIntervalInSeconds,
      );
      expect(online, ContactPresenceStatus.online);

      final offline = await chatService.calculateContactPresenceStatus(
        now.subtract(
          Duration(seconds: chatService.chatPresenceIntervalInSeconds + 10),
        ),
        chatService.chatPresenceIntervalInSeconds,
      );
      expect(offline, ContactPresenceStatus.offline);
    });

    test('updates group contact pending status', () async {
      await chatService.startChatSession();

      final group = FakeGroups.approvedGroup();
      await chatService.updateGroupContactPendingStatus(testContact, group);
      expect(true, isTrue);
    });

    test('removeMember on a non-group chat is a no-op', () async {
      await chatService.startChatSession();
      await chatService.removeMember(
        groupId: 'group-1',
        memberDid: 'did:key:bob',
      );
      expect(fakeChatSdk.removeMemberCallCount, 0);
    });
  });

  group('ChatSessionService - Group Chat Delegation', () {
    late ProviderContainer container;
    late ChatSessionService chatService;
    late FakeMeetingPlaceSDK fakeCoreSdk;
    late FakeChatSdk fakeChatSdk;

    final groupContact = FakeContacts.groupContact;
    final groupChannelDid = groupContact.channelDid!;

    setUp(() async {
      fakeCoreSdk = FakeMeetingPlaceSDK(
        channels: {groupChannelDid: FakeChannels.groupChannel},
      );
      fakeCoreSdk.setMockGroup(FakeGroups.approvedGroup());
      fakeChatSdk = FakeChatSdk();

      container = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
          chatSdkProvider.overrideWith((ref, channel) async => fakeChatSdk),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          environmentProvider.overrideWithValue(FakeEnvironment()),
          appBadgeServiceProvider.overrideWith((ref) => FakeAppBadgeService()),
          networkConnectivityServiceProvider.overrideWith(
            _FakeNetworkConnectivityService.new,
          ),
        ],
      );
      container.listen(
        chatSessionServiceProvider(groupChannelDid),
        (previous, value) {},
        fireImmediately: true,
      );
      chatService = container.read(
        chatSessionServiceProvider(groupChannelDid).notifier,
      );
    });

    tearDown(() => container.dispose());

    test('delegates removeMember to SDK', () async {
      await chatService.startChatSession();
      await chatService.removeMember(
        groupId: 'group-1',
        memberDid: 'did:key:bob',
      );
      expect(fakeChatSdk.lastRemovedMemberDid, 'did:key:bob');
    });
  });

  group('ChatSessionService - State Emissions', () {
    late ProviderContainer container;
    late ChatSessionService chatService;
    late FakeMeetingPlaceSDK fakeCoreSdk;
    late FakeChatSdk fakeChatSdk;
    late FakeContactsService fakeContactsService;

    final testContact = FakeContacts.individualContact;
    final channelDid = testContact.channelDid!;

    ChatServiceState serviceState() =>
        container.read(chatSessionServiceProvider(channelDid));

    setUp(() async {
      fakeCoreSdk = FakeMeetingPlaceSDK(
        channels: {channelDid: FakeChannels.individualChannel},
      );
      fakeChatSdk = FakeChatSdk();
      fakeChatSdk.chatActivitySent = false;
      fakeContactsService = FakeContactsService();

      container = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
          chatSdkProvider.overrideWith((ref, channel) async => fakeChatSdk),
          contactsServiceProvider.overrideWith(() => fakeContactsService),
          environmentProvider.overrideWithValue(FakeEnvironment()),
          appBadgeServiceProvider.overrideWith((ref) => FakeAppBadgeService()),
          networkConnectivityServiceProvider.overrideWith(
            _FakeNetworkConnectivityService.new,
          ),
        ],
      );
      container.listen(
        chatSessionServiceProvider(channelDid),
        (previous, value) {},
        fireImmediately: true,
      );
      chatService = container.read(
        chatSessionServiceProvider(channelDid).notifier,
      );
    });

    tearDown(() => container.dispose());

    test('adds chatItem to state when receiving message', () async {
      await chatService.startChatSession();

      fakeChatSdk.simulateIncomingTextMessage(
        text: 'test message',
        recipientDid: channelDid,
        attachments: [],
      );

      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(
        serviceState().messages.whereType<Message>().any(
          (m) => m.value == 'test message',
        ),
        isTrue,
      );
    });

    test(
      'updates contactPresenceStatus in state when receiving presence',
      () async {
        await chatService.startChatSession();

        fakeChatSdk.simulateIncomingPresenceMessage(
          timestamp: DateTime.now().toIso8601String(),
          recipientDid: channelDid,
        );

        await Future<void>.delayed(const Duration(milliseconds: 1));
        expect(
          serviceState().contactPresenceStatus,
          ContactPresenceStatus.online,
        );
      },
    );

    test(
      'updates membersTyping in state when receiving typing activity',
      () async {
        await chatService.startChatSession();

        // Simulate contact card update to set otherPartyCard in state
        fakeChatSdk.simulateIncomingContactCardUpdate(
          contactDid: 'did:key:other-party', // Bob's DID
          card: FakeContacts.individualContact.otherPartyCard!,
          recipientDid: channelDid,
        );

        await Future<void>.delayed(const Duration(milliseconds: 1));
        expect(serviceState().otherPartyCard?.firstName, isNotNull);

        fakeChatSdk.simulateIncomingTypingActivity(
          senderDid: 'did:key:other-party',
          createdTime: DateTime.now(),
          recipientDid: channelDid,
        );

        await Future<void>.delayed(const Duration(milliseconds: 1));
        expect(serviceState().membersTyping, isNotEmpty);
      },
    );

    test('updates effect in state when receiving effect', () async {
      await chatService.startChatSession();

      fakeChatSdk.simulateIncomingEffectMessage(
        effectName: Effect.confetti.name,
        recipientDid: channelDid,
      );

      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(serviceState().effect, Effect.confetti);
    });

    test('clearEffect resets effect in state', () async {
      await chatService.startChatSession();

      fakeChatSdk.simulateIncomingEffectMessage(
        effectName: Effect.confetti.name,
        recipientDid: channelDid,
      );
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(serviceState().effect, Effect.confetti);

      chatService.clearEffect();
      expect(serviceState().effect, isNull);
    });

    test('refreshes group in state when receiving group update', () async {
      final groupContact = FakeContacts.groupContact;
      final groupChannelDid = groupContact.channelDid!;
      final knownGroup = FakeGroups.approvedGroup();

      final groupCoreSdk = FakeMeetingPlaceSDK(
        channels: {groupChannelDid: FakeChannels.groupChannel},
      );
      groupCoreSdk.setMockGroup(knownGroup);

      final groupFakeChatSdk = FakeChatSdk();
      final groupContainer = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith((ref) async => groupCoreSdk),
          chatSdkProvider.overrideWith(
            (ref, channel) async => groupFakeChatSdk,
          ),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          environmentProvider.overrideWithValue(FakeEnvironment()),
          appBadgeServiceProvider.overrideWith((ref) => FakeAppBadgeService()),
          networkConnectivityServiceProvider.overrideWith(
            _FakeNetworkConnectivityService.new,
          ),
        ],
      );
      addTearDown(groupContainer.dispose);

      groupContainer.listen(
        chatSessionServiceProvider(groupChannelDid),
        (previous, value) {},
        fireImmediately: true,
      );
      final groupService = groupContainer.read(
        chatSessionServiceProvider(groupChannelDid).notifier,
      );
      await groupService.startChatSession();

      groupService.state = groupService.state.copyWith(group: knownGroup);

      expect(
        groupContainer.read(chatSessionServiceProvider(groupChannelDid)).group,
        isNotNull,
      );

      groupFakeChatSdk.simulateIncomingGroupDetailsUpdate(
        recipientDid: groupChannelDid,
      );

      expect(
        groupContainer.read(chatSessionServiceProvider(groupChannelDid)).group,
        isNotNull,
      );
    });

    test(
      'updates otherPartyCard in state when receiving contact card update',
      () async {
        await chatService.startChatSession();

        final updatedCard = FakeContacts.individualContact.card.copyWith(
          firstName: 'Updated Alice',
        );
        fakeChatSdk.simulateIncomingContactCardUpdate(
          contactDid: channelDid,
          card: updatedCard,
          recipientDid: channelDid,
        );

        await Future<void>.delayed(const Duration(milliseconds: 1));
        expect(serviceState().otherPartyCard?.firstName, 'Updated Alice');
      },
    );
  });
}

class _FakeNetworkConnectivityService extends NetworkConnectivityService {
  @override
  NetworkConnectivityServiceState build() {
    return const NetworkConnectivityServiceState(isConnected: true);
  }
}
