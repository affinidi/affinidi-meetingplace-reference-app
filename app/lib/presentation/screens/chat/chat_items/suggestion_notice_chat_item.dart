part of '../chat_screen.dart';

class _SuggestionNoticeChatItem extends StatelessWidget {
  const _SuggestionNoticeChatItem({
    required this.suggestion,
    required this.isFromMe,
  });

  final ChatSuggestion suggestion;
  final bool isFromMe;

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.auto_awesome, size: 18, color: Colors.amber.shade800),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                suggestion.text,
                style: TextStyle(color: Colors.amber.shade900, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
