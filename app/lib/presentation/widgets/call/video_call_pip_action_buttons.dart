import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

/// Circular mute/unmute button for the PiP window.
class VideoCallPiPMuteButton extends StatelessWidget {
  const VideoCallPiPMuteButton({
    super.key,
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

/// Circular expand button to maximize the PiP window.
class VideoCallPiPExpandButton extends StatelessWidget {
  const VideoCallPiPExpandButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Positioned(
      top: 10,
      right: 44,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colors.darkGrey.withValues(alpha: 0.75),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.open_in_full, color: colors.pureWhite, size: 14),
        ),
      ),
    );
  }
}

/// Circular flip-camera button for the PiP window.
class VideoCallPiPFlipCameraButton extends StatelessWidget {
  const VideoCallPiPFlipCameraButton({
    super.key,
    required this.isPermissionError,
    required this.onTap,
  });

  final bool isPermissionError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Positioned(
      top: 10,
      right: 10,
      child: Opacity(
        opacity: isPermissionError ? 0.4 : 1.0,
        child: GestureDetector(
          onTap: isPermissionError ? null : onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.darkGrey.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flip_camera_ios,
              color: colors.pureWhite,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
