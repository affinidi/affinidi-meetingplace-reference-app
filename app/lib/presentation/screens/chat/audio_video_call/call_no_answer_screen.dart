part of 'audio_video_call_screen.dart';

/// No-answer end screen for missed or declined calls.
///
/// Renders mode-specific UI: audio calls show avatar + name + message,
/// video calls show a darker surface with the same layout.
class _CallNoAnswerScreen extends ConsumerWidget {
  const _CallNoAnswerScreen({
    required this.contactId,
    required this.mediaType,
    required this.peerName,
    required this.message,
    this.calleeAvatarImage,
  });

  final String contactId;
  final CallMediaType mediaType;
  final String peerName;
  final String message;
  final ImageProvider<Object>? calleeAvatarImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      audioVideoCallScreenControllerProvider(contactId).notifier,
    );
    final callIsAudioOnly = ref.read(
      audioVideoCallScreenControllerProvider(
        contactId,
      ).select((s) => s.isAudioOnly),
    );
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isAudioOnly = mediaType == CallMediaType.audio;

    final backgroundColor = isAudioOnly
        ? colorScheme.surface
        : colors.callControlSurface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  if (isAudioOnly)
                    _CallEndAvatar(image: calleeAvatarImage)
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 24),
                  Text(
                    peerName,
                    style: textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _CallNoAnswerActionBar(
                isAudioOnly: isAudioOnly,
                onCancel: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
                onCallAgain: () => unawaited(
                  controller.restartCall(isAudioOnly: callIsAudioOnly),
                ),
                cancelContainerColor: isAudioOnly
                    ? colors.callControlSurface
                    : colorScheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar for end-call UI, with placeholder fallback.
/// Uses the app-wide [ProfileCircleAvatar] pattern for consistency.
class _CallEndAvatar extends StatelessWidget {
  const _CallEndAvatar({required this.image});

  final ImageProvider<Object>? image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ProfileCircleAvatar(
        radius: 75,
        image: image,
        child: Icon(
          Icons.person,
          size: 75,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _CallNoAnswerActionBar extends StatelessWidget {
  const _CallNoAnswerActionBar({
    required this.isAudioOnly,
    required this.onCancel,
    required this.onCallAgain,
    required this.cancelContainerColor,
  });

  final bool isAudioOnly;
  final VoidCallback onCancel;
  final VoidCallback onCallAgain;
  final Color cancelContainerColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final l10n = context.l10n;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _CallNoAnswerActionButton(
              icon: Icons.close,
              label: l10n.videoCallCancel,
              iconColor: colorScheme.onSurface,
              containerColor: cancelContainerColor,
              onTap: onCancel,
            ),
            const SizedBox(width: 80),
            _CallNoAnswerActionButton(
              icon: isAudioOnly ? Icons.call : Icons.videocam,
              label: l10n.videoCallAgain,
              iconColor: colors.pureWhite,
              containerColor: colors.success,
              onTap: onCallAgain,
            ),
          ],
        ),
      ),
    );
  }
}

class _CallNoAnswerActionButton extends StatelessWidget {
  const _CallNoAnswerActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.containerColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color containerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: containerColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
