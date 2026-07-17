part of 'audio_video_call_screen.dart';

/// Shared top bar: minimize button (left) + peer name and call status (center).
///
/// Used by both [_AudioCallScreen] and [_VideoCallScreen].
class _CallTopBar extends ConsumerWidget {
  const _CallTopBar({required this.contactId, required this.onMinimize})
    : trailingIcon = null,
      onTrailingPressed = null;

  const _CallTopBar.group({required this.contactId, required this.onMinimize})
    : trailingIcon = Icons.people_alt_outlined,
      onTrailingPressed = _noop;

  const _CallTopBar.cameraSwitch({
    required this.contactId,
    required this.onMinimize,
    required VoidCallback onSwitchCamera,
  }) : trailingIcon = Icons.flip_camera_ios,
       onTrailingPressed = onSwitchCamera;

  final String contactId;
  final VoidCallback onMinimize;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;

  static void _noop() {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = audioVideoCallScreenControllerProvider(contactId);
    final peerName = ref.watch(provider.select((s) => s.peerName));
    final phase = ref.watch(
      provider.select(
        (s) => resolveCallUiPhase(status: s.status, hasHadPeer: s.hasHadPeer),
      ),
    );
    final callDurationSeconds = ref.watch(
      provider.select((s) => s.callDurationSeconds),
    );
    final isRinging = phase != CallUiPhase.inCall;

    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _CallTopBarActionButton(
            icon: Icons.close_fullscreen,
            onPressed: onMinimize,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  peerName,
                  style: textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  switch (phase) {
                    CallUiPhase.inCall => Duration(
                      seconds: callDurationSeconds,
                    ).label,
                    CallUiPhase.ringing => context.l10n.videoCallRinging,
                    CallUiPhase.calling ||
                    CallUiPhase.ended => context.l10n.videoCallCalling,
                  },
                  style: textTheme.titleMedium?.copyWith(
                    color: isRinging
                        ? colorScheme.onSurface.withAlpha(153)
                        : colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailingIcon != null && onTrailingPressed != null)
            _CallTopBarActionButton(
              icon: trailingIcon!,
              onPressed: onTrailingPressed!,
            )
          else
            const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

class _CallTopBarActionButton extends StatelessWidget {
  const _CallTopBarActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.darkGrey,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: 22),
      ),
    );
  }
}

class _CallTopBarOverlay extends StatelessWidget {
  const _CallTopBarOverlay({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: visible ? 1.0 : 0.0,
        child: IgnorePointer(ignoring: !visible, child: child),
      ),
    );
  }
}

/// Shared gradient person avatar placeholder.
///
/// Used in [_AudioCallScreen] (large center avatar when no profile picture).
class _CallPersonAvatar extends StatelessWidget {
  const _CallPersonAvatar({this.isGroup = false});

  static const double _diameter = 192;

  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final colors = context.customColors;

    return Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color.lerp(
              colorScheme.surfaceContainerHigh,
              colors.pureWhite,
              0.3,
            )!,
            Color.lerp(
              colorScheme.surfaceContainerHigh,
              colors.pureWhite,
              0.1,
            )!,
            colorScheme.surfaceContainerHigh,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Icon(
        isGroup ? Icons.group : Icons.person,
        size: _diameter / 2,
        color: colors.pureWhite,
      ),
    );
  }
}
