import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../themes/tokens/mc_radius.dart';
import 'credential_detail_row.dart';

/// Reusable container card for displaying credential details
///
/// Features:
/// - Header with icon, title, and subtitle
/// - Panel background
/// - Content area for credential details
/// - Hairline border
class CredentialDetailCard extends StatelessWidget {
  const CredentialDetailCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.details = const [],
    this.body,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final List<CredentialDetailRowData> details;
  final Widget? body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  Icon(
                    Icons.verified_rounded,
                    color: mc.highlightSecondary,
                    size: 24,
                  ),
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
            // Body with details
            Container(
              padding: const EdgeInsets.all(24),
              child:
                  body ??
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < details.length; i++) ...[
                        CredentialDetailRow(
                          label: details[i].label,
                          value: details[i].value,
                        ),
                        if (i < details.length - 1)
                          Divider(color: mc.hairline, height: 16),
                      ],
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
