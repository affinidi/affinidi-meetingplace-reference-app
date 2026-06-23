import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';

// TODO (earl): Rename to `VrcChatItem` for consistency
class CredentialAttachmentWidget extends StatelessWidget {
  const CredentialAttachmentWidget({super.key, required this.onTap});

  final VoidCallback? onTap;

  static const double height = 90.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    return SizedBox(
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-0.5, -1.3),
              end: const Alignment(0.342, 2.2),
              colors: [Colors.black, colorScheme.primary],
              stops: const [0.4, 1.075],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.primary, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withAlpha(50),
                ),
                child: Icon(
                  Icons.verified_user,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.verifiableRelationshipCredential,
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
