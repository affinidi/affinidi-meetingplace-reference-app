import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/open_chat_registry.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_controller.dart';

import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'utils/app.dart';

void main() {
  group('ChatScreenController', () {
    testWidgets('clears VRC banner state for group chat', (tester) async {
      await navigateToChat(
        tester,
        contactId: FakeContacts.groupContact.id,
        contacts: [FakeContacts.groupContact],
      );

      final context = tester.element(find.byType(Scaffold).first);
      final container = ProviderScope.containerOf(context, listen: false);
      final state = container.read(
        chatScreenControllerProvider(FakeContacts.groupContact.id),
      );

      expect(state.shouldShowVrcBanner, isFalse);
      expect(state.shouldEnableVrcAttachment, isFalse);
    });

    testWidgets('pauses covered chat read state and restores badge reset', (
      tester,
    ) async {
      final contact = FakeContacts.groupContact;
      await navigateToChat(tester, contactId: contact.id, contacts: [contact]);

      final context = tester.element(find.byType(Scaffold).first);
      final container = ProviderScope.containerOf(context, listen: false);
      final controller = container.read(
        chatScreenControllerProvider(contact.id).notifier,
      );
      await tester.pump();

      final openChatRegistry = container.read(
        openChatRegistryProvider.notifier,
      );
      expect(openChatRegistry.isOpen(contact.id), isTrue);

      expect(controller.pauseReadStateForCoveringCall(), isTrue);
      await tester.pump();
      expect(openChatRegistry.isOpen(contact.id), isFalse);
      expect(controller.pauseReadStateForCoveringCall(), isFalse);

      controller.restoreReadStateAfterCoveringCall();
      await tester.pumpAndSettle();

      expect(openChatRegistry.isOpen(contact.id), isTrue);
      expect(
        container
            .read(contactsServiceProvider)
            .getContactById(contact.id)
            ?.badgeCount,
        0,
      );
    });

    testWidgets('keeps pending suggestion progress visible beyond 12 seconds', (
      tester,
    ) async {
      final chatSdk = FakeChatSdk();
      final contact = FakeContacts.individualContact;

      await navigateToChat(
        tester,
        contactId: contact.id,
        contacts: [contact],
        chatSdk: chatSdk,
      );

      final message = chatSdk.simulateIncomingTextMessage(
        text: 'Original message',
        recipientDid: contact.channelDid!,
      );
      await tester.pump();

      final context = tester.element(find.byType(Scaffold).first);
      final container = ProviderScope.containerOf(context, listen: false);
      final controller = container.read(
        chatScreenControllerProvider(contact.id).notifier,
      );

      final askFuture = controller.askForSuggestion(message.messageId);
      await tester.pump();

      expect(
        container
            .read(chatScreenControllerProvider(contact.id))
            .pendingSuggestionMessageId,
        message.messageId,
      );

      await tester.pump(const Duration(seconds: 13));

      expect(
        container
            .read(chatScreenControllerProvider(contact.id))
            .pendingSuggestionMessageId,
        message.messageId,
      );

      chatSdk.simulateIncomingSuggestion(
        text: 'Suggested reply',
        relatedMessageId: message.messageId,
        recipientDid: contact.channelDid!,
      );
      await tester.pump();

      await askFuture;

      final state = container.read(chatScreenControllerProvider(contact.id));
      expect(state.pendingSuggestionMessageId, isNull);
      expect(state.latestSuggestion, isA<ChatSuggestion>());
    });
  });
}
