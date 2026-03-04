import 'package:flutter/material.dart';

class ProfileCircleAvatar extends StatelessWidget {
  const ProfileCircleAvatar({
    super.key,
    this.image,
    this.radius,
    this.child,
  });

  final ImageProvider<Object>? image;
  final double? radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return _AvatarGradientContainer(
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: radius,
        foregroundImage: image,
        child: child,
      ),
    );
  }
}

class _AvatarGradientContainer extends StatelessWidget {
  const _AvatarGradientContainer({
    this.child,
  });

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
