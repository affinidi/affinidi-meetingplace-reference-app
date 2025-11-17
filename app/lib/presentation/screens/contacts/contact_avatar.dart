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
    final vCard = contact.vCard;
    final statusColor = contact.getStatusColor(context, asAvatar: true);
    final iconSize = 70.0;
    final cacheManager = ref.read(cacheManagerProvider);
    final isGroup = contact.type == ContactType.group;

    final displayImage =
        isGroup ? groupImage : vCard.image(cacheManager: cacheManager);
    final isGroupOrDefaultImage =
        displayImage == groupImage || displayImage == defaultProfileImage;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: statusColor, width: 4),
      ),
      child: CircleAvatar(
        radius: iconSize / 2,
        backgroundColor: isGroupOrDefaultImage ? Colors.white : null,
        backgroundImage: !isGroupOrDefaultImage ? displayImage : null,
        child: isGroupOrDefaultImage
            ? Image(
                image: displayImage,
                fit: BoxFit.contain,
                width: 40,
                height: 40,
              )
            : null,
      ),
    );
  }
}
