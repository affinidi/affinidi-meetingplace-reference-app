part of 'audio_video_call_screen.dart';

/// Shared top bar: minimize button (left) + peer name and call status (center).
///
/// Used by both [_AudioCallScreen] and [_VideoCallScreen].
class _CallTopBar extends ConsumerWidget {
  const _CallTopBar({
    required this.contactId,
    required this.onMinimize,
    this.statusPill,
  }) : trailingIcon = null,
       onTrailingPressed = null,
       trailing = null,
       opensParticipantList = false,
       crossAxisAlignment = CrossAxisAlignment.start,
       centerPadding = EdgeInsets.zero;

  const _CallTopBar.group({required this.contactId, required this.onMinimize})
    : trailingIcon = Icons.people_alt_outlined,
      onTrailingPressed = null,
      trailing = null,
      statusPill = null,
      opensParticipantList = true,
      crossAxisAlignment = CrossAxisAlignment.center,
      centerPadding = EdgeInsets.zero;

  const _CallTopBar.cameraSwitch({
    required this.contactId,
    required this.onMinimize,
    required VoidCallback onSwitchCamera,
  }) : trailingIcon = Icons.flip_camera_ios,
       onTrailingPressed = onSwitchCamera,
       trailing = null,
       statusPill = null,
       opensParticipantList = false,
       crossAxisAlignment = CrossAxisAlignment.center,
       centerPadding = EdgeInsets.zero;

  final String contactId;
  final VoidCallback onMinimize;
  final Widget? statusPill;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;
  final Widget? trailing;

  /// When true the trailing button opens the group participant list sheet.
  final bool opensParticipantList;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry centerPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallTopBarWidget(
      contactId: contactId,
      onMinimize: onMinimize,
      trailingIcon: trailingIcon,
      onTrailingPressed: opensParticipantList
          ? () => CallParticipantsSheet.show(context, contactId: contactId)
          : onTrailingPressed,
      trailing: trailing,
      statusPill: statusPill,
      crossAxisAlignment: crossAxisAlignment,
      centerPadding: centerPadding,
    );
  }
}

class _CallTopBarOverlay extends StatelessWidget {
  const _CallTopBarOverlay({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallTopBarOverlay(visible: visible, child: child);
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
