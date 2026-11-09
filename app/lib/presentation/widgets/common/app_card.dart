import 'package:flutter/material.dart';

/// A panel card; colour, hairline border and radius come from the card
/// theme.
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
      shape: shape,
      elevation: elevation,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0.0),
        child: child,
      ),
    );
  }
}
