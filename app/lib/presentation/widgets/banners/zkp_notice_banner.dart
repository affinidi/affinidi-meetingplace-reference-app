import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../screens/chat/chat_items/concierge_message.dart';

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
          contactName: contactName,
          onGenerateProof: onGenerateProof,
          onDoLater: onDoLater,
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
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConciergeMessage(
            dateCreated: dateCreated,
            message: message,
            fullWidth: true,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              margin: isFromMe
                  ? const EdgeInsets.only(left: 60)
                  : const EdgeInsets.only(right: 60),
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
                      : const Color(0xFF2E3035),
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
                      color: Color(0x4D0368C0),
                    ),
                    child: Icon(
                      Icons.verified_user,
                      size: 22,
                      color: colorScheme.primary,
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
          ),
        ],
      ),
    );
  }
}

/// Widget displaying a proof request notice
class _ProofRequestNotice extends StatelessWidget {
  const _ProofRequestNotice({
    this.contactName,
    this.onGenerateProof,
    this.onDoLater,
  });

  final String? contactName;
  final VoidCallback? onGenerateProof;
  final VoidCallback? onDoLater;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 2,
          colors: [
            Color.fromARGB(255, 76, 76, 76),
            Color.fromARGB(255, 31, 31, 31),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            context.l10n.genWordConciergeMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.zkpNoticeRequest(
              contactName ?? context.l10n.proofFlowThisContact,
            ),
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
                      backgroundColor: colorScheme.onSurface,
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      minimumSize: const Size(80, 25),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        side: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    onPressed: onGenerateProof,
                    child: Text(
                      context.l10n.generateProof,
                      style: TextStyle(
                        color: colorScheme.surface.withValues(alpha: 0.8),
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
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        side: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    onPressed: onDoLater,
                    child: Text(
                      context.l10n.doLater,
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
