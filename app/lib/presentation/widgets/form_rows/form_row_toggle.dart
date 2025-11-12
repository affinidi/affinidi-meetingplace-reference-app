import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import 'label_icon.dart';

class FormRowToggle extends StatelessWidget {
  const FormRowToggle({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helperText,
    this.switchKey,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? helperText;
  final Key? switchKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: LabelIcon(
            icon: icon,
            iconColor: iconColor,
            label: label,
          ),
          title: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
            ),
          ),
          trailing: Switch.adaptive(
            key: switchKey,
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.colorScheme.primary,
            inactiveThumbColor: context.colorScheme.onSurfaceVariant,
            inactiveTrackColor: context.colorScheme.surfaceContainerHighest,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        if (helperText?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
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
