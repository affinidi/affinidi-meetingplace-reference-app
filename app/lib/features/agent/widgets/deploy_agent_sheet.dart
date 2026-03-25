import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/agent_readiness_state.dart';
import '../providers/agent_providers.dart';
import 'persona_summary_card.dart';

/// Bottom sheet that shows the learned persona summary, then issues the
/// AgentConfigVC via the backend and displays success / error feedback.
///
/// Auto-closes 2 seconds after a successful deployment.
class DeployAgentSheet extends ConsumerStatefulWidget {
  const DeployAgentSheet({
    required this.ownerDid,
    required this.readiness,
    super.key,
  });

  final String ownerDid;
  final AgentReadinessState readiness;

  @override
  ConsumerState<DeployAgentSheet> createState() => _DeployAgentSheetState();
}

class _DeployAgentSheetState extends ConsumerState<DeployAgentSheet> {
  Timer? _autoCloseTimer;

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    ref.read(deploymentNotifierProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deployState = ref.watch(deploymentNotifierProvider);

    // Auto-close on success.
    ref.listen(deploymentNotifierProvider, (_, next) {
      if (next is AsyncData && next.value != null) {
        _autoCloseTimer ??= Timer(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: bottomInset + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Deploy as My Representative',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Confirming will issue an AgentConfigVC into your Affinidi Vault. '
              'Your representative will respond on your behalf '
              'while you are in focus mode.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),

            // Persona summary — scrollable so tall cards don't overflow
            Flexible(
              child: SingleChildScrollView(
                child: PersonaSummaryCard(readiness: widget.readiness),
              ),
            ),
            const SizedBox(height: 16),

            // Success banner
            deployState.maybeWhen(
              data: (result) {
                if (result == null) return const SizedBox.shrink();
                return _SuccessBanner(vcId: result.vcId);
              },
              orElse: () => const SizedBox.shrink(),
            ),

            // Error banner
            deployState.maybeWhen(
              error: (err, _) => _ErrorBanner(message: err.toString()),
              orElse: () => const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            // Primary action button
            deployState.maybeWhen(
              data: (result) {
                if (result != null) return const SizedBox.shrink();
                return FilledButton.icon(
                  onPressed: () => ref
                      .read(deploymentNotifierProvider.notifier)
                      .deploy(widget.ownerDid),
                  icon: const Icon(Icons.verified_outlined, size: 18),
                  label: const Text('Issue VC & Activate Agent'),
                );
              },
              loading: () => FilledButton.icon(
                onPressed: null,
                icon: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                label: const Text('Issuing VC…'),
              ),
              orElse: () => FilledButton.icon(
                onPressed: () => ref
                    .read(deploymentNotifierProvider.notifier)
                    .deploy(widget.ownerDid),
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: const Text('Issue VC & Activate Agent'),
              ),
            ),

            const SizedBox(height: 8),

            // Cancel button
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Banners
// ---------------------------------------------------------------------------

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.vcId});

  final String vcId;

  String get _truncatedVcId {
    if (vcId.length <= 20) return vcId;
    return '${vcId.substring(0, 8)}…${vcId.substring(vcId.length - 8)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade700,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agent activated!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'VC: $_truncatedVcId',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
