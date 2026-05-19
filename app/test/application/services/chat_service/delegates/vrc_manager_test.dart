import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/vrc_manager.dart';
import 'package:mpx_flutter_reference_app/application/services/vrc_service/vrc_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/chat_repository_provider.dart';

import '../../../../fakes/fake_chat_repository.dart';
import '../../../../fakes/fake_chat_sdk.dart';
import '../../../../fakes/fake_vrc_service.dart';

final _refProvider = Provider<Ref>((ref) => ref);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppLogger.initialize(File('${Directory.systemTemp.path}/app_debug_test.log'));

  group('VrcManager', () {
    const channelDid = 'did:key:channel';
    const chatId = 'chat-abc-123';

    late ProviderContainer container;
    late FakeVrcService fakeVrcService;
    late FakeInMemoryChatRepository fakeRepo;
    late FakeChatSdk fakeChatSdk;
    late List<ChatItem> upsertedItems;
    late List<ChatItem> removedItems;
    late List<ChatItem> messages;

    VrcManager makeDelegate({
      String? Function()? getChatId,
      List<ChatItem> Function()? getMessages,
    }) {
      return VrcManager(
        ref: container.read(_refProvider),
        getChatId: getChatId ?? () => chatId,
        logger: AppLogger.instance,
        getChatSdk: () => fakeChatSdk,
        getMessages: getMessages ?? () => messages,
        upsertChatItem: upsertedItems.add,
        removeChatItem: removedItems.add,
      );
    }

    late VrcManager delegate;

    setUp(() {
      messages = [];
      upsertedItems = [];
      removedItems = [];
      fakeChatSdk = FakeChatSdk();
      fakeRepo = FakeInMemoryChatRepository();
      fakeVrcService = FakeVrcService();

      container = ProviderContainer(
        overrides: [
          vrcServiceProvider.overrideWith(() => fakeVrcService),
          chatRepositoryProvider.overrideWith((ref) async => fakeRepo),
        ],
      );

      delegate = makeDelegate();
    });

    tearDown(() {
      container.dispose();
    });

    test('persistLocalEventMessage — persists EventMessage '
        'to repository and calls upsertChatItem', () async {
      await delegate.persistLocalEventMessage(
        EventMessageType.fromJson('vrcRequestSent'),
      );

      expect(fakeRepo.createdMessages, hasLength(1));
      expect(fakeRepo.createdMessages.first, isA<EventMessage>());
      expect(upsertedItems, hasLength(1));
    });

    test('persistLocalEventMessage — no-op when chatId is null', () async {
      final noIdDelegate = makeDelegate(getChatId: () => null);

      await noIdDelegate.persistLocalEventMessage(
        EventMessageType.fromJson('vrcRequestSent'),
      );

      expect(fakeRepo.createdMessages, isEmpty);
      expect(upsertedItems, isEmpty);
    });

    test(
      'persistLocalEventMessage — forwards extra data into the event message',
      () async {
        await delegate.persistLocalEventMessage(
          EventMessageType.fromJson('vrcRequestSent'),
          data: {'referenceId': 'ref-1'},
        );

        final event = fakeRepo.createdMessages.first as EventMessage;
        expect(event.data['referenceId'], 'ref-1');
      },
    );

    test('onVrcRequestReceived — no-op when chatId is null', () async {
      final noIdDelegate = makeDelegate(getChatId: () => null);

      await noIdDelegate.onVrcRequestReceived(channelDid, null, null);

      expect(fakeRepo.createdMessages, isEmpty);
      expect(upsertedItems, isEmpty);
    });

    test(
      'onVrcRequestReceived — no-op when VRC already exists for channel',
      () async {
        fakeVrcService.hasVrc = true;

        await delegate.onVrcRequestReceived(channelDid, null, null);

        expect(fakeRepo.createdMessages, isEmpty);
        expect(upsertedItems, isEmpty);
      },
    );

    test('onVrcRequestReceived with shouldPromptForAction true — '
        'persists event and concierge, calls upsertChatItem twice', () async {
      await delegate.onVrcRequestReceived(
        channelDid,
        'did:key:identity',
        'Alice',
        shouldPromptForAction: true,
      );

      expect(fakeRepo.createdMessages, hasLength(2));
      expect(fakeRepo.createdMessages[0], isA<EventMessage>());
      expect(fakeRepo.createdMessages[1], isA<ConciergeMessage>());
      expect(upsertedItems, hasLength(2));
    });

    test('onVrcRequestReceived with shouldPromptForAction false — '
        'persists event only, calls upsertChatItem once', () async {
      await delegate.onVrcRequestReceived(
        channelDid,
        null,
        null,
        shouldPromptForAction: false,
      );

      expect(fakeRepo.createdMessages, hasLength(1));
      expect(fakeRepo.createdMessages.first, isA<EventMessage>());
      expect(upsertedItems, hasLength(1));
    });

    test('onVrcRequestReceived — embeds identityDid and identityName '
        'in event data when provided', () async {
      await delegate.onVrcRequestReceived(
        channelDid,
        'did:key:identity',
        'Alice',
        shouldPromptForAction: false,
      );

      final event = fakeRepo.createdMessages.first as EventMessage;
      expect(event.data['identityDid'], 'did:key:identity');
      expect(event.data['identityName'], 'Alice');
    });

    test('dismissVrcConciergeMessages — marks permissionToVerifyRelationship '
        'messages as confirmed and calls removeChatItem', () async {
      final vcMsg = ConciergeMessage(
        chatId: chatId,
        messageId: 'vrc-concierge-1',
        senderDid: channelDid,
        isFromMe: false,
        dateCreated: DateTime.now(),
        status: ChatItemStatus.userInput,
        conciergeType: ConciergeMessageType.fromJson(
          'permissionToVerifyRelationship',
        ),
        data: const {},
      );
      messages = [vcMsg];

      await delegate.dismissVrcConciergeMessages();

      expect(removedItems, hasLength(1));
      expect(removedItems.first.messageId, vcMsg.messageId);
      expect(
        (removedItems.first as ConciergeMessage).status,
        ChatItemStatus.confirmed,
      );
    });

    test('dismissVrcConciergeMessages — leaves other concierge '
        'message types untouched', () async {
      final otherMsg = ConciergeMessage(
        chatId: chatId,
        messageId: 'other-concierge-1',
        senderDid: channelDid,
        isFromMe: false,
        dateCreated: DateTime.now(),
        status: ChatItemStatus.userInput,
        conciergeType: ConciergeMessageType.fromJson('shareContactDetails'),
        data: const {},
      );
      messages = [otherMsg];

      await delegate.dismissVrcConciergeMessages();

      expect(removedItems, isEmpty);
    });

    test(
      'dismissVrcConciergeMessages — no-op when message list is empty',
      () async {
        messages = [];

        await delegate.dismissVrcConciergeMessages();

        expect(removedItems, isEmpty);
      },
    );

    test('showSentVrcAttachment — calls createAttachmentMessage '
        'with one attachment', () async {
      await delegate.showSentVrcAttachment(
        vcBlob: '{"id":"urn:fake-vrc"}',
        senderDid: channelDid,
      );

      expect(fakeChatSdk.createAttachmentMessageCalls, hasLength(1));
      expect(
        fakeChatSdk.createAttachmentMessageCalls.first.attachments,
        hasLength(1),
      );
    });

    test('showSentVrcAttachment — no-op when chatSdk is null', () async {
      final noSdkDelegate = VrcManager(
        ref: container.read(_refProvider),
        getChatId: () => chatId,
        logger: AppLogger.instance,
        getChatSdk: () => null,
        getMessages: () => messages,
        upsertChatItem: upsertedItems.add,
        removeChatItem: removedItems.add,
      );

      await expectLater(
        noSdkDelegate.showSentVrcAttachment(
          vcBlob: '{"id":"urn:fake-vrc"}',
          senderDid: channelDid,
        ),
        completes,
      );
      expect(fakeChatSdk.createAttachmentMessageCalls, isEmpty);
    });
  });
}
