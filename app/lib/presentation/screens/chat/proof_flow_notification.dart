part of 'chat_screen.dart';

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
        context.l10n.proofFlowContact;

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
                context.l10n.proofFlowVerifyingProof(contactName),
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
            .clearVerificationFailure();
      },
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.proofFlowVerificationFailed(contactName),
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
