import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/services/signing_service/signing_service.dart';

class StepUpApprovalListener extends ConsumerStatefulWidget {
  const StepUpApprovalListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<StepUpApprovalListener> createState() =>
      _StepUpApprovalListenerState();
}

class _StepUpApprovalListenerState
    extends ConsumerState<StepUpApprovalListener> {
  bool _dialogShowing = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<SigningServiceState>(signingServiceProvider, (prev, next) {
      if (next.pendingApproval != null && !_dialogShowing) {
        _showApprovalDialog(context, next.pendingApproval!);
      }
    });
    return widget.child;
  }

  void _showApprovalDialog(BuildContext context, PendingApproval pending) {
    _dialogShowing = true;
    final reason =
        pending.approveRequest['reason'] as String? ??
        'Step-up authentication required';

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approval Required'),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(signingServiceProvider.notifier).rejectCurrentRequest();
              Navigator.of(dialogContext).pop();
              _dialogShowing = false;
            },
            child: const Text('Reject'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(signingServiceProvider.notifier).approveCurrentRequest();
              Navigator.of(dialogContext).pop();
              _dialogShowing = false;
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    ).then((_) => _dialogShowing = false);
  }
}
