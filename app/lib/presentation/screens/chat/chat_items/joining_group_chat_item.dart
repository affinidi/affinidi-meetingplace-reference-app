import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    hide ConciergeMessage;

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/event_message_extentions.dart';
import 'concierge_message.dart';

class JoiningGroupChatItem extends StatelessWidget {
  const JoiningGroupChatItem({super.key, required EventMessage chatItem})
      : _chatItem = chatItem;

  final EventMessage _chatItem;
  @override
  Widget build(BuildContext context) {
    final memberCard = _chatItem.contactCard;
    final l10n = context.l10n;
    final memberName = memberCard?.firstName;

    if (memberName == null) {
      return const SizedBox.shrink();
    }

    return ConciergeMessage(
      message: l10n.joiningGroup(memberName),
      dateCreated: _chatItem.dateCreated,
    );
  }
}
