part of 'audio_video_call_screen.dart';

class _CallControls {
  const _CallControls({
    required this.mic,
    required this.speaker,
    this.camera,
    required this.onEndCall,
  });

  final CallButtonConfig mic;
  final CallButtonConfig speaker;

  /// Null means audio-only — no camera button shown.
  final CallButtonConfig? camera;
  final VoidCallback onEndCall;
}

void _showCallSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onInverseSurface,
          ),
        ),
        backgroundColor: context.colorScheme.error,
        duration: duration,
      ),
    );
  });
}

class _AnimatedControlsOverlay extends StatelessWidget {
  const _AnimatedControlsOverlay({
    required this.visible,
    required this.duration,
    required this.child,
  });

  final bool visible;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallControlsOverlay(
      visible: visible,
      duration: duration,
      child: child,
    );
  }
}

class _ControlsOverlayContent extends StatelessWidget {
  const _ControlsOverlayContent({required this.controls});

  final _CallControls controls;

  @override
  Widget build(BuildContext context) {
    return CallControlsBar(
      mic: controls.mic,
      speaker: controls.speaker,
      camera: controls.camera,
      onEndCall: controls.onEndCall,
    );
  }
}
