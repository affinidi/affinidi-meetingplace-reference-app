import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';

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
      // Over media: stays dark in both modes.
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: Icon(
        McIcons.micOff,
        color: context.customColors.pureWhite,
        size: size * 0.55,
      ),
    );
  }
}
