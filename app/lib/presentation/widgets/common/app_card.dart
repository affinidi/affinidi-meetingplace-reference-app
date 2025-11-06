import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.shape,
    this.elevation,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.inverseSurface.withValues(alpha: 0.5),
      shape: shape,
      elevation: elevation,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0.0),
        child: child,
      ),
    );
  }
}
