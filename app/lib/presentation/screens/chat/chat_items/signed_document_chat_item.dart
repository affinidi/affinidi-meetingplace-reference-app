part of '../chat_screen.dart';

class _SignedDocumentChatItem extends StatelessWidget {
  const _SignedDocumentChatItem({
    required this.title,
    required this.issuer,
  });

  static const _typePrefix = 'cierge/signed-document';

  static Map<String, dynamic>? matchPlainMessage(chat.ChatItem item) {
    if (item is! chat.Message) return null;
    try {
      final decoded = jsonDecode(item.value);
      if (decoded is! Map<String, dynamic>) return null;
      final type = decoded['type'] as String? ?? '';
      if (type.contains('signed-document')) return decoded;
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final shortIssuer = issuer.length > 24
        ? '${issuer.substring(0, 12)}...${issuer.substring(issuer.length - 8)}'
        : issuer;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 2,
          colors: [
            Color.fromARGB(255, 36, 76, 56),
            Color.fromARGB(255, 18, 31, 24),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: Colors.greenAccent, size: 28),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.greenAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Signed',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'by $shortIssuer',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final String title;
  final String issuer;
}
