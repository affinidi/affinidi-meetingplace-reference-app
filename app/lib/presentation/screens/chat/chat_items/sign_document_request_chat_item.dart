part of '../chat_screen.dart';

class _SignDocumentRequestChatItem extends ConsumerStatefulWidget {
  const _SignDocumentRequestChatItem({
    required this.title,
    required this.contactId,
    required this.messageIndex,
    this.status,
    this.rawPayload,
    this.statusLabel,
    this.statusColor,
    this.statusIcon,
  });

  final String title;
  final String contactId;
  final int messageIndex;
  final chat.ChatItemStatus? status;
  final Map<String, dynamic>? rawPayload;
  final String? statusLabel;
  final Color? statusColor;
  final IconData? statusIcon;

  static chat.CiergeSignDocumentRequest? matchPlainMessage(chat.ChatItem item) {
    if (item is! chat.Message) return null;
    return chat.CiergeSignDocumentRequest.fromMessageText(item.value);
  }

  static Map<String, dynamic>? parseStatusMessage(chat.ChatItem item) {
    if (item is! chat.Message) return null;
    try {
      final decoded = jsonDecode(item.value);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['type'] == 'cierge/sign-document-status' &&
          decoded['status'] == 'awaiting_approval') {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  static bool matchStatusMessage(chat.ChatItem item) {
    return parseStatusMessage(item) != null;
  }

  @override
  ConsumerState<_SignDocumentRequestChatItem> createState() =>
      _SignDocumentRequestChatItemState();
}

class _SignDocumentRequestChatItemState
    extends ConsumerState<_SignDocumentRequestChatItem> {
  bool _expanded = false;
  bool _vtaExpanded = false;

  @override
  Widget build(BuildContext context) {
    final signingStatus = ref.watch(
      signingServiceProvider.select((s) => s.status),
    );
    if (signingStatus == SigningServiceStatus.connected) {
      return const SizedBox.shrink();
    }

    final statusData = ref.watch(
      chatScreenControllerProvider(widget.contactId).select((state) {
        final msgs = state.messages;
        for (var i = widget.messageIndex - 1; i >= 0; i--) {
          final msg = msgs[i];
          if (_SignDocumentRequestChatItem.matchPlainMessage(msg) != null) {
            return null;
          }
          if (msg is chat.ConciergeMessage &&
              msg.conciergeType ==
                  chat.ConciergeMessageType.fromJson(
                    chat.CiergeSignDocumentRequest.conciergeTypeName,
                  )) {
            return null;
          }
          final parsed = _SignDocumentRequestChatItem.parseStatusMessage(msg);
          if (parsed != null) return parsed;
        }
        return null;
      }),
    );

    final String label;
    final Color color;
    final IconData icon;

    if (widget.statusLabel != null) {
      label = widget.statusLabel!;
      color = widget.statusColor ?? Colors.white54;
      icon = widget.statusIcon ?? Icons.info_outline;
    } else if (statusData != null) {
      label = 'Awaiting approval';
      color = Colors.amber;
      icon = Icons.hourglass_top;
    } else {
      (label, color, icon) = switch (widget.status) {
        chat.ChatItemStatus.confirmed => (
          'Document signed',
          Colors.greenAccent,
          Icons.check_circle_outline,
        ),
        chat.ChatItemStatus.error => (
          'Signing failed',
          Colors.redAccent,
          Icons.error_outline,
        ),
        _ => ('Signing request sent', Colors.white54, Icons.send_outlined),
      };
    }

    final challenge = statusData?['challenge'] as String?;
    final subject = statusData?['subject'] as String?;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.description_outlined,
                color: Colors.white70,
                size: 28,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
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
                        Icon(icon, color: color, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: TextStyle(color: color, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.rawPayload != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white38,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _expanded ? 'Hide details' : 'More details',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(widget.rawPayload),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
          if (statusData != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _vtaExpanded = !_vtaExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _vtaExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white38,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _vtaExpanded ? 'Hide VTA details' : 'VTA details',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (_vtaExpanded) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(statusData),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
