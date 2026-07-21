import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

/// Circular icon button used in the call top bar.
class CallTopBarActionButton extends StatelessWidget {
  const CallTopBarActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.darkGrey,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 22),
      ),
    );
  }
}

/// Animated top-bar overlay that fades in and out based on visibility.
class CallTopBarOverlay extends StatelessWidget {
  const CallTopBarOverlay({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: visible ? 1.0 : 0.0,
        child: IgnorePointer(ignoring: !visible, child: child),
      ),
    );
  }
}

/// Animated bottom-controls overlay that slides up and fades based on
/// visibility.
class CallControlsOverlay extends StatelessWidget {
  const CallControlsOverlay({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 100),
  });

  final bool visible;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedSlide(
          duration: duration,
          offset: visible ? Offset.zero : const Offset(0, 1),
          child: AnimatedOpacity(
            duration: duration,
            opacity: visible ? 1.0 : 0.0,
            child: child,
          ),
        ),
      ),
    );
  }
}
