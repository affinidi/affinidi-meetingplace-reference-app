import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    hide ConciergeMessage;

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/event_message_extensions.dart';
import '../chat_screen_controller.dart';
import 'concierge_message.dart';

class LeavingGroupChatItem extends ConsumerWidget {
  const LeavingGroupChatItem({
    super.key,
    required this.chatItem,
    required this.contactId,
  });

  final EventMessage chatItem;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberCard = chatItem.contactCard;
    final l10n = context.l10n;
    final memberName = memberCard?.firstName;

    if (memberName == null) {
      return const SizedBox.shrink();
    }

    final ownDid = ref.watch(
      chatScreenControllerProvider(
        contactId,
      ).select((state) => state.contact?.channelDid),
    );
    final isRemovedSelf =
        chatItem.isGroupMemberRemoved &&
        ownDid != null &&
        chatItem.memberDid == ownDid;

    final message = chatItem.isGroupMemberRemoved
        ? isRemovedSelf
              ? l10n.youRemovedFromGroup
              : l10n.memberRemovedFromGroup(memberName)
        : l10n.leavingGroup(memberName);

    return ConciergeMessage(
      message: message,
      dateCreated: chatItem.dateCreated,
    );
  }
}
