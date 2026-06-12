import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    hide ConciergeMessage;

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import 'concierge_message.dart';

/// A chat notice shown when a VRC exchange was deferred.
class ChatVrcExchangeDoLaterNotice extends StatelessWidget {
  const ChatVrcExchangeDoLaterNotice({
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
        child: ConciergeMessage(
          message: context.l10n.vrcDoLater,
          dateCreated: chatItem.dateCreated.toLocal(),
        ),
      ),
    );
  }
}
