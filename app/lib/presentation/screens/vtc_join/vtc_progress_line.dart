import 'package:flutter/material.dart';

import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_trail_step.dart';

/// A step of something the phone does in the background: a tick once
/// done, a spinner while under way, a dimmed circle while still to come.
class VtcProgressLine extends StatelessWidget {
  const VtcProgressLine({super.key, required this.title, required this.stage});

  final String title;
  final VtcTrailStage stage;

  @override
  Widget build(BuildContext context) {
    final isNext = stage == VtcTrailStage.next;
    return Row(
      spacing: 8,
      children: [
        SizedBox.square(
          dimension: 16,
          child: switch (stage) {
            VtcTrailStage.current => const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
            VtcTrailStage.done => const Icon(
              Icons.check_circle,
              size: 16,
              color: Colors.white,
            ),
            _ => const Icon(
              Icons.radio_button_unchecked,
              size: 16,
              color: Colors.white38,
            ),
          },
        ),
        Flexible(
          child: Text(
            title,
            style: onboardingNote(
              context,
            )?.copyWith(color: isNext ? Colors.white38 : null),
          ),
        ),
      ],
    );
  }
}
