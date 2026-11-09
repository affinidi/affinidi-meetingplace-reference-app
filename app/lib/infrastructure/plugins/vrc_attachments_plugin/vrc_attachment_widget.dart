import 'package:flutter/material.dart';

import '../../../presentation/themes/tokens/mc_colors.dart';
import '../../../presentation/themes/tokens/mc_radius.dart';
import '../../extensions/build_context_extensions.dart';

class VrcAttachmentWidget extends StatelessWidget {
  const VrcAttachmentWidget({super.key, required this.onTap});

  final VoidCallback? onTap;

  static const double height = 90.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mc = context.mcColors;

    return SizedBox(
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(McRadius.lg),
            border: Border.all(color: mc.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: McColors.controlHoverWash,
                ),
                child: Icon(
                  Icons.verified_user,
                  size: 24,
                  color: mc.highlightSecondary,
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
                    color: mc.textPrimary,
                    fontWeight: FontWeight.w500,
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
