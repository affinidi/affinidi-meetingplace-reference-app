import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    hide ConciergeMessage;

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../chat_screen_controller.dart';
import 'concierge_message.dart';

/// A chat notice shown when a VRC request has been received from a contact.
class ChatVrcRequestReceivedNotice extends StatelessWidget {
  const ChatVrcRequestReceivedNotice({
    super.key,
    required this.chatItem,
    required this.contactId,
  });

  final EventMessage chatItem;
  final String contactId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: _ChatVrcRequestReceivedNoticeContent(
          chatItem: chatItem,
          contactId: contactId,
        ),
      ),
    );
  }
}

class _ChatVrcRequestReceivedNoticeContent extends ConsumerWidget {
  const _ChatVrcRequestReceivedNoticeContent({
    required this.chatItem,
    required this.contactId,
  });

  final EventMessage chatItem;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.watch(
      chatScreenControllerProvider(contactId).otherPartyName,
    );

    if (firstName == null || firstName.isEmpty) {
      return const SizedBox.shrink();
    }

    return ConciergeMessage(
      message: context.l10n.vrcRequestReceived(firstName),
      dateCreated: chatItem.dateCreated.toLocal(),
    );
  }
}
