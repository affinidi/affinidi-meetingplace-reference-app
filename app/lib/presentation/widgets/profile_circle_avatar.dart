import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';

class ProfileCircleAvatar extends StatelessWidget {
  const ProfileCircleAvatar({super.key, this.image, this.radius, this.child});

  final ImageProvider<Object>? image;
  final double? radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return _AvatarContainer(
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: radius,
        foregroundImage: image,
        child: image == null ? child : null,
      ),
    );
  }
}

class _AvatarContainer extends StatelessWidget {
  const _AvatarContainer({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colorScheme.surfaceContainerHigh,
        border: Border.all(color: context.mcColors.hairline),
      ),
      child: child,
    );
  }
}
