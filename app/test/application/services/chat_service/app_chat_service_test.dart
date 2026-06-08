import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_presence_status.dart';
import 'package:mpx_flutter_reference_app/infrastructure/configuration/environment.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_badge_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/credentials_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/r_cards_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/vrc_repository_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/secure_storage/secure_storage.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/unsent_messages_service/unsent_messages_service.dart';
import 'package:ssi/ssi.dart';

import '../../../fakes/fake_app_badge_service.dart';
import '../../../fakes/fake_channels.dart';
import '../../../fakes/fake_chat_repository.dart';
import '../../../fakes/fake_chat_sdk.dart';
import '../../../fakes/fake_contacts.dart';
import '../../../fakes/fake_contacts_service.dart';
import '../../../fakes/fake_credentials_sdk.dart';
import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_groups.dart';
import '../../../fakes/fake_identities.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';
import '../../../fakes/fake_r_card_repository.dart';
import '../../../fakes/fake_secure_storage.dart';
import '../../../fakes/fake_vrc_repository.dart';

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
          rCardsRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpRCardRepository(),
          ),
          vrcRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpVrcRepository(),
          ),
          secureStorageProvider.overrideWith(
            (ref) async => FakeSecureStorage(),
          ),
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
      chatService.pauseChat();
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
        attachments: [Attachment(id: '1')],
      );
      expect(fakeChatSdk.sendTextMessageCalls.last['attachments'], isNotEmpty);
    });

    test('pauseChat can be called multiple times safely', () async {
      await chatService.startChatSession();
      chatService.pauseChat();
      chatService.pauseChat();
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
          rCardsRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpRCardRepository(),
          ),
          vrcRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpVrcRepository(),
          ),
          secureStorageProvider.overrideWith(
            (ref) async => FakeSecureStorage(),
          ),
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

    test('clears membersTyping immediately when a new typing event replaces the'
        ' active timer', () async {
      await chatService.startChatSession();

      fakeChatSdk.simulateIncomingContactCardUpdate(
        contactDid: 'did:key:other-party',
        card: FakeContacts.individualContact.otherPartyCard!,
        recipientDid: channelDid,
      );
      await Future<void>.delayed(const Duration(milliseconds: 1));

      // First typing event — timer starts, membersTyping is populated.
      fakeChatSdk.simulateIncomingTypingActivity(
        senderDid: 'did:key:other-party',
        createdTime: DateTime.now(),
        recipientDid: channelDid,
      );
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(serviceState().membersTyping, isNotEmpty);

      // Second typing event — previous timer is cancelled, state must be
      // cleared synchronously before the new timer populates it again.
      fakeChatSdk.simulateIncomingTypingActivity(
        senderDid: 'did:key:other-party',
        createdTime: DateTime.now(),
        recipientDid: channelDid,
      );
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(serviceState().membersTyping, isNotEmpty);
    });

    test(
      'disposing provider while typing timer is active does not throw',
      () async {
        await chatService.startChatSession();

        fakeChatSdk.simulateIncomingContactCardUpdate(
          contactDid: 'did:key:other-party',
          card: FakeContacts.individualContact.otherPartyCard!,
          recipientDid: channelDid,
        );
        await Future<void>.delayed(const Duration(milliseconds: 1));

        fakeChatSdk.simulateIncomingTypingActivity(
          senderDid: 'did:key:other-party',
          createdTime: DateTime.now(),
          recipientDid: channelDid,
        );
        await Future<void>.delayed(const Duration(milliseconds: 1));
        expect(serviceState().membersTyping, isNotEmpty);

        // Disposing while the timer is still running must not throw the
        // Riverpod 3.x "Cannot modify providers inside life-cycles" assertion.
        expect(() => container.dispose(), returnsNormally);
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
          rCardsRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpRCardRepository(),
          ),
          vrcRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpVrcRepository(),
          ),
          secureStorageProvider.overrideWith(
            (ref) async => FakeSecureStorage(),
          ),
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

    test(
      'preserves messages added to state during replay after startChatSession',
      () async {
        final replayMessage = EventMessage(
          chatId: 'fake-chat-id',
          messageId: 'replay-vrc-request-id',
          senderDid: channelDid,
          isFromMe: false,
          dateCreated: DateTime.now(),
          status: ChatItemStatus.received,
          eventType: EventMessageType.fromJson('vrcRequestReceived'),
          data: const {},
        );
        chatService.state = chatService.state.copyWith(
          messages: [replayMessage],
        );

        await chatService.startChatSession();

        expect(
          serviceState().messages.any(
            (m) => m.messageId == 'replay-vrc-request-id',
          ),
          isTrue,
        );
      },
    );
  });

  group('ChatSessionService - R-Card Integration', () {
    late ProviderContainer container;
    late ChatSessionService chatService;
    late FakeMeetingPlaceSDK fakeCoreSdk;
    late FakeChatSdk fakeChatSdk;
    late DidKeyManager issuerManager;
    late String issuerDid;

    final testContact = FakeContacts.individualContact;
    final channelDid = testContact.channelDid!;

    setUpAll(() async {
      final wallet = PersistentWallet(InMemoryKeyStore());
      issuerManager = DidKeyManager(wallet: wallet, store: InMemoryDidStore());
      final keyPair = await wallet.generateKey();
      await issuerManager.addVerificationMethod(keyPair.id);
      final didDoc = await issuerManager.getDidDocument();
      issuerDid = didDoc.id;
    });

    Channel makeChannel({
      String? permanentChannelDid,
      String? otherPartyPermanentChannelDid,
    }) {
      return Channel(
        offerLink: 'test-offer-link',
        publishOfferDid: 'did:key:publisher',
        mediatorDid: 'did:key:mediator',
        status: ChannelStatus.inaugurated,
        contactCard: FakeContacts.individualContact.card.toSdkContactCard(),
        outboundMessageId: 'msg-1',
        acceptOfferDid: 'did:key:accept',
        permanentChannelDid: permanentChannelDid ?? issuerDid,
        otherPartyPermanentChannelDid:
            otherPartyPermanentChannelDid ?? channelDid,
        type: ChannelType.individual,
        isConnectionInitiator: false,
      );
    }

    ProviderContainer makeContainer(FakeMeetingPlaceSDK coreSdk) {
      final c = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith((ref) async => coreSdk),
          chatSdkProvider.overrideWith((ref, channel) async => fakeChatSdk),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          environmentProvider.overrideWithValue(FakeEnvironment()),
          appBadgeServiceProvider.overrideWith((ref) => FakeAppBadgeService()),
          rCardsRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpRCardRepository(),
          ),
          vrcRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpVrcRepository(),
          ),
          networkConnectivityServiceProvider.overrideWith(
            _FakeNetworkConnectivityService.new,
          ),
        ],
      );
      c.listen(
        chatSessionServiceProvider(channelDid),
        (previous, value) {},
        fireImmediately: true,
      );
      return c;
    }

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      fakeCoreSdk = FakeMeetingPlaceSDK(channels: {channelDid: makeChannel()});
      fakeCoreSdk.setFakeDidManager(issuerManager);
      container = makeContainer(fakeCoreSdk);
      chatService = container.read(
        chatSessionServiceProvider(channelDid).notifier,
      );
    });

    tearDown(() => container.dispose());

    test('sendRCardFromPlugin calls createAttachmentMessage', () async {
      await chatService.startChatSession();

      await chatService.sendRCardFromPlugin(FakeIdentities.primaryIdentity);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeChatSdk.createAttachmentMessageCalls, hasLength(1));
    });

    test('sendRCardFromPlugin is a no-op when channel is not found', () async {
      final noChannelSdk = FakeMeetingPlaceSDK(channels: {});
      final noChannelContainer = makeContainer(noChannelSdk);
      addTearDown(noChannelContainer.dispose);

      noChannelContainer.listen(
        chatSessionServiceProvider(channelDid),
        (previous, value) {},
        fireImmediately: true,
      );
      final service = noChannelContainer.read(
        chatSessionServiceProvider(channelDid).notifier,
      );
      await service.startChatSession();

      await service.sendRCardFromPlugin(FakeIdentities.primaryIdentity);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test('sendRCardFromPlugin silently skips when channel '
        'lacks permanentChannelDid', () async {
      final incompleteChannel = Channel(
        offerLink: 'link',
        publishOfferDid: 'did:key:pub',
        mediatorDid: 'did:key:med',
        status: ChannelStatus.inaugurated,
        contactCard: FakeContacts.individualContact.card.toSdkContactCard(),
        outboundMessageId: 'msg',
        acceptOfferDid: 'did:key:acc',
        permanentChannelDid: null,
        otherPartyPermanentChannelDid: null,
        type: ChannelType.individual,
        isConnectionInitiator: false,
      );
      final sdkWithIncompleteChannel = FakeMeetingPlaceSDK(
        channels: {channelDid: incompleteChannel},
      );
      sdkWithIncompleteChannel.setFakeDidManager(issuerManager);
      final c = makeContainer(sdkWithIncompleteChannel);
      addTearDown(c.dispose);

      final service = c.read(chatSessionServiceProvider(channelDid).notifier);
      await service.startChatSession();

      await service.sendRCardFromPlugin(FakeIdentities.primaryIdentity);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test('pauseChat cancels rCard subscription without error', () async {
      await chatService.startChatSession();

      chatService.pauseChat();
      chatService.pauseChat(); // second call must not throw

      expect(fakeChatSdk.sessionEnded, isTrue);
    });
  });

  group('ChatSessionService - VRC Replay Ordering', () {
    late ProviderContainer container;
    late ChatSessionService chatService;
    late FakeMeetingPlaceSDK fakeCoreSdk;
    late FakeChatSdk fakeChatSdk;
    late DidKeyManager peerDidManager;
    late DidKeyManager localDidManager;
    late String peerDid;
    late String localIdentityDid;
    late String peerVcBlob;

    final testContact = FakeContacts.individualContact;
    final channelDid = testContact.channelDid!;

    Channel makeChannel() => Channel(
      offerLink: 'test-offer-link',
      publishOfferDid: 'did:key:publisher',
      mediatorDid: 'did:key:mediator',
      status: ChannelStatus.inaugurated,
      contactCard: FakeContacts.individualContact.card.toSdkContactCard(),
      outboundMessageId: 'msg-1',
      acceptOfferDid: 'did:key:accept',
      permanentChannelDid: localIdentityDid,
      otherPartyPermanentChannelDid: channelDid,
      type: ChannelType.individual,
      isConnectionInitiator: true,
    );

    setUpAll(() async {
      final peerWallet = PersistentWallet(InMemoryKeyStore());
      peerDidManager = DidKeyManager(
        wallet: peerWallet,
        store: InMemoryDidStore(),
      );
      await peerWallet.generateKey().then(
        (kp) => peerDidManager.addVerificationMethod(kp.id),
      );
      peerDid = (await peerDidManager.getDidDocument()).id;

      final localWallet = PersistentWallet(InMemoryKeyStore());
      localDidManager = DidKeyManager(
        wallet: localWallet,
        store: InMemoryDidStore(),
      );
      await localWallet.generateKey().then(
        (kp) => localDidManager.addVerificationMethod(kp.id),
      );
      localIdentityDid = (await localDidManager.getDidDocument()).id;

      final vc = await CredentialBuilder.buildVrc(
        issuerDid: peerDid,
        subject: VrcCredentialSubject(
          from: VrcParty(did: peerDid, name: 'Bob'),
          to: VrcParty(did: localIdentityDid, name: 'Alice'),
        ),
        issuerDidManager: peerDidManager,
      );
      peerVcBlob = jsonEncode(vc.toJson());
    });

    setUp(() {
      fakeChatSdk = FakeChatSdk();
      fakeChatSdk.sessionMessages = [
        EventMessage(
          chatId: 'fake-chat-id',
          messageId: 'vrc-initiated-event-id',
          senderDid: localIdentityDid,
          isFromMe: true,
          dateCreated: DateTime.now().subtract(const Duration(hours: 1)),
          status: ChatItemStatus.confirmed,
          eventType: EventMessageType.fromJson('vrcExchangeInitiated'),
          data: {'identityDid': localIdentityDid, 'identityName': 'Alice'},
        ),
      ];

      fakeCoreSdk = FakeMeetingPlaceSDK(channels: {channelDid: makeChannel()});
      fakeCoreSdk.setFakeDidManager(localDidManager);

      final pendingVrc = VrcIssuance(
        senderDid: peerDid,
        vcBlob: peerVcBlob,
        parsedCredential: UniversalParser.parse(peerVcBlob),
      );

      container = ProviderContainer(
        overrides: [
          meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
          chatSdkProvider.overrideWith((ref, channel) async => fakeChatSdk),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          environmentProvider.overrideWithValue(FakeEnvironment()),
          appBadgeServiceProvider.overrideWith((ref) => FakeAppBadgeService()),
          rCardsRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpRCardRepository(),
          ),
          vrcRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpVrcRepository(),
          ),
          secureStorageProvider.overrideWith(
            (ref) async => FakeSecureStorage(),
          ),
          networkConnectivityServiceProvider.overrideWith(
            _FakeNetworkConnectivityService.new,
          ),
          chatRepositoryProvider.overrideWith(
            (ref) async => FakeNoOpChatRepository(),
          ),
          credentialsSdkProvider.overrideWith((ref) async {
            final coreSDK = await ref.read(meetingPlaceSdkProvider.future);
            final rCardRepo = await ref.read(rCardsRepositoryProvider.future);
            final vrcRepo = await ref.read(vrcRepositoryProvider.future);
            return StubCredentialsSdk(
              coreSDK: coreSDK,
              rCardRepository: rCardRepo,
              vrcRepository: vrcRepo,
              pendingVrc: pendingVrc,
            );
          }),
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

    test(
      'reciprocates VRC when state.messages is populated before replay runs',
      () async {
        await chatService.startChatSession();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(
          fakeChatSdk.createAttachmentMessageCalls
              .where((c) => c.senderDid == localIdentityDid)
              .toList(),
          hasLength(1),
        );
      },
    );

    test('shows incoming VRC chat item when pending VRC is replayed '
        'on session open', () async {
      await chatService.startChatSession();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
        fakeChatSdk.createAttachmentMessageCalls
            .where((c) => c.senderDid == channelDid)
            .toList(),
        hasLength(1),
      );
    });
  });
}

class _FakeNetworkConnectivityService extends NetworkConnectivityService {
  @override
  NetworkConnectivityServiceState build() {
    return const NetworkConnectivityServiceState(isConnected: true);
  }
}
