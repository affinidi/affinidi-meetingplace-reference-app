import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../screens/chat/chat_items/concierge_message.dart';
import '../../themes/tokens/mc_colors.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';

/// Types of ZKP notices that can be displayed
enum ZkpNoticeType {
  /// User shared a proof
  shared,

  /// User received a proof
  received,

  /// User received a proof request
  request,

  /// User initiated a proof request
  initiated,

  /// User paused the ZKP flow
  paused,

  /// Peer declined the ZKP request
  declined,
}

/// Unified widget for displaying ZKP-related notices
///
/// Replaces multiple separate notice widgets with a single
/// configurable component
class ZkpNoticeBanner extends ConsumerWidget {
  const ZkpNoticeBanner({
    super.key,
    required this.type,
    required this.dateCreated,
    this.contactName,
    this.onGenerateProof,
    this.onDoLater,
  });

  final ZkpNoticeType type;
  final DateTime dateCreated;
  final String? contactName;
  final VoidCallback? onGenerateProof;
  final VoidCallback? onDoLater;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (type) {
      case ZkpNoticeType.paused:
        return ConciergeMessage(
          dateCreated: dateCreated,
          message: context.l10n.zkpNoticePaused,
          fullWidth: true,
        );

      case ZkpNoticeType.shared:
        return _ProofNotice(
          dateCreated: dateCreated,
          isFromMe: true,
          message: context.l10n.zkpNoticeShared,
        );

      case ZkpNoticeType.received:
        return _ProofNotice(
          dateCreated: dateCreated,
          isFromMe: false,
          message: context.l10n.zkpNoticeReceived(
            contactName ?? context.l10n.proofFlowContact,
          ),
        );

      case ZkpNoticeType.request:
        return _ProofRequestNotice(
          dateCreated: dateCreated,
          contactName: contactName,
          onGenerateProof: onGenerateProof,
          onDoLater: onDoLater,
        );
      case ZkpNoticeType.declined:
        return ConciergeMessage(
          dateCreated: dateCreated,
          message: context.l10n.zkpNoticeDeclined(
            contactName ?? context.l10n.proofFlowContact,
          ),
        );
      case ZkpNoticeType.initiated:
        return ConciergeMessage(
          dateCreated: dateCreated,
          message: context.l10n.zkpNoticeRequestInitiated,
          fullWidth: true,
        );
    }
  }
}

/// Widget displaying a proof notice (shared or received)
class _ProofNotice extends StatelessWidget {
  const _ProofNotice({
    required this.dateCreated,
    required this.isFromMe,
    required this.message,
  });

  final DateTime dateCreated;
  final bool isFromMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConciergeMessage(
          dateCreated: dateCreated,
          message: message,
          fullWidth: true,
        ),
        const SizedBox(height: 16),
        _ZkpBadge(isFromMe: isFromMe),
      ],
    );
  }
}

/// Visual badge showing ZKP verification (aligned like a chat message).
class _ZkpBadge extends StatelessWidget {
  const _ZkpBadge({required this.isFromMe});

  static const _chatListHorizontalPadding = 20.0;
  static const _chatBubbleSideMargin = 60.0;

  final bool isFromMe;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;

    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: isFromMe
            ? const EdgeInsets.fromLTRB(
                _chatBubbleSideMargin,
                0,
                _chatListHorizontalPadding,
                0,
              )
            : const EdgeInsets.fromLTRB(
                _chatListHorizontalPadding,
                0,
                _chatBubbleSideMargin,
                0,
              ),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(McRadius.lg),
          border: Border.all(
            color: isFromMe ? McColors.blue : mc.hairline,
            width: 4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: McColors.controlHoverWash,
              ),
              child: Icon(
                McIcons.userCheck,
                size: 22,
                color: mc.highlightSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.humanZkpAbbreviated,
              style: textTheme.labelLarge?.copyWith(color: mc.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofRequestNotice extends StatelessWidget {
  const _ProofRequestNotice({
    required this.dateCreated,
    this.contactName,
    this.onGenerateProof,
    this.onDoLater,
  });

  final DateTime dateCreated;
  final String? contactName;
  final VoidCallback? onGenerateProof;
  final VoidCallback? onDoLater;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mc = context.mcColors;
    final textTheme = context.textTheme;
    final outlineButtonShape = StadiumBorder(
      side: BorderSide(color: mc.hairlineStrong),
    );

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        border: Border.all(color: mc.hairline),
        borderRadius: BorderRadius.circular(McRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            l10n.genWordConciergeMessage,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(color: mc.textPrimary),
          ),
          Text(
            l10n.zkpNoticeRequest(contactName ?? l10n.proofFlowThisContact),
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: mc.textSecondary),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onGenerateProof != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: McColors.blue,
                      foregroundColor: McColors.textOnPrimary,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      minimumSize: const Size(80, 25),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: onGenerateProof,
                    child: Text(l10n.generateProof),
                  ),
                ),
              if (onDoLater != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: mc.textPrimary,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(80, 25),
                      shape: outlineButtonShape,
                    ),
                    onPressed: onDoLater,
                    child: Text(l10n.doLater),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
