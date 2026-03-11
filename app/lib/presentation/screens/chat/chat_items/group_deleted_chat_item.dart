import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    hide ConciergeMessage;

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import 'concierge_message.dart';

class GroupDeletedChatItem extends StatelessWidget {
  const GroupDeletedChatItem({super.key, required EventMessage chatItem})
    : _chatItem = chatItem;

  final EventMessage _chatItem;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ConciergeMessage(
      message: l10n.groupDeleted,
      dateCreated: _chatItem.dateCreated,
    );
  }
}
