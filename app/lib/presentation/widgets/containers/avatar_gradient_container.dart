import 'package:flutter/material.dart';

class AvatarGradientContainer extends StatelessWidget {
  const AvatarGradientContainer({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHigh;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color.lerp(base, Colors.white, 0.3)!,
            Color.lerp(base, Colors.white, 0.1)!,
            base,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
