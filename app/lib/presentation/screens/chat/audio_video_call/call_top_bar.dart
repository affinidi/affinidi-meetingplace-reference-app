part of 'audio_video_call_screen.dart';

String _formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// Shared top bar: minimize button (left) + peer name and call status (center).
///
/// Used by both [_AudioCallScreen] and [_VideoCallScreen].
class _CallTopBar extends ConsumerWidget {
  const _CallTopBar({required this.contactId, required this.onMinimize});

  final String contactId;
  final VoidCallback onMinimize;

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

    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onMinimize,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.darkGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_fullscreen,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                peerName,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                switch (phase) {
                  CallUiPhase.inCall => _formatDuration(callDurationSeconds),
                  CallUiPhase.ringing => context.l10n.videoCallRinging,
                  CallUiPhase.calling ||
                  CallUiPhase.ended => context.l10n.videoCallCalling,
                },
                style: textTheme.titleMedium?.copyWith(
                  color: isRinging
                      ? colorScheme.onSurface.withAlpha(153)
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
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
  const _CallPersonAvatar();

  static const double _diameter = 192;

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
        Icons.person,
        size: _diameter / 2,
        color: colorScheme.onSurface,
      ),
    );
  }
}
