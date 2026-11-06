import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import 'vtc_trail_step.dart';

/// A step of something the phone does in the background: a tick once
/// done, a spinner while under way, a dimmed circle while still to come.
class VtcProgressLine extends StatelessWidget {
  const VtcProgressLine({super.key, required this.title, required this.stage});

  final String title;
  final VtcTrailStage stage;

  /// The size of the marker beside the line, to match its text.
  static const _markerSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final isNext = stage == VtcTrailStage.next;
    return Row(
      spacing: 12,
      children: [
        SizedBox.square(
          dimension: _markerSize,
          child: switch (stage) {
            VtcTrailStage.current => const Padding(
              padding: EdgeInsets.all(2),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            VtcTrailStage.done => const Icon(
              Icons.check_circle,
              size: _markerSize,
              color: Colors.white,
            ),
            _ => const Icon(
              Icons.radio_button_unchecked,
              size: _markerSize,
              color: Colors.white38,
            ),
          },
        ),
        Flexible(
          child: Text(
            title,
            style: context.textTheme.bodyLarge?.copyWith(
              color: isNext ? Colors.white38 : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
