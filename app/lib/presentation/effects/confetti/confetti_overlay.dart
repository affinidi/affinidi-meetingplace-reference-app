import 'package:flutter/material.dart';

import 'confetti_effect.dart';

/// [child] with confetti blasting over the whole of it once [celebrate]
/// turns true, without catching taps.
class ConfettiOverlay extends StatelessWidget {
  const ConfettiOverlay({
    super.key,
    required this.celebrate,
    required this.child,
  });

  final bool celebrate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (celebrate)
          const Positioned.fill(
            child: IgnorePointer(
              child: ConfettiEffect(key: Key('confetti_overlay')),
            ),
          ),
      ],
    );
  }
}
