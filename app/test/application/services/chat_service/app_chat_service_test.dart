import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service.dart';
import 'package:mpx_flutter_reference_app/application/services/network_connectivity_service/network_connectivity_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
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
import 'package:uuid/uuid.dart';

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
import '../../../fakes/fake_identities_service.dart';
import '../../../fakes/fake_meeting_place_sdk.dart';
import '../../../fakes/fake_r_card_repository.dart';
import '../../../fakes/fake_secure_storage.dart';
import '../../../fakes/fake_vrc_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  ChatAttachment bufferedVideoAttachment() => ChatAttachment(
    id: 'buffered-video-id',
    mediaType: 'video/mp4',
    filename: 'video.mp4',
    format: 'fake_buffered_video_plugin',
    byteCount: 5,
    data: ChatAttachmentData(base64: base64Encode([118, 105, 100, 101, 111])),
  );

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

    test(
      'refreshes current contact card again when identity changes mid-session',
      () async {
        final identity = FakeIdentities.primaryIdentity;
        final updatedIdentity = identity.copyWith(
          card: identity.card.copyWith(displayName: 'John Updated'),
        );
        final baseChannel = FakeChannels.individualChannel;
        final channel = Channel(
          permanentChannelDid: baseChannel.permanentChannelDid,
          otherPartyPermanentChannelDid:
              baseChannel.otherPartyPermanentChannelDid,
          offerLink: baseChannel.offerLink,
          contactCard: baseChannel.contactCard,
          otherPartyContactCard: baseChannel.otherPartyContactCard,
          otherPartyNotificationToken: baseChannel.otherPartyNotificationToken,
          seqNo: baseChannel.seqNo,
          type: baseChannel.type,
          publishOfferDid: baseChannel.publishOfferDid,
          mediatorDid: baseChannel.mediatorDid,
          status: baseChannel.status,
          isConnectionInitiator: baseChannel.isConnectionInitiator,
          externalRef: identity.id,
        );
        final fakeIdentitiesService = FakeIdentitiesService(
          IdentitiesServiceState(
            identities: [identity],
            currentIdentity: identity,
          ),
        );

        fakeCoreSdk = FakeMeetingPlaceSDK(channels: {channelDid: channel});
        container.dispose();
        container = ProviderContainer(
          overrides: [
            meetingPlaceSdkProvider.overrideWith((ref) async => fakeCoreSdk),
            chatSdkProvider.overrideWith((ref, channel) async => fakeChatSdk),
            contactsServiceProvider.overrideWith(() => fakeContactsService),
            identitiesServiceProvider.overrideWith(() => fakeIdentitiesService),
            environmentProvider.overrideWithValue(FakeEnvironment()),
            appBadgeServiceProvider.overrideWith(
              (ref) => FakeAppBadgeService(),
            ),
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

        await chatService.startChatSession();
        expect(fakeChatSdk.refreshCurrentContactCardCallCount, equals(0));

        fakeIdentitiesService.setState(
          IdentitiesServiceState(
            identities: [updatedIdentity],
            currentIdentity: updatedIdentity,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(fakeChatSdk.refreshCurrentContactCardCallCount, equals(1));
        expect(
          fakeChatSdk.lastRefreshedCurrentContactCard!.toJson()['contactInfo'],
          equals(
            updatedIdentity.card.toSdkContactCard().toJson()['contactInfo'],
          ),
        );
      },
    );

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

    test(
      'buffers outbound messages while paused and flushes them on resume',
      () async {
        await chatService.startChatSession();
        await chatService.pauseChat();

        await chatService.sendTextMessage(
          '',
          attachments: [bufferedVideoAttachment()],
        );

        expect(fakeChatSdk.sendTextMessageCalls, isEmpty);
        expect(fakeChatSdk.sendMediaMessageCalls, isEmpty);

        await chatService.startChatSession();

        expect(fakeChatSdk.startChatSessionCallCount, equals(2));
        expect(fakeChatSdk.sendTextMessageCalls, hasLength(1));
        expect(fakeChatSdk.sendMediaMessageCalls, hasLength(1));
        expect(
          fakeChatSdk.sendMediaMessageCalls.first['contentType'],
          startsWith('video/'),
        );
        expect(
          fakeChatSdk.sendMediaMessageCalls.first['filename'],
          'video.mp4',
        );
      },
    );

    test('does not flush the same buffered message more than once', () async {
      await chatService.startChatSession();
      await chatService.pauseChat();

      await chatService.sendTextMessage(
        '',
        attachments: [bufferedVideoAttachment()],
      );

      await chatService.startChatSession();

      expect(fakeChatSdk.sendTextMessageCalls, hasLength(1));
      expect(fakeChatSdk.sendMediaMessageCalls, hasLength(1));

      await chatService.pauseChat();
      await chatService.startChatSession();

      expect(fakeChatSdk.startChatSessionCallCount, equals(3));
      expect(fakeChatSdk.sendTextMessageCalls, hasLength(1));
      expect(fakeChatSdk.sendMediaMessageCalls, hasLength(1));
    });

    test(
      '''keeps buffered messages queued when flush send fails without aborting start''',
      () async {
        await chatService.startChatSession();
        await chatService.pauseChat();

        await chatService.sendTextMessage(
          '',
          attachments: [bufferedVideoAttachment()],
        );

        fakeChatSdk.sendTextMessageFailuresRemaining = 1;

        await chatService.startChatSession();

        expect(fakeChatSdk.startChatSessionCallCount, equals(2));
        expect(
          fakeContactsService.resetBadgeCalledWith,
          testContact.channelDid,
        );
        expect(fakeChatSdk.sendTextMessageCalls, isEmpty);
        expect(fakeChatSdk.sendMediaMessageCalls, isEmpty);

        await chatService.pauseChat();
        await chatService.startChatSession();

        expect(fakeChatSdk.startChatSessionCallCount, equals(3));
        expect(fakeChatSdk.sendTextMessageCalls, hasLength(1));
        expect(fakeChatSdk.sendMediaMessageCalls, hasLength(1));
      },
    );

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

    Future<void> waitForState(
      bool Function(ChatServiceState state) predicate,
      void Function() trigger,
    ) async {
      if (predicate(serviceState())) {
        trigger();
        return;
      }

      final completer = Completer<void>();
      late ProviderSubscription<ChatServiceState> subscription;
      subscription = container.listen<ChatServiceState>(
        chatSessionServiceProvider(channelDid),
        (previous, next) {
          if (completer.isCompleted || !predicate(next)) return;
          completer.complete();
          subscription.close();
        },
      );

      trigger();

      if (!completer.isCompleted && predicate(serviceState())) {
        completer.complete();
        subscription.close();
      }

      await completer.future;
    }

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

      await waitForState(
        (state) => state.messages.whereType<Message>().any(
          (message) => message.value == 'test message',
        ),
        () => fakeChatSdk.simulateIncomingTextMessage(
          text: 'test message',
          recipientDid: channelDid,
          attachments: [],
        ),
      );

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

        await waitForState(
          (state) =>
              state.contactPresenceStatus == ContactPresenceStatus.online,
          () => fakeChatSdk.simulateIncomingPresenceMessage(
            timestamp: DateTime.now().toIso8601String(),
            recipientDid: channelDid,
          ),
        );

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
        await waitForState(
          (state) => state.otherPartyCard?.firstName != null,
          () => fakeChatSdk.simulateIncomingContactCardUpdate(
            contactDid: 'did:key:other-party', // Bob's DID
            card: FakeContacts.individualContact.otherPartyCard!,
            recipientDid: channelDid,
          ),
        );

        expect(serviceState().otherPartyCard?.firstName, isNotNull);

        await waitForState(
          (state) => state.membersTyping.isNotEmpty,
          () => fakeChatSdk.simulateIncomingTypingActivity(
            senderDid: 'did:key:other-party',
            createdTime: DateTime.now(),
            recipientDid: channelDid,
          ),
        );

        expect(serviceState().membersTyping, isNotEmpty);
      },
    );

    test('clears membersTyping immediately when a new typing event replaces the'
        ' active timer', () async {
      await chatService.startChatSession();

      await waitForState(
        (state) => state.otherPartyCard?.firstName != null,
        () => fakeChatSdk.simulateIncomingContactCardUpdate(
          contactDid: 'did:key:other-party',
          card: FakeContacts.individualContact.otherPartyCard!,
          recipientDid: channelDid,
        ),
      );

      // First typing event — timer starts, membersTyping is populated.
      await waitForState(
        (state) => state.membersTyping.isNotEmpty,
        () => fakeChatSdk.simulateIncomingTypingActivity(
          senderDid: 'did:key:other-party',
          createdTime: DateTime.now(),
          recipientDid: channelDid,
        ),
      );
      expect(serviceState().membersTyping, isNotEmpty);

      // Second typing event — previous timer is cancelled, state must be
      // cleared synchronously before the new timer populates it again.
      await waitForState(
        (state) => state.membersTyping.isNotEmpty,
        () => fakeChatSdk.simulateIncomingTypingActivity(
          senderDid: 'did:key:other-party',
          createdTime: DateTime.now(),
          recipientDid: channelDid,
        ),
      );
      expect(serviceState().membersTyping, isNotEmpty);
    });

    test(
      'disposing provider while typing timer is active does not throw',
      () async {
        await chatService.startChatSession();

        await waitForState(
          (state) => state.otherPartyCard?.firstName != null,
          () => fakeChatSdk.simulateIncomingContactCardUpdate(
            contactDid: 'did:key:other-party',
            card: FakeContacts.individualContact.otherPartyCard!,
            recipientDid: channelDid,
          ),
        );

        await waitForState(
          (state) => state.membersTyping.isNotEmpty,
          () => fakeChatSdk.simulateIncomingTypingActivity(
            senderDid: 'did:key:other-party',
            createdTime: DateTime.now(),
            recipientDid: channelDid,
          ),
        );
        expect(serviceState().membersTyping, isNotEmpty);

        // Disposing while the timer is still running must not throw the
        // Riverpod 3.x "Cannot modify providers inside life-cycles" assertion.
        expect(() => container.dispose(), returnsNormally);
      },
    );

    test('updates effect in state when receiving effect', () async {
      await chatService.startChatSession();

      await waitForState(
        (state) => state.effect == Effect.confetti,
        () => fakeChatSdk.simulateIncomingEffectMessage(
          effectName: Effect.confetti.name,
          recipientDid: channelDid,
        ),
      );

      expect(serviceState().effect, Effect.confetti);
    });

    test('clearEffect resets effect in state', () async {
      await chatService.startChatSession();

      await waitForState(
        (state) => state.effect == Effect.confetti,
        () => fakeChatSdk.simulateIncomingEffectMessage(
          effectName: Effect.confetti.name,
          recipientDid: channelDid,
        ),
      );
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
        await waitForState(
          (state) => state.otherPartyCard?.firstName == 'Updated Alice',
          () => fakeChatSdk.simulateIncomingContactCardUpdate(
            contactDid: channelDid,
            card: updatedCard,
            recipientDid: channelDid,
          ),
        );

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

      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });

    test('pauseChat cancels rCard subscription without error', () async {
      await chatService.startChatSession();

      await chatService.pauseChat();
      await chatService.pauseChat(); // second call must not throw

      expect(fakeChatSdk.sessionEnded, isTrue);
    });
  });

  group('ChatSessionService - VRC Replay Ordering', () {
    late ProviderContainer container;
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
    });

    tearDown(() => container.dispose());
  });

  group('ChatSessionService - Call Chat Item', () {
    late ProviderContainer container;
    late ChatSessionService chatService;
    late FakeMeetingPlaceSDK fakeCoreSdk;
    late FakeChatSdk fakeChatSdk;
    late FakeContactsService fakeContactsService;

    final testContact = FakeContacts.individualContact;
    final channelDid = testContact.channelDid!;

    Message callMessage({
      required String messageId,
      required bool isFromMe,
      required CallStatus status,
    }) => Message(
      chatId: 'fake-chat-id',
      messageId: messageId,
      value: '',
      dateCreated: DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: isFromMe,
      senderDid: isFromMe ? 'me' : channelDid,
      attachments: [
        CallMetadata.buildAttachment(
          id: const Uuid().v4(),
          mediaType: CallMediaType.video,
          status: status,
          callId: '',
        ),
      ],
    );

    setUp(() async {
      fakeCoreSdk = FakeMeetingPlaceSDK(
        channels: {channelDid: FakeChannels.individualChannel},
      );
      fakeChatSdk = FakeChatSdk();
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

    test('sendOutgoingCallMessage sends a call item over the wire '
        'and returns its id', () async {
      final messageId = await chatService.sendOutgoingCallMessage(
        mediaType: CallMediaType.audio,
        callId: 'test-call-id',
      );

      expect(messageId, isNotNull);
      expect(fakeChatSdk.sendTextMessageCalls, hasLength(1));
      final sent = fakeChatSdk.sendTextMessageCalls.single;
      expect(sent['text'], '');
      final attachments = sent['attachments'] as List<ChatAttachment>;
      expect(CallMetadata.isCall(attachments.single), isTrue);
      final call = CallMetadata.maybeOf(attachments.single);
      expect(call?.mediaType, CallMediaType.audio);
      expect(call?.status, CallStatus.calling);
    });

    test('resolveIncomingCallChatItemId returns the latest non-terminal '
        'incoming call item', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'old-incoming',
          isFromMe: false,
          status: CallStatus.calling,
        ),
        callMessage(
          messageId: 'my-call',
          isFromMe: true,
          status: CallStatus.calling,
        ),
        callMessage(
          messageId: 'latest-incoming',
          isFromMe: false,
          status: CallStatus.calling,
        ),
      ];

      final resolved = await chatService.resolveIncomingCallChatItemId();

      expect(resolved, 'latest-incoming');
    });

    test('resolveIncomingCallChatItemId returns null when only terminal or '
        'own call items exist', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'ended-incoming',
          isFromMe: false,
          status: CallStatus.ended,
        ),
        callMessage(
          messageId: 'my-call',
          isFromMe: true,
          status: CallStatus.calling,
        ),
      ];

      final resolved = await chatService.resolveIncomingCallChatItemId();

      expect(resolved, isNull);
    });

    test('resolveOutgoingCallChatItemId returns the latest non-terminal '
        'outgoing call item', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'their-call',
          isFromMe: false,
          status: CallStatus.calling,
        ),
        callMessage(
          messageId: 'old-mine',
          isFromMe: true,
          status: CallStatus.calling,
        ),
        callMessage(
          messageId: 'latest-mine',
          isFromMe: true,
          status: CallStatus.ringing,
        ),
      ];

      final resolved = await chatService.resolveOutgoingCallChatItemId();

      expect(resolved, 'latest-mine');
    });

    test('resolveOutgoingCallChatItemId returns null when only terminal or '
        'incoming call items exist', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'ended-mine',
          isFromMe: true,
          status: CallStatus.ended,
        ),
        callMessage(
          messageId: 'their-call',
          isFromMe: false,
          status: CallStatus.calling,
        ),
      ];

      final resolved = await chatService.resolveOutgoingCallChatItemId();

      expect(resolved, isNull);
    });

    test('updateCallChatItem updates call attachment status on an existing '
        'call message', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'call-msg-1',
          isFromMe: true,
          status: CallStatus.calling,
        ),
      ];

      await chatService.updateCallChatItem(
        'call-msg-1',
        status: CallStatus.ended,
        duration: const Duration(seconds: 30),
      );

      expect(fakeChatSdk.updateMessageCalls, hasLength(1));
      final updated = fakeChatSdk.updateMessageCalls.single;
      final call = CallMetadata.maybeOf(
        updated.attachments.firstWhere(CallMetadata.isCall),
      );
      expect(call?.status, CallStatus.ended);
      expect(call?.durationMs, 30000);
    });

    test(
      'updateCallChatItem is a no-op when the message id does not exist',
      () async {
        fakeChatSdk.sessionMessages = [];

        await chatService.updateCallChatItem(
          'missing-id',
          status: CallStatus.ended,
        );

        expect(fakeChatSdk.updateMessageCalls, isEmpty);
      },
    );

    test('markCallAsMissed returns true and updates the latest non-terminal '
        'incoming call item to missed', () async {
      fakeContactsService.setContacts([FakeContacts.individualContact]);
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'incoming-call',
          isFromMe: false,
          status: CallStatus.calling,
        ),
      ];

      await chatService.startChatSession();
      await fakeContactsService.setPendingMissedCall(channelDid);
      final healed = await chatService.markCallAsMissed();

      expect(healed, isTrue);
      expect(fakeChatSdk.updateMessageCalls, hasLength(1));
      final updated = fakeChatSdk.updateMessageCalls.single;
      expect(updated.messageId, 'incoming-call');
      final call = CallMetadata.maybeOf(
        updated.attachments.firstWhere(CallMetadata.isCall),
      );
      expect(call?.status, CallStatus.missed);
    });

    test(
      'startChatSession keeps the pending missed-call marker available for '
      'follow-up healing when no stale item exists during initial replay',
      () async {
        fakeContactsService.setContacts([
          Contact(
            id: testContact.id,
            channelDid: testContact.channelDid,
            channelDidSha256: testContact.channelDidSha256,
            offerLink: testContact.offerLink,
            card: testContact.card,
            dateAdded: testContact.dateAdded,
            type: testContact.type,
            status: testContact.status,
            mediatorDid: testContact.mediatorDid,
            origin: testContact.origin,
            category: testContact.category,
            otherPartyCard: testContact.otherPartyCard,
            displayName: testContact.displayName,
            badgeUpdateInProgress: testContact.badgeUpdateInProgress,
            badgeCount: testContact.badgeCount,
            currentMessageSeqNo: testContact.currentMessageSeqNo,
            missedCallCount: testContact.missedCallCount,
            pendingMissedCallAt: DateTime.now().toUtc().subtract(
              const Duration(seconds: 5),
            ),
            hasBeenOpened: testContact.hasBeenOpened,
            lastKeepAliveMessage: testContact.lastKeepAliveMessage,
            notificationBannerDismissed:
                testContact.notificationBannerDismissed,
          ),
        ]);
        fakeChatSdk.sessionMessages = [fakeChatSdk.fakeMessage()];

        await chatService.startChatSession();
        await pumpEventQueue();

        expect(fakeChatSdk.updateMessageCalls, isEmpty);
        expect(
          await fakeContactsService.getPendingMissedCallAt(channelDid),
          isNotNull,
        );
      },
    );

    test('markCallAsMissed is a no-op when there is no pending incoming call '
        'item', () async {
      fakeChatSdk.sessionMessages = [
        callMessage(
          messageId: 'ended-incoming',
          isFromMe: false,
          status: CallStatus.ended,
        ),
      ];

      await chatService.startChatSession();
      final healed = await chatService.markCallAsMissed();

      expect(healed, isFalse);
      expect(fakeChatSdk.updateMessageCalls, isEmpty);
    });
  });
}

class _FakeNetworkConnectivityService extends NetworkConnectivityService {
  @override
  NetworkConnectivityServiceState build() {
    return const NetworkConnectivityServiceState(isConnected: true);
  }
}
