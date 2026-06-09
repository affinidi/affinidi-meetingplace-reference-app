import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../widgets/info_banner.dart';
import '../chat_screen_controller.dart';
import '../proof_flow_controller.dart';

/// ZKP-specific UI layered above the chat message list (verification banner).
class ChatZkpOverlay extends ConsumerWidget {
  const ChatZkpOverlay({super.key, required this.contactId});

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proofFlowControllerProvider(contactId));
    final chatState = ref.watch(chatScreenControllerProvider(contactId));
    final contactName =
        chatState.contact?.displayName ??
        chatState.contact?.card.firstName ??
        context.l10n.proofFlowContact;

    if (state.isVerifyingProof) {
      return InfoBanner(
        backgroundColor: Colors.blue.shade700,
        onDismiss: () {},
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

    final error = state.verificationError;
    if (error == null) {
      return const SizedBox.shrink();
    }

    return InfoBanner(
      backgroundColor: Colors.red.shade700,
      onDismiss: () {
        ref
            .read(proofFlowControllerProvider(contactId).notifier)
            .clearVerificationError();
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
