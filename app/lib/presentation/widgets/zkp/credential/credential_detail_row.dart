import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';

/// Data model for a single detail row in a credential
class CredentialDetailRowData {
  const CredentialDetailRowData({required this.label, required this.value});

  final String label;
  final String value;
}

/// Reusable widget for displaying credential detail rows
class CredentialDetailRow extends StatelessWidget {
  const CredentialDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: textTheme.labelLarge?.copyWith(color: mc.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(color: mc.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
