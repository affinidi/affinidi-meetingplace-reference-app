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
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSlide(
        duration: duration,
        offset: visible ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: duration,
          opacity: visible ? 1.0 : 0.0,
          child: child,
        ),
      ),
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

class _InCallFlipCameraButton extends StatelessWidget {
  const _InCallFlipCameraButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Positioned(
      top: 10,
      right: 10,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colors.darkGrey.withValues(alpha: 0.75),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.flip_camera_ios, color: colors.pureWhite, size: 16),
        ),
      ),
    );
  }
}

class _InCallMuteButton extends StatelessWidget {
  const _InCallMuteButton({
    required this.isMicEnabled,
    required this.isPermissionError,
    required this.onTap,
  });

  final bool isMicEnabled;
  final bool isPermissionError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Positioned(
      top: 10,
      left: 10,
      child: Opacity(
        opacity: isPermissionError ? 0.4 : 1.0,
        child: GestureDetector(
          onTap: isPermissionError ? null : onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isMicEnabled
                  ? colors.darkGrey.withValues(alpha: 0.75)
                  : colors.pureWhite,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMicEnabled ? Icons.mic : Icons.mic_off,
              color: isMicEnabled ? colors.pureWhite : colors.rose,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
