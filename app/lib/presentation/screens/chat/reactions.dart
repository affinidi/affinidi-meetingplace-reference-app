part of 'chat_screen.dart';

class _Reactions extends ConsumerWidget {
  _Reactions({required this._contactId, required this._chatItem});

  final String _contactId;
  final chat.Message _chatItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_chatItem.reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final myDid = ref.watch(provider.select((state) => state.myDid));

    // Group reactions by emoji, preserving first-seen order, so the same emoji
    // from multiple participants renders as one chip with a count rather than
    // being repeated or collapsed without ownership.
    final order = <String>[];
    final counts = <String, int>{};
    final reactedByMe = <String>{};
    for (final reaction in _chatItem.reactions) {
      if (!counts.containsKey(reaction.emoji)) order.add(reaction.emoji);
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
      if (myDid != null && reaction.senderDid == myDid) {
        reactedByMe.add(reaction.emoji);
      }
    }

    // Reacting to one's own message is not supported, mirroring the reaction
    // picker; chips on own messages are display-only.
    final onChipTap = _chatItem.isFromMe
        ? null
        : (String emoji) =>
              controller.setMessageReaction(_chatItem.messageId, emoji);

    return Align(
      alignment: _chatItem.isFromMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final emoji in order)
            _ReactionChip(
              emoji: emoji,
              count: counts[emoji]!,
              isMine: reactedByMe.contains(emoji),
              onTap: onChipTap == null ? null : () => onChipTap(emoji),
            ),
        ],
      ),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.emoji,
    required this.count,
    required this.isMine,
    required this.onTap,
  });

  final String emoji;
  final int count;
  final bool isMine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Pair each background with its matching on-color so the count stays
    // readable: own reactions use the accent colour, others a raised surface
    // that is visible against the dark chat background.
    final backgroundColor = isMine
        ? colorScheme.primary
        : colorScheme.surfaceContainerHigh;
    final foregroundColor = isMine
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            if (count > 1) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
