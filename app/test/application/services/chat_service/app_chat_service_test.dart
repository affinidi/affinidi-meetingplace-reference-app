import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/app_chat_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_presence_status.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
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

  group('AppChatService - Session & SDK Delegation', () {
    late ProviderContainer container;
    late AppChatService chatService;
    late FakeMeetingPlaceSDK fakeCoreSdk;
    late FakeChatSdk fakeChatSdk;
    late Contact testContact;
    late FakeContactsService fakeContactsService;

    setUp(() async {
      testContact = FakeContacts.individualContact;
      fakeCoreSdk = FakeMeetingPlaceSDK(
        channels: {testContact.channelDid!: FakeChannels.individualChannel},
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
        ],
      );
      container.listen(
        appChatServiceProvider.notifier,
        (previous, value) {},
        fireImmediately: true,
      );
      chatService = container.read(appChatServiceProvider.notifier);

      final knownGroup = FakeGroups.approvedGroup();
      fakeCoreSdk.setMockGroup(knownGroup);
    });

    test('sets session state and delegates to SDK on start', () async {
      await chatService.startChatSession(contact: testContact);

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
      await chatService.startChatSession(contact: testContact);
      await chatService.sendTextMessage('hello');
      expect(fakeChatSdk.sendTextMessageCalls.last['text'], 'hello');
    });

    test('delegates sendChatActivity to SDK', () async {
      await chatService.startChatSession(contact: testContact);
      await chatService.sendChatActivity();
      expect(fakeChatSdk.chatActivitySent, true);
    });

    test('delegates rejectConnectionRequest to SDK', () async {
      await chatService.startChatSession(contact: testContact);
      final fakeMessage = fakeChatSdk.fakeConciergeMessage();
      await chatService.rejectConnectionRequest(fakeMessage);
      expect(fakeChatSdk.lastRejectedConnection, fakeMessage);
    });

    test('delegates approveConnectionRequest to SDK', () async {
      await chatService.startChatSession(contact: testContact);
      final fakeMessage = fakeChatSdk.fakeConciergeMessage();
      await chatService.approveConnectionRequest(fakeMessage);
      expect(fakeChatSdk.lastApprovedConnection, fakeMessage);
    });

    test('delegates sendChatContactDetailsUpdate to SDK', () async {
      await chatService.startChatSession(contact: testContact);
      final fakeMessage = fakeChatSdk.fakeConciergeMessage();
      await chatService.sendChatContactDetailsUpdate(fakeMessage);
      expect(fakeChatSdk.lastContactDetailsUpdateSent, fakeMessage);
    });

    test('delegates rejectChatContactDetailsUpdate to SDK', () async {
      await chatService.startChatSession(contact: testContact);
      final fakeMessage = fakeChatSdk.fakeConciergeMessage();
      await chatService.rejectChatContactDetailsUpdate(fakeMessage);
      expect(fakeChatSdk.lastContactDetailsUpdateRejected, fakeMessage);
    });

    test('delegates reactOnMessage to SDK', () async {
      await chatService.startChatSession(contact: testContact);
      final fakeMessage = fakeChatSdk.fakeMessage();
      await chatService.reactOnMessage(fakeMessage, reaction: '👍');
      expect(fakeChatSdk.lastReactionMessage, fakeMessage);
      expect(fakeChatSdk.lastReaction, '👍');
    });

    test('delegates sendEffect to SDK', () async {
      await chatService.startChatSession(contact: testContact);
      await chatService.sendEffect(Effect.confetti);
      expect(fakeChatSdk.lastEffectSent, Effect.confetti.name);
    });

    test('ends session and cancels subscription on disposeChat', () async {
      await chatService.startChatSession(contact: testContact);
      chatService.disposeChat();
      expect(fakeChatSdk.sessionEnded, true);
    });

    test('resets badge count on resetBadgeCount', () async {
      await chatService.startChatSession(contact: testContact);
      await chatService.resetBadgeCount();
      expect(fakeContactsService.resetBadgeCalledWith, testContact.channelDid);
    });

    test('skips badge reset when channel is missing on start', () async {
      final missingContact = FakeContacts.individualContact.copyWith(
        channelDid: 'did:key:missing',
      );
      await chatService.startChatSession(contact: missingContact);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(fakeContactsService.resetBadgeCalledWith, isNull);
    });

    test(
      'skips badge reset when channelDid is null on resetBadgeCount',
      () async {
        final contact = FakeContacts.individualContact.copyWith(
          channelDid: null,
        );
        await chatService.startChatSession(contact: contact);
        await chatService.resetBadgeCount();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(fakeContactsService.resetBadgeCalledWith, isNull);
      },
    );

    test('logs error and skips badge reset when SDK throws on start', () async {
      fakeChatSdk.shouldThrowOnStartSession = true;
      await chatService.startChatSession(contact: testContact);
      expect(fakeContactsService.resetBadgeCalledWith, isNull);
      expect(fakeChatSdk.startChatSessionCallCount, equals(1));
      expect(fakeChatSdk.sessionEnded, isFalse);
      expect(fakeChatSdk.sendTextMessageCalls, isEmpty);
    });

    test('updates contact sequence number', () async {
      await chatService.startChatSession(contact: testContact);
      await chatService.updateContactSequenceNumber(testContact.channelDid!);
      expect(fakeContactsService.updateContactCalls, isNotEmpty);
    });

    test('delegates sendTextMessage with attachments to SDK', () async {
      await chatService.startChatSession(contact: testContact);
      await chatService.sendTextMessage(
        'hello',
        attachments: [Attachment(id: '1')],
      );
      expect(fakeChatSdk.sendTextMessageCalls.last['attachments'], isNotEmpty);
    });

    test('disposeChat can be called multiple times safely', () async {
      await chatService.startChatSession(contact: testContact);
      chatService.disposeChat();
      chatService.disposeChat();
      expect(fakeChatSdk.sessionEnded, true);
    });

    test('restores unsent message for contact when message exists', () async {
      await chatService.startChatSession(contact: testContact);

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

    test('refreshes group returns valid group for known group', () async {
      await chatService.startChatSession(contact: testContact);
      final knownGroup = FakeGroups.approvedGroup();

      final group = await chatService.refreshGroup(knownGroup.id);
      expect(group, isNotNull);
      expect(group!.id, knownGroup.id);
    });

    test('refreshes group returns null for unknown group', () async {
      await chatService.startChatSession(contact: testContact);
      final group = await chatService.refreshGroup('unknown-group-id');
      expect(group, isNull);
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
      await chatService.startChatSession(
        contact: FakeContacts.individualContact,
      );

      final group = FakeGroups.approvedGroup();

      await chatService.updateGroupContactPendingStatus(
        FakeContacts.individualContact,
        group,
      );
      expect(true, isTrue);
    });
  });

  group('AppChatService - Stream Emissions', () {
    late ProviderContainer container;
    late AppChatService chatService;
    late FakeMeetingPlaceSDK fakeCoreSdk;
    late FakeChatSdk fakeChatSdk;
    late Contact testContact;
    late FakeContactsService fakeContactsService;

    setUp(() async {
      testContact = FakeContacts.individualContact;
      fakeCoreSdk = FakeMeetingPlaceSDK(
        channels: {testContact.channelDid!: FakeChannels.individualChannel},
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
        ],
      );
      container.listen(
        appChatServiceProvider.notifier,
        (previous, value) {},
        fireImmediately: true,
      );
      chatService = container.read(appChatServiceProvider.notifier);
    });

    test('emits chatItem stream when receiving message', () async {
      final receivedMessages = <Message>[];
      final subscription = chatService.chatItem.listen((item) {
        if (item is Message) {
          receivedMessages.add(item);
        }
      });

      await chatService.startChatSession(contact: testContact);

      fakeChatSdk.simulateIncomingTextMessage(
        text: 'test message',
        recipientDid: testContact.channelDid!,
        attachments: [],
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      expect(
        receivedMessages.any((Message m) => m.value == 'test message'),
        isTrue,
      );
    });

    test('emits presence stream when receiving presence', () async {
      await chatService.startChatSession(contact: testContact);

      final receivedPresence = <DateTime>[];
      final subscription = chatService.presence.listen(receivedPresence.add);

      fakeChatSdk.simulateIncomingPresenceMessage(
        timestamp: DateTime.now().toIso8601String(),
        recipientDid: testContact.channelDid!,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      expect(receivedPresence, isNotEmpty);
    });

    test('emits typing stream when receiving typing activity', () async {
      await chatService.startChatSession(contact: testContact);

      final receivedTyping = <String?>[];
      final subscription = chatService.typingMembers.listen(receivedTyping.add);

      fakeChatSdk.simulateIncomingTypingActivity(
        senderDid: testContact.channelDid!,
        createdTime: DateTime.now(),
        recipientDid: testContact.channelDid!,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      expect(receivedTyping, contains(testContact.channelDid));
    });

    test('emits effect stream when receiving effect', () async {
      await chatService.startChatSession(contact: testContact);

      final receivedEffects = <String?>[];
      final subscription = chatService.effect.listen((effect) {
        if (effect != null) {
          receivedEffects.add(effect);
        }
      });

      fakeChatSdk.simulateIncomingEffectMessage(
        effectName: Effect.confetti.name,
        recipientDid: testContact.channelDid!,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      expect(receivedEffects, isNotEmpty);
      expect(receivedEffects, contains(Effect.confetti.name));
    });

    test('emits groupDetails stream when receiving group update', () async {
      await chatService.startChatSession(contact: testContact);

      final receivedGroupDetails = <StreamData>[];
      final subscription = chatService.groupDetails.listen(
        receivedGroupDetails.add,
      );

      fakeChatSdk.simulateIncomingGroupDetailsUpdate(
        recipientDid: testContact.channelDid!,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      expect(receivedGroupDetails, isNotEmpty);

      final groupUpdateMessage = receivedGroupDetails.first.plainTextMessage;
      expect(groupUpdateMessage, isNotNull);
      expect(
        groupUpdateMessage!.type.toString(),
        ChatProtocol.chatGroupDetailsUpdate.value,
      );

      if (groupUpdateMessage.body != null) {
        expect(groupUpdateMessage.body!['groupDid'], testContact.channelDid);
        expect(
          groupUpdateMessage.body!['adminDids'],
          contains(testContact.channelDid),
        );
      }
    });

    test('emits otherPartyContactCardUpdate stream'
        ' when receiving contact card update', () async {
      await chatService.startChatSession(contact: testContact);

      final receivedCards = <ContactCard>[];
      final subscription = chatService.otherPartyContactCardUpdate.listen(
        receivedCards.add,
      );

      final updatedCard = FakeContacts.individualContact.card.copyWith(
        firstName: 'Updated Alice',
      );
      fakeChatSdk.simulateIncomingContactCardUpdate(
        contactDid: testContact.channelDid!,
        card: updatedCard,
        recipientDid: testContact.channelDid!,
      );

      await Future<void>.delayed(const Duration(milliseconds: 100));
      await subscription.cancel();

      expect(
        receivedCards.any((card) => card.firstName == 'Updated Alice'),
        isTrue,
      );
    });
  });
}
