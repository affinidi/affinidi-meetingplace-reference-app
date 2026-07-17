part of '../chat_screen.dart';

class _SignDocumentRequestChatItem extends StatelessWidget {
  const _SignDocumentRequestChatItem({
    required this.chatItem,
    required this.contactId,
  });

  final chat.ConciergeMessage chatItem;
  final String contactId;

  @override
  Widget build(BuildContext context) {
    final document = chatItem.data['document'] as Map<String, dynamic>? ?? {};
    final title = document['title'] as String? ?? 'Untitled Document';
    final isActionable = chatItem.status == chat.ChatItemStatus.userInput;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 2,
          colors: [
            Color.fromARGB(255, 46, 76, 96),
            Color.fromARGB(255, 21, 31, 41),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_outlined, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Document Signing Request',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          if (isActionable) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(90, 32),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  onPressed: () {
                    // TODO: wire up VTA signing flow
                  },
                  child: const Text(
                    'Sign',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(90, 32),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Colors.white54, width: 1),
                    ),
                  ),
                  onPressed: () {
                    // TODO: mark as declined
                  },
                  child: const Text(
                    'Decline',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
