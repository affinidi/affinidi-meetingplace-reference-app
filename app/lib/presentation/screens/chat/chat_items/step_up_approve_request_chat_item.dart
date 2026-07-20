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
    extends ConsumerState<_StepUpApproveRequestChatItem> {
  bool _processing = false;
  String? _result;

  @override
  Widget build(BuildContext context) {
    final signingStatus = ref.watch(
      signingServiceProvider.select((s) => s.status),
    );
    final isOwner = signingStatus == SigningServiceStatus.connected;

    final approveRequest =
        widget.chatItem.data['approveRequest'] as Map<String, dynamic>? ?? {};
    final payload =
        approveRequest['payload'] as Map<String, dynamic>? ?? approveRequest;
    final reason = payload['reason'] as String? ?? 'Step-up approval required';
    final isActionable = isOwner &&
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
          const Icon(Icons.verified_user_outlined, color: Colors.white, size: 32),
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
          if (_result != null) ...[
            const SizedBox(height: 12),
            Text(
              _result!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _result == 'Approved' ? Colors.greenAccent : Colors.redAccent,
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
      final signingService = ref.read(signingServiceProvider.notifier);
      await signingService.handleRelayedApproveRequest(approveRequest);
      // Notify the connector that approval succeeded so the agent can retry.
      final controller = ref.read(
        chatScreenControllerProvider(widget.contactId).notifier,
      );
      await controller.sendMessageDirect(
        '{"type":"cierge/stepUpApproved"}',
      );
      if (mounted) setState(() { _result = 'Approved'; _processing = false; });
    } catch (e) {
      if (mounted) setState(() { _result = 'Failed: $e'; _processing = false; });
    }
  }

  void _handleRejection() {
    setState(() => _result = 'Rejected');
  }
}
