import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/open_chat_registry.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_controller.dart';

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
  });
}
