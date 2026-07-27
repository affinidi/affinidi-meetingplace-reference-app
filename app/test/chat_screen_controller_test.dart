import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
