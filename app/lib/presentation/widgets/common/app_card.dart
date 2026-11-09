import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

/// A panel card, as on the community page; colour, hairline border and
/// radius come from the card theme, and a 1px lit top edge raises it off
/// the canvas. With [onTap], [onLongPress] or [onDoubleTap] the whole panel
/// responds, with ink clipped to its shape. With [accent], the card carries
/// that identity as Mission Control's top-right corner wash.
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
    this.accent,
  });

  /// Strength of the corner wash. Mission Control's product card uses 7%
  /// at rest and 16% when active; a card shown on its own page is the
  /// active one.
  static const _accentWashStrength = 0.16;

  /// Where the wash fades out, as a share of its reach.
  static const _accentWashFade = 0.6;
  static const _accentWashReach = 1.4;

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;
  final double? elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final Color? accent;

  bool get _isInteractive =>
      onTap != null || onLongPress != null || onDoubleTap != null;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.mcColors.insetTop)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: _accentWash()),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      ),
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

  /// The corner wash, isolated to the top right and never a background.
  RadialGradient? _accentWash() {
    final accent = this.accent;
    if (accent == null) return null;
    return RadialGradient(
      center: Alignment.topRight,
      radius: _accentWashReach,
      colors: [
        accent.withValues(alpha: _accentWashStrength),
        accent.withValues(alpha: 0),
      ],
      stops: const [0, _accentWashFade],
    );
  }
}
