import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../themes/tokens/mc_colors.dart';
import '../themes/tokens/mc_radius.dart';

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
    final mc = context.mcColors;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerLow,
        border: Border.all(color: mc.hairline),
        borderRadius: BorderRadius.circular(McRadius.md),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: McColors.blue, size: 40),
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
              icon: Icon(Icons.close, color: mc.textTertiary, size: 28),
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
