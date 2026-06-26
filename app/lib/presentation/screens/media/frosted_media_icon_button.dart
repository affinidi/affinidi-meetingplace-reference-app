import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class FrostedMediaIconButton extends StatelessWidget {
  const FrostedMediaIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.dimension = 52,
    this.iconSize = 26,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double dimension;
  final double iconSize;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: backgroundColor ?? Colors.black.withValues(alpha: 0.44),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
            iconSize: iconSize,
            constraints: BoxConstraints.tightFor(
              width: dimension,
              height: dimension,
            ),
          ),
        ),
      ),
    );
  }
}
