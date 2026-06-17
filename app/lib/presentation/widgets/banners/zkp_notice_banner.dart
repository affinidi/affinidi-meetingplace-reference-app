import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../screens/chat/chat_items/concierge_message.dart';
import '../../themes/app_custom_colors.dart';

/// Types of ZKP notices that can be displayed
enum ZkpNoticeType {
  /// User shared a proof
  shared,

  /// User received a proof
  received,

  /// User received a proof request
  request,

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
    final colorScheme = context.colorScheme;
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
          gradient: LinearGradient(
            begin: const Alignment(-0.5, -1.3),
            end: const Alignment(0.342, 2.2),
            colors: [Colors.black, colorScheme.primary],
            stops: const [0.4, 1.075],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFromMe
                ? colorScheme.primary
                : colorScheme.surfaceContainerHigh,
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withAlpha(77),
              ),
              child: const Icon(
                Icons.how_to_reg,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.humanZkp,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
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

  static const _cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    gradient: RadialGradient(
      center: Alignment.bottomCenter,
      radius: 2,
      colors: [
        AppCustomColors.conciergeCardGradientStart,
        AppCustomColors.conciergeCardGradientEnd,
      ],
    ),
  );

  static final _outlineButtonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
    side: const BorderSide(color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(10),
      decoration: _cardDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            l10n.genWordConciergeMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            l10n.zkpNoticeRequest(contactName ?? l10n.proofFlowThisContact),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onGenerateProof != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppCustomColors.conciergeActionOnWhite,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      minimumSize: const Size(80, 25),
                      shape: _outlineButtonShape,
                    ),
                    onPressed: onGenerateProof,
                    child: Text(
                      l10n.generateProof,
                      style: const TextStyle(
                        color: AppCustomColors.conciergeActionOnWhite,
                      ),
                    ),
                  ),
                ),
              if (onDoLater != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(80, 25),
                      shape: _outlineButtonShape,
                    ),
                    onPressed: onDoLater,
                    child: Text(
                      l10n.doLater,
                      style: const TextStyle(color: Colors.white),
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
