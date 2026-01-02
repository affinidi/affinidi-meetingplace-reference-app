part of '../chat_screen.dart';

class _ChatItemFromInfo extends ConsumerWidget {
  const _ChatItemFromInfo(
      {required chat.ChatItem chatItem, required String contactId})
      : _chatItem = chatItem,
        _contactId = contactId;

  final chat.ChatItem _chatItem;
  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final isGroupChat = ref.watch(provider.isGroupChat);
    final groupMember = ref.watch(provider.select((state) => state
        .group?.members
        .firstWhereOrNull((gm) => gm.did == _chatItem.senderDid)));

    // AL: Refactored to one statement, and returns a spacer
    // to prevent layout shift
    if (!isGroupChat ||
        _chatItem is chat.ConciergeMessage ||
        _chatItem.senderDid.isEmpty ||
        groupMember == null) {
      return const SizedBox(
        height: 17,
      );
    }

    final dateCreated = _chatItem.dateCreated.toLocal();

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
