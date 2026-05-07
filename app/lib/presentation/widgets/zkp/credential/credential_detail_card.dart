import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import 'credential_detail_row.dart';

/// Reusable container card for displaying credential details
///
/// Features:
/// - Header with icon, title, and subtitle
/// - Gradient background
/// - Content area for credential details
/// - Colored border
class CredentialDetailCard extends StatelessWidget {
  const CredentialDetailCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.details,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final List<CredentialDetailRowData> details;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: colorScheme.primary, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.5, -1.3),
                  end: const Alignment(0.342, 2.2),
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.7),
                  ],
                  stops: const [0.4, 1.075],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < details.length; i++) ...[
                    CredentialDetailRow(
                      label: details[i].label,
                      value: details[i].value,
                    ),
                    if (i < details.length - 1)
                      Divider(color: colorScheme.primary, height: 16),
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
