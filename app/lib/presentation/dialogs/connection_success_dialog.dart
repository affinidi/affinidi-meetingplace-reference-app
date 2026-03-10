import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/contacts/contact.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/navigator.dart' as app_navigator;
import '../../navigation/routes/dashboard_routes.dart';
import '../widgets/bottom_sheet_menu.dart';

class ConnectionSuccessDialog extends ConsumerWidget {
  const ConnectionSuccessDialog({super.key, required this.contact});

  final Contact contact;

  static Future<void> show({
    required BuildContext context,
    required Contact contact,
  }) {
    return showModalBottomSheet<void>(
      backgroundColor: context.colorScheme.inverseSurface,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      context: context,
      builder: (context) => ConnectionSuccessDialog(contact: contact),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomSheetMenu(
      header: 'Connection Successful!',
      itemCount: 2,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text('Chat with ${contact.displayName}'),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                ref
                    .read(app_navigator.navigatorProvider)
                    .go(ChatRoute(contactId: contact.id).location);
              },
            );
          case 1:
            return ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Close'),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
