part of 'contacts_screen.dart';

class _ContactNotificationBadge extends StatelessWidget {
  const _ContactNotificationBadge({
    required this.origin,
    required this.badgeCount,
    this.isList = false,
  });

  final ContactOrigin origin;
  final int badgeCount;
  final bool isList;

  @override
  Widget build(BuildContext context) {
    final size = isList ? 28.0 : 32.0;
    final borderWidth = isList ? 3.0 : 5.0;
    final padding = isList
        ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    final textStyle = isList
        ? context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          )
        : context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          );
    final isOobContact = origin == ContactOrigin.directInteractive;
    final badgeColor = isOobContact
        ? context.colorScheme.surfaceContainerHigh
        : origin.color(context);

    return Container(
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colorScheme.surface,
          width: borderWidth,
        ),
      ),
      alignment: Alignment.center,
      padding: isOobContact ? null : padding,
      child: isOobContact
          ? const Icon(
              Icons.notifications_off_outlined,
              color: Colors.white,
              size: 14,
            )
          : Text(
              badgeCount > 99 ? '99+' : '$badgeCount',
              style: textStyle,
              textScaler:
                  (MediaQuery.maybeTextScalerOf(context) ??
                          TextScaler.noScaling)
                      .clamp(maxScaleFactor: 0.8),
            ),
    );
  }
}

class _ContactNewChannelDotBadge extends StatelessWidget {
  const _ContactNewChannelDotBadge({required this.origin, this.isList = false});

  final ContactOrigin origin;
  final bool isList;

  @override
  Widget build(BuildContext context) {
    final size = isList ? 14.0 : 16.0;
    final borderWidth = isList ? 3.0 : 4.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: origin.color(context),
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colorScheme.surface,
          width: borderWidth,
        ),
      ),
    );
  }
}
