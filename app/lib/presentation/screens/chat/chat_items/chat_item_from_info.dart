part of '../chat_screen.dart';

class _ChatItemFromInfo extends ConsumerWidget {
  const _ChatItemFromInfo({required this._chatItem, required this._contactId});

  final chat.ChatItem _chatItem;
  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final isGroupChat = ref.watch(provider.isGroupChat);
    final workAiLabel = context.l10n.agentContextWorkAiLabel;

    if (_chatItem is chat.ConciergeMessage) {
      return const SizedBox(height: 17);
    }

    final dateCreated = _chatItem.dateCreated.toLocal();

    if (!isGroupChat) {
      final item = _chatItem;
      final isAgentReply =
          !_chatItem.isFromMe &&
          item is chat.Message &&
          item.attachments.any((a) => a.isCiergeAgentMarker);
      if (!isAgentReply) {
        return const SizedBox(height: 17);
      }

      final peerName = ref.watch(
        provider.select(
          (state) =>
              state.otherPartyCard?.fullName ?? state.contact?.displayName,
        ),
      );
      if (peerName == null ||
          peerName.isEmpty ||
          peerName.trim() == workAiLabel) {
        return const SizedBox(height: 17);
      }

      return Text(
        context.l10n.agentReplyInfo(
          peerName,
          DateFormat.jm().format(dateCreated),
        ),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
        textAlign: TextAlign.start,
      );
    }

    final groupMember = ref.watch(
      provider.select(
        (state) => state.group?.members.firstWhereOrNull(
          (gm) =>
              gm.did == _chatItem.senderDid ||
              gm.contactCard.did == _chatItem.senderDid,
        ),
      ),
    );

    final isAgentReply =
        !_chatItem.isFromMe &&
        _chatItem is chat.Message &&
        _chatItem.attachments.any((a) => a.isCiergeAgentMarker);

    if (isAgentReply) {
      // Agents are not group members. The connector stamps the owning member's
      // DID on the reply, so resolve the member name from that when the direct
      // roster lookup misses.
      final ownerDids = _chatItem.attachments
          .expand((a) => a.ciergeOwnerDids)
          .toSet();
      final ownerMember = ref.watch(
        provider.select(
          (state) => state.group?.members.firstWhereOrNull(
            (gm) =>
                ownerDids.contains(gm.did) ||
                ownerDids.contains(gm.contactCard.did),
          ),
        ),
      );
      final senderName =
          groupMember?.contactCard.fullName ??
          ownerMember?.contactCard.fullName ??
          workAiLabel;
      return Text(
        context.l10n.agentReplyInfo(
          senderName,
          DateFormat.jm().format(dateCreated),
        ),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
        textAlign: TextAlign.start,
      );
    }

    if (_chatItem.senderDid.isEmpty || groupMember == null) {
      return const SizedBox(height: 17);
    }

    return Text(
      context.l10n.groupMessageInfo(
        groupMember.contactCard.fullName,
        DateFormat.MMMd().format(dateCreated),
        DateFormat.jm().format(dateCreated),
      ),
      style: const TextStyle(color: Colors.grey, fontSize: 12),
      textAlign: _chatItem.isFromMe ? TextAlign.end : TextAlign.start,
    );
  }
}
