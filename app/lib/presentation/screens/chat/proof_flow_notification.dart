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
        context.l10n.proofFlowThisContact;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!state.showBanner || state.bannerDismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: const Color(0xff2c2c2c),
      child: Column(
        children: [
          Text(
            context.l10n.proofFlowCheckIfHuman(contactName),
            style: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextButton(
                  onPressed: () {
                    ref
                        .read(proofFlowControllerProvider(_contactId).notifier)
                        .requestLivenessCheck();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    minimumSize: const Size(80, 25),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: Text(
                    context.l10n.proofFlowRequestProof,
                    style: textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 16,
                  ),
                  minimumSize: const Size(80, 25),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    side: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                child: Text(
                  context.l10n.doLater,
                  style: textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
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
            .dismissBanner();
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
