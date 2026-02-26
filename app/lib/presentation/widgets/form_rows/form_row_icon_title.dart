import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import 'label_icon.dart';

class FormRowIconTitle extends StatelessWidget {
  const FormRowIconTitle({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.helperText = '',
    this.isCopiable = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? helperText;
  final bool isCopiable;

  Future<void> _copyToClipboard(BuildContext context, String text) async {
    if (!context.mounted || text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.copiedToClipboard),
        duration: const Duration(seconds: 2),
        backgroundColor: context.customColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          dense: true,
          onTap: isCopiable ? () => _copyToClipboard(context, label) : null,
          leading: LabelIcon(
            icon: icon,
            iconColor: iconColor,
            label: label,
          ),
          title: Text(
            label,
            style: context.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(value, style: context.textTheme.bodyMedium),
        ),
        if (helperText != null && helperText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 4.0),
            child: Text(
              helperText!,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
