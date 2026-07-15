import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../extensions/build_context_extensions.dart';

class CiergeSignatureAttachmentsPlugin implements AttachmentRenderer {
  static const String pluginFormat = CiergeSignatureProof.attachmentFormat;
  static const String signatureGlyph = '.✦ ݁˖';

  @override
  AttachmentPluginIcon get icon => const AssetIcon('assets/sign.png');

  @override
  bool get isPlatformSupported => false;

  @override
  String localizedName(BuildContext context) => 'Signed response';

  @override
  bool supportsFormat(ChatAttachment attachment) =>
      attachment.format == pluginFormat;

  @override
  Widget renderAttachment(AttachmentRenderRequest request) {
    developer.log(
      'renderAttachment format=${request.attachment.format} '
      'id=${request.attachment.id} '
      'hasJson=${request.attachment.data?.json != null} '
      'hasBase64=${request.attachment.data?.base64 != null} '
      'transportId=${request.attachment.transportId}',
      name: 'CiergeSignaturePlugin',
    );

    final inlineProof = CiergeSignatureProof.fromAttachment(request.attachment);
    if (inlineProof != null) {
      developer.log(
        'inline proof parsed '
        'memory=${inlineProof.memory ?? '-'}',
        name: 'CiergeSignaturePlugin',
      );
      return _SignedResponseBadge(proof: inlineProof);
    }

    final download = request.download;
    if (download == null) return const SizedBox.shrink();

    return FutureBuilder<CiergeSignatureProof?>(
      future: () async {
        developer.log(
          'inline proof missing, attempting download '
          'id=${request.attachment.id}',
          name: 'CiergeSignaturePlugin',
        );
        final bytes = await download(request.attachment);
        developer.log(
          'downloaded ${bytes.length} bytes for id=${request.attachment.id}',
          name: 'CiergeSignaturePlugin',
        );
        if (bytes.isEmpty) return null;
        final raw = utf8.decode(bytes, allowMalformed: true);
        return CiergeSignatureProof.fromRawJson(raw);
      }(),
      builder: (context, snapshot) {
        final proof = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (proof == null) {
          developer.log(
            'download path parse failed id=${request.attachment.id}',
            name: 'CiergeSignaturePlugin',
          );
          return const SizedBox.shrink();
        }
        developer.log(
          'download proof parsed '
          'memory=${proof.memory ?? '-'}',
          name: 'CiergeSignaturePlugin',
        );
        return _SignedResponseBadge(proof: proof);
      },
    );
  }

  @override
  Widget renderAttachments(AttachmentListRenderRequest request) {
    if (request.attachments.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: request.attachments
          .map(
            (attachment) => renderAttachment(
              AttachmentRenderRequest(
                attachment: attachment,
                isFromMe: request.isFromMe,
                chatItemColor: request.chatItemColor,
                renderContext: request.renderContext,
                download: request.download,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SignedResponseBadge extends StatelessWidget {
  const _SignedResponseBadge({required this.proof});

  final CiergeSignatureProof proof;

  @override
  Widget build(BuildContext context) {
    const badgeTextColor = Colors.white;
    const badgeBg = Color(0xFF2F3F64);
    const badgeBorder = Color(0xFF9BB2E6);
    const badge = 'Verified response';

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        onTap: () => _showSignedResponseSheet(context, proof),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: badgeBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                CiergeSignatureAttachmentsPlugin.signatureGlyph,
                style: context.textTheme.bodySmall?.copyWith(
                  color: badgeTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                badge,
                style: context.textTheme.bodySmall?.copyWith(
                  color: badgeTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showSignedResponseSheet(
  BuildContext context,
  CiergeSignatureProof proof,
) {
  final textTheme = context.textTheme;
  final color = context.colorScheme.primary;

  Widget row(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF10141D),
    showDragHandle: true,
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      CiergeSignatureAttachmentsPlugin.signatureGlyph,
                      style: textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Signed Response',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(35),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: color.withAlpha(130)),
                      ),
                      child: Text(
                        'Verified',
                        style: textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                row('Domain DID', proof.signerDid),
                row('Model', proof.model),
                row('Timestamp', proof.timestamp),
                row('Memory', proof.memory),
                row('Message ID', proof.messageId),
                row('Token ID', proof.tokenId),
                row('Signature', proof.signature),
              ],
            ),
          ),
        ),
      );
    },
  );
}
