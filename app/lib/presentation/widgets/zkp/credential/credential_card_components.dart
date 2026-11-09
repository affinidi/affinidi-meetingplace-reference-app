import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../themes/tokens/mc_icons.dart';
import '../../../themes/tokens/mc_radius.dart';

/// Data model for a single detail row in a credential card.
class CredentialDetailRowData {
  const CredentialDetailRowData({
    required this.label,
    required this.value,
    this.icon,
    this.subRows,
  });

  final IconData? icon;
  final String label;
  final String value;
  final List<CredentialDetailRowData>? subRows;
}

/// Reusable container card that wraps credential details.
class CredentialCardContainer extends StatelessWidget {
  const CredentialCardContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
  });

  final String title;
  final String subtitle;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(McRadius.xl),
        border: Border.all(color: mc.hairline),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: mc.hairline)),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(McIcons.verified, color: mc.highlightSecondary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: mc.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.labelMedium?.copyWith(
                          color: mc.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Container(padding: const EdgeInsets.all(24), child: content),
        ],
      ),
    );
  }
}
