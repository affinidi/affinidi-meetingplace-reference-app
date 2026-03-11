import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import 'label_icon.dart';

class FormRowPicker extends StatelessWidget {
  const FormRowPicker({
    super.key,
    required this.label,
    required this.helperText,
    required this.buttonText,
    required this.onPressed,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String helperText;
  final String buttonText;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: icon != null
              ? LabelIcon(icon: icon, iconColor: iconColor, label: label)
              : null,
          title: Text(
            label,
            style: context.listTileTheme.titleTextStyle?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          trailing: TextButton(
            onPressed: onPressed,
            child: Text(
              buttonText,
              style: context.listTileTheme.leadingAndTrailingTextStyle,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        if (helperText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            child: Text(
              helperText,
              style: context.listTileTheme.subtitleTextStyle,
            ),
          ),
      ],
    );
  }
}
