import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.child,
    required this.onDismiss,
    this.icon = Icons.description_outlined,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
  });

  final Widget child;
  final VoidCallback onDismiss;
  final IconData icon;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primary.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.primary, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: child,
                ),
              ),
            ],
          ),
          Positioned(
            top: -10,
            right: -8,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 28,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
