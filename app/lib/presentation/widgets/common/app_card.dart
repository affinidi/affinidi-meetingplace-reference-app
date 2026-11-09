import 'package:flutter/material.dart';

/// A panel card, as on the community page; colour, hairline border and
/// radius come from the card theme. With [onTap], [onLongPress] or
/// [onDoubleTap] the whole panel responds, with ink clipped to its shape.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.shape,
    this.elevation,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;
  final double? elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  bool get _isInteractive =>
      onTap != null || onLongPress != null || onDoubleTap != null;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    return Card(
      shape: shape,
      elevation: elevation,
      clipBehavior: _isInteractive ? Clip.antiAlias : null,
      child: _isInteractive
          ? InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              onDoubleTap: onDoubleTap,
              child: content,
            )
          : content,
    );
  }
}
