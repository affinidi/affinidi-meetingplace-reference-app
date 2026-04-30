part of 'chat_screen.dart';

/// Banner showing liveness check prompt (initiator side)
class _LivenessBanner extends ConsumerWidget {
  const _LivenessBanner(this._contactId);

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proofFlowControllerProvider(_contactId));
    final chatState = ref.watch(chatScreenControllerProvider(_contactId));
    final contactName =
        chatState.contact?.displayName ??
        chatState.contact?.card.firstName ??
        'this contact';
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!state.showBanner || state.bannerDismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey.shade700,
      child: Column(
        spacing: 8,
        children: [
          Text(
            'Check if $contactName is human using a Zero‑Knowledge Proof.',
            style: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: () {
                    ref
                        .read(proofFlowControllerProvider(_contactId).notifier)
                        .requestLivenessCheck();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colorScheme.onSurface,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    minimumSize: const Size(80, 25),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: Text(
                    'Request proof',
                    style: TextStyle(
                      color: colorScheme.surface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(proofFlowControllerProvider(_contactId).notifier)
                      .dismissBanner();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(80, 25),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    side: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                child: const Text(
                  'Do later',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Banner showing verification result (initiator side)
class _VerificationResultBanner extends ConsumerWidget {
  const _VerificationResultBanner(this._contactId);

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proofFlowControllerProvider(_contactId));
    final chatState = ref.watch(chatScreenControllerProvider(_contactId));
    final contactName =
        chatState.contact?.displayName ??
        chatState.contact?.card.firstName ??
        'Contact';

    // Don't show banner for successful verification, only for failures
    if (!state.verificationFailed) {
      return const SizedBox.shrink();
    }

    if (state.isVerifyingProof) {
      return InfoBanner(
        backgroundColor: Colors.blue.shade700,
        onDismiss: () {
          // Cannot dismiss while verifying
        },
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Verifying proof from $contactName...',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return InfoBanner(
      backgroundColor: Colors.red.shade700,
      onDismiss: () {
        // Reset state after dismissing
        ref
            .read(proofFlowControllerProvider(_contactId).notifier)
            .dismissBanner();
      },
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Verification failed for $contactName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
