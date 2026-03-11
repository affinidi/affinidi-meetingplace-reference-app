import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class LabelIcon extends StatelessWidget {
  const LabelIcon({super.key, required this.label, this.icon, this.iconColor});

  final String label;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    if (icon != null && iconColor != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 24,
          height: 24,
          color: iconColor,
          child: Icon(icon, size: 16, color: context.colorScheme.onPrimary),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
