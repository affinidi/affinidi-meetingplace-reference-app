import 'package:flutter/material.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';

class CallButtonConfig {
  const CallButtonConfig({
    required this.onTap,
    this.isEnabled = true,
    this.isDisabled = false,
  });

  final VoidCallback onTap;
  final bool isEnabled;
  final bool isDisabled;
}

class CallControlsBar extends StatelessWidget {
  const CallControlsBar({
    super.key,
    required this.mic,
    required this.speaker,
    required this.onEndCall,
    this.camera,
  });

  final CallButtonConfig mic;
  final CallButtonConfig speaker;
  final CallButtonConfig? camera;
  final VoidCallback onEndCall;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: colors.darkGrey.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (camera != null)
                _ControlButton(
                  icon: camera!.isEnabled ? Icons.videocam : Icons.videocam_off,
                  isActive: camera!.isEnabled && !camera!.isDisabled,
                  isDisabled: camera!.isDisabled,
                  onTap: camera!.onTap,
                ),
              _ControlButton(
                icon: Icons.volume_up,
                isActive: speaker.isEnabled,
                onTap: speaker.onTap,
              ),
              _ControlButton(
                icon: mic.isEnabled ? Icons.mic : Icons.mic_off,
                isActive: !mic.isEnabled && !mic.isDisabled,
                isDisabled: mic.isDisabled,
                onTap: mic.onTap,
                isMic: true,
              ),
              _ControlButton(
                icon: Icons.call_end,
                isActive: false,
                isEndCall: true,
                onTap: onEndCall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.isDisabled = false,
    this.isEndCall = false,
    this.isMic = false,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDisabled;
  final bool isEndCall;
  final bool isMic;

  ({Color container, Color icon}) _resolveColors(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    const gray = Color.fromARGB(255, 37, 39, 42);

    return switch ((isEndCall, isDisabled, isMic, isActive)) {
      (true, _, _, _) => (container: colorScheme.error, icon: colors.pureWhite),
      (_, true, _, _) => (container: gray, icon: colors.pureWhite),
      (_, false, true, true) => (container: colors.pureWhite, icon: Colors.red),
      (_, false, true, false) => (container: gray, icon: colors.pureWhite),
      (_, false, false, true) => (
        container: colors.pureWhite,
        icon: Colors.black,
      ),
      _ => (container: gray, icon: colors.pureWhite),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(context);

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.container,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colors.icon, size: 26),
        ),
      ),
    );
  }
}
