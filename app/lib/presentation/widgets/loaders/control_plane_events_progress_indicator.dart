import 'package:flutter/material.dart' hide LinearProgressIndicator;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/services/control_plane_service/control_plane_service.dart';
import 'linear_progress_indicator.dart';

class ControlPlaneEventsProgressIndicator extends ConsumerWidget {
  const ControlPlaneEventsProgressIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = ref.watch(
      controlPlaneServiceProvider.select((s) => s.isProcessing),
    );

    return SizedBox(
      height: 3,
      child: isProcessing ? LinearProgressIndicator() : const SizedBox.shrink(),
    );
  }
}
