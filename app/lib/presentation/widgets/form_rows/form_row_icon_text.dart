import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import 'label_icon.dart';

class FormRowIconText extends StatelessWidget {
  const FormRowIconText({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.helperText = '',
    this.labelStyle,
    this.valueStyle,
    this.isCopiable = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final String? helperText;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
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
          onTap: () => isCopiable ? _copyToClipboard(context, label) : null,
          leading: LabelIcon(
            icon: icon,
            iconColor: iconColor,
            label: label,
          ),
          title: Text(
            label,
            style: labelStyle,
          ),
          trailing: value != null
              ? Text(
                  value!,
                  style: valueStyle,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
