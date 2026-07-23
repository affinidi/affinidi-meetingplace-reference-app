part of '../chat_screen.dart';

class _StepUpApproveRequestChatItem extends ConsumerStatefulWidget {
  const _StepUpApproveRequestChatItem({
    required this.chatItem,
    required this.contactId,
  });

  final chat.ConciergeMessage chatItem;
  final String contactId;

  @override
  ConsumerState<_StepUpApproveRequestChatItem> createState() =>
      _StepUpApproveRequestChatItemState();
}

class _StepUpApproveRequestChatItemState
    extends ConsumerState<_StepUpApproveRequestChatItem>
    with AutomaticKeepAliveClientMixin {
  bool _processing = false;
  String? _result;
  bool _vtaExpanded = false;

  @override
  bool get wantKeepAlive => _result != null || _processing;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isOwner = !widget.chatItem.isFromMe;

    final approveRequest =
        widget.chatItem.data['approveRequest'] as Map<String, dynamic>? ?? {};
    final payload =
        approveRequest['payload'] as Map<String, dynamic>? ?? approveRequest;
    final reason = payload['reason'] as String? ?? 'Step-up approval required';
    final document = widget.chatItem.data['document'] as Map<String, dynamic>?;
    final documentTitle = document?['title'] as String?;
    final documentMediaType = document?['mediaType'] as String?;
    final alreadyConfirmed =
        widget.chatItem.status == chat.ChatItemStatus.confirmed;
    final isActionable =
        isOwner &&
        widget.chatItem.status == chat.ChatItemStatus.userInput &&
        _result == null;

    // Non-owner sees a passive notice.
    if (!isOwner) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: 2,
            colors: [
              Color.fromARGB(255, 56, 56, 76),
              Color.fromARGB(255, 21, 21, 31),
            ],
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_top, color: Colors.white54, size: 28),
            SizedBox(height: 8),
            Text(
              'Waiting for owner approval...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
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
            Color.fromARGB(255, 76, 56, 96),
            Color.fromARGB(255, 31, 21, 41),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Approval Required',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (documentTitle != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.description_outlined,
                    color: Colors.white70,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documentTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        if (documentMediaType != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            documentMediaType,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                const JsonEncoder.withIndent('  ').convert(payload),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          if (_result != null || alreadyConfirmed) ...[
            const SizedBox(height: 12),
            Text(
              _result ?? 'Approved',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: (_result ?? 'Approved') == 'Approved'
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (isActionable && !_processing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(90, 36),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () => _handleApproval(approveRequest),
                  child: const Text('Approve'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(90, 36),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Colors.white54, width: 1),
                    ),
                  ),
                  onPressed: _handleRejection,
                  child: const Text(
                    'Reject',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ],
          if (_processing) ...[
            const SizedBox(height: 16),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleApproval(Map<String, dynamic> approveRequest) async {
    setState(() => _processing = true);
    try {
      final contact = ref
          .read(contactsServiceProvider)
          .getContactById(widget.contactId);
      final signingService = ref.read(signingServiceProvider.notifier);
      await signingService.handleRelayedApproveRequest(
        approveRequest,
        mediatorDid: contact!.mediatorDid,
      );
      widget.chatItem.status = chat.ChatItemStatus.confirmed;
      final repository = await ref.read(chatRepositoryProvider.future);
      await repository.updateMesssage(widget.chatItem);
      if (mounted) {
        setState(() {
          _result = 'Approved';
          _processing = false;
          updateKeepAlive();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Failed: $e';
          _processing = false;
          updateKeepAlive();
        });
      }
    }
  }

  void _handleRejection() {
    setState(() => _result = 'Rejected');
  }
}
