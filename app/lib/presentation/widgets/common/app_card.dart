import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

/// A panel card, as on the community page; colour, hairline border and
/// radius come from the card theme, and a 1px lit top edge raises it off
/// the canvas. With [onTap], [onLongPress] or [onDoubleTap] the whole panel
/// responds, with ink clipped to its shape.
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
    final content = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.mcColors.insetTop)),
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
    return Card(
      shape: shape,
      elevation: elevation,
      // Clipped so the lit edge follows the rounded top corners.
      clipBehavior: Clip.antiAlias,
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
