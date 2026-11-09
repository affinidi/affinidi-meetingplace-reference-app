import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../themes/tokens/mc_icons.dart';
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
        onDismiss: () {},
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.proofFlowVerifyingProof(contactName),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.mcColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final error = state.verificationError;
    final mc = context.mcColors;
    if (error == null) {
      return const SizedBox.shrink();
    }

    return InfoBanner(
      onDismiss: () {
        ref
            .read(proofFlowControllerProvider(contactId).notifier)
            .clearVerificationError();
      },
      child: Row(
        children: [
          Icon(McIcons.error, color: mc.dangerText, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.proofFlowVerificationFailed(contactName),
              style: context.textTheme.bodyMedium?.copyWith(
                color: mc.dangerText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
