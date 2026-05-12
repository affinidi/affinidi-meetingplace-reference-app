import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    hide ConciergeMessage;

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import 'concierge_message.dart';

/// A chat notice shown when a VRC exchange has been completed successfully.
class ChatVrcExchangeCompleteNotice extends StatelessWidget {
  const ChatVrcExchangeCompleteNotice({
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
        child: _ChatVrcExchangeCompleteNoticeContent(chatItem: chatItem),
      ),
    );
  }
}

class _ChatVrcExchangeCompleteNoticeContent extends StatelessWidget {
  const _ChatVrcExchangeCompleteNoticeContent({required this.chatItem});

  final EventMessage chatItem;

  @override
  Widget build(BuildContext context) {
    return ConciergeMessage(
      message: context.l10n.vrcExchangeCompleted,
      dateCreated: chatItem.dateCreated.toLocal(),
    );
  }
}
