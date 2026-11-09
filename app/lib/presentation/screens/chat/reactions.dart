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
    final mc = context.mcColors;
    // Selection never fills: own reactions are marked by a blue outline.
    final borderColor = isMine ? colorScheme.primary : mc.hairline;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(McRadius.md),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            if (count > 1) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: mc.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
