part of 'contacts_screen.dart';

class _ContactAvatar extends ConsumerWidget {
  const _ContactAvatar({
    required this.contact,
    this.isList = false,
  });

  final Contact contact;
  final bool isList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = contact.getStatusColor(context, asAvatar: true);
    final iconSize = 70.0;
    final cacheManager = ref.read(cacheManagerProvider);

    final displayImage = contact.image(cacheManager: cacheManager);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (contact.isGroup && contact.status == ContactStatus.pendingApproval)
          Positioned(
            top: isList ? -5 : -5,
            right: isList ? -10 : -15,
            child: Icon(
              Icons.star,
              color: statusColor,
              size: isList ? 20 : 24,
            ),
          ),
        AvatarGradientContainer(
          child: CircleAvatar(
            radius: iconSize / 2,
            backgroundColor: Colors.transparent,
            foregroundImage: displayImage,
          ),
        ),
      ],
    );
  }
}
