part of '../chat_screen.dart';

class _SignedDocumentChatItem extends StatefulWidget {
  const _SignedDocumentChatItem({required this.data});

  final Map<String, dynamic> data;

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
  State<_SignedDocumentChatItem> createState() =>
      _SignedDocumentChatItemState();
}

class _SignedDocumentChatItemState extends State<_SignedDocumentChatItem> {
  bool _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final payload =
        widget.data['payload'] as Map<String, dynamic>? ?? {};
    final proof =
        widget.data['proof'] as Map<String, dynamic>? ?? {};
    final title = payload['title'] as String? ?? 'Untitled Document';
    final issuer = widget.data['issuer'] as String? ?? '';
    final issuedAt = widget.data['issuedAt'] as String? ?? '';
    final proofType = proof['type'] as String? ?? '';
    final cryptosuite = proof['cryptosuite'] as String? ?? '';
    final proofCreated = proof['created'] as String? ?? '';

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.greenAccent,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
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
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, color: Colors.white38, size: 14),
              const SizedBox(width: 4),
              Text(
                '$proofType · $cryptosuite',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          if (proofCreated.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.white38,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Signed at $proofCreated',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _detailsExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white38,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _detailsExpanded ? 'Hide details' : 'More details',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          if (_detailsExpanded) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(widget.data),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
