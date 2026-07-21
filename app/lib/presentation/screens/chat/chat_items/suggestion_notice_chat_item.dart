part of '../chat_screen.dart';

class _SuggestionNoticeChatItem extends HookConsumerWidget {
  const _SuggestionNoticeChatItem({
    required this.suggestion,
    required this.isFromMe,
    required this.contactId,
  });

  final ChatSuggestion suggestion;
  final bool isFromMe;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final controller = ref.read(
      chatScreenControllerProvider(contactId).notifier,
    );

    Future<void> ignoreSuggestion() async {
      if (isBusy.value) return;

      isBusy.value = true;
      try {
        await controller.ignoreLatestSuggestion();
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> sendAsMe() async {
      if (isBusy.value) return;

      isBusy.value = true;
      try {
        await controller.sendLatestSuggestionAsMe();
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> editSuggestion() async {
      if (isBusy.value) return;

      isBusy.value = true;
      try {
        await controller.editLatestSuggestion();
      } finally {
        isBusy.value = false;
      }
    }

    return Align(
      alignment: isFromMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        key: ValueKey('chat_suggestion_${suggestion.relatedMessageId}'),
        margin: isFromMe
            ? const EdgeInsets.fromLTRB(60, 8, 5, 0)
            : const EdgeInsets.fromLTRB(5, 8, 60, 0),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    suggestion.text,
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: isBusy.value ? null : ignoreSuggestion,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amber.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(context.l10n.chatSuggestionActionIgnore),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: isBusy.value ? null : editSuggestion,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amber.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(context.l10n.chatSuggestionActionEdit),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: isBusy.value ? null : sendAsMe,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.amber.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(context.l10n.chatSuggestionActionSendAsMe),
                ),
              ],
            ),
            if (isBusy.value)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.amber.shade800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
