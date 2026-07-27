part of '../chat_screen.dart';

class _SignDocumentRequestChatItem extends ConsumerStatefulWidget {
  const _SignDocumentRequestChatItem({
    required this.title,
    required this.contactId,
    required this.messageIndex,
    required this.senderDid,
    this.status,
    this.rawPayload,
  }) : statusColor = null,
       statusLabel = null,
       statusIcon = null;

  final String title;
  final String contactId;
  final int messageIndex;
  final String senderDid;
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
      if (decoded['type'] == 'cierge/sign-document-status') {
        final status = decoded['status'] as String?;
        if (status == 'awaiting_approval' || status == 'error') {
          return decoded;
        }
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
    // Only the device that sent the request should see the signing-request
    // widget. Other participants (e.g. the VTA owner in the same Matrix chat)
    // see this message too but must not see "Signing request sent".
    final myDid = ref.watch(
      chatScreenControllerProvider(widget.contactId).select((s) => s.myDid),
    );
    if (myDid != null && widget.senderDid != myDid) {
      return const SizedBox.shrink();
    }

    final statusData = ref.watch(
      chatScreenControllerProvider(widget.contactId).select((state) {
        final msgs = state.messages;
        final conciergeSignType = chat.ConciergeMessageType.fromJson(
          chat.CiergeSignDocumentRequest.conciergeTypeName,
        );
        // Messages are reverse-chronological (index 0 = newest).
        // The status reply (newer) is at a lower index than this sign request.
        // Search forward from 0 so we find the status before hitting any
        // ConciergeMessage echo of this same sign request at messageIndex-1.
        for (var i = 0; i < widget.messageIndex; i++) {
          final msg = msgs[i];
          // A different, newer sign request — its status is not ours; stop.
          if (_SignDocumentRequestChatItem.matchPlainMessage(msg) != null) {
            break;
          }
          if (msg is chat.ConciergeMessage &&
              msg.conciergeType == conciergeSignType) {
            break;
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
      final status = statusData['status'] as String?;
      if (status == 'error') {
        label = 'Signing failed';
        color = Colors.redAccent;
        icon = Icons.error_outline;
      } else {
        label = 'Awaiting approval';
        color = Colors.amber;
        icon = Icons.hourglass_top;
      }
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
                  _truncatedPayloadJson(widget.rawPayload!),
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

  static String _truncatedPayloadJson(Map<String, dynamic> data) {
    const maxChars = 200;
    final copy = Map<String, dynamic>.from(data);
    for (final key in copy.keys.toList()) {
      final value = copy[key];
      if (value is Map<String, dynamic>) {
        final valJson = jsonEncode(value);
        if (valJson.length > maxChars) {
          copy[key] = '${valJson.substring(0, maxChars)}... (truncated)';
        }
      } else if (value is String && value.length > maxChars) {
        copy[key] = '${value.substring(0, maxChars)}... (truncated)';
      }
    }
    return const JsonEncoder.withIndent('  ').convert(copy);
  }
}
