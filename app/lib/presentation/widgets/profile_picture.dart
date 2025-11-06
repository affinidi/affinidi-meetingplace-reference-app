import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    super.key,
    this.image,
    this.size = 150.0,
    this.border = 6.0,
    this.displayMode = true,
  });

  final ImageProvider<Object>? image;
  final double size;
  final double border;
  final bool displayMode;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return const SizedBox.shrink();
    }

    return Container(
      clipBehavior: Clip.none,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: displayMode
            ? Border.all(
                color: context.theme.scaffoldBackgroundColor,
                width: border,
              )
            : null,
      ),
      child: CircleAvatar(
        radius: (size - border) / 2,
        foregroundImage: image,
      ),
    );
  }
}
