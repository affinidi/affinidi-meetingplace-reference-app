part of 'chat_screen.dart';

class _Reactions extends ConsumerWidget {
  _Reactions({
    required this._contactId,
    required this._chatItem,
    required this._index,
  });

  final String _contactId;
  final chat.Message _chatItem;
  final int _index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    if (_chatItem.reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _chatItem.isFromMe
          ? null
          : () {
              controller.selectReactionAtIndex(_index);
            },
      child: Text(
        _chatItem.reactions.join(' '),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
