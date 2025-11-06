part of '../chat_screen.dart';

class _ReactionPickerChatItem extends StatelessWidget {
  const _ReactionPickerChatItem({
    required chat.Message chatItem,
    required String contactId,
  })  : _chatItem = chatItem,
        _contactId = contactId;

  final chat.Message _chatItem;
  final String _contactId;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Wrap(
            children: [
              //https://www.prosettings.com/emoji-list/
              _TappableReaction('❤', _chatItem.messageId, _contactId),
              _TappableReaction('👍', _chatItem.messageId, _contactId),
              _TappableReaction('👎', _chatItem.messageId, _contactId),
              _TappableReaction('😂', _chatItem.messageId, _contactId),
              _TappableReaction('🙂', _chatItem.messageId, _contactId),
              _TappableReaction('🤔', _chatItem.messageId, _contactId),
              _TappableReaction('😳', _chatItem.messageId, _contactId),
              _TappableReaction('🤢', _chatItem.messageId, _contactId),
              _TappableReaction('😭', _chatItem.messageId, _contactId),
              _TappableReaction('😞', _chatItem.messageId, _contactId),
              _TappableReaction('😔', _chatItem.messageId, _contactId),
              _TappableReaction('😕', _chatItem.messageId, _contactId),
              _TappableReaction('🙀', _chatItem.messageId, _contactId),
              _TappableReaction('👋', _chatItem.messageId, _contactId),
              _TappableReaction('👌', _chatItem.messageId, _contactId),
              _TappableReaction('👆', _chatItem.messageId, _contactId),
              _TappableReaction('🤷‍♂️', _chatItem.messageId, _contactId),
              _TappableReaction('🤷‍♀️', _chatItem.messageId, _contactId),
              _TappableReaction('❓', _chatItem.messageId, _contactId),
              _TappableReaction('‼', _chatItem.messageId, _contactId),
              _TappableReaction('💤', _chatItem.messageId, _contactId),
            ],
          ),
        ),
      ),
    );
  }
}

class _TappableReaction extends ConsumerWidget {
  const _TappableReaction(
    this.reaction,
    this.messageId,
    String contactId,
  ) : _contactId = contactId;

  final String reaction;
  final String messageId;
  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    void hideReactionPicker() {
      if (!context.mounted) return;

      controller.clearSelectedReaction();
    }

    return GestureDetector(
      onTap: () {
        controller.setMessageReaction(messageId, reaction);
        hideReactionPicker();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 18, 0),
        child: Text(
          reaction,
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
