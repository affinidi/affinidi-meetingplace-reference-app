import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

/// Compact mute badge shown on call participant surfaces.
class CallParticipantMuteBadge extends StatelessWidget {
  const CallParticipantMuteBadge({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: Icon(
        Icons.mic_off,
        color: context.customColors.pureWhite,
        size: size * 0.55,
      ),
    );
  }
}
