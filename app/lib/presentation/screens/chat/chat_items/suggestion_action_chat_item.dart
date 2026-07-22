part of '../chat_screen.dart';

class _SuggestionActionChatItem extends ConsumerWidget {
  const _SuggestionActionChatItem({
    required this.messageId,
    required this.contactId,
  });

  final String messageId;
  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(contactId);
    final controller = ref.read(provider.notifier);

    Future<void> askForSuggestion() async {
      try {
        await controller.askForSuggestion(messageId);
      } on TimeoutException {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.chatSuggestionRequestFailed),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.chatSuggestionRequestFailed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: askForSuggestion,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.chatMessageActionAskSuggestion,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
