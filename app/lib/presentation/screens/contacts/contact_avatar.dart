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

    if (contact.type == ContactType.group) {
      final avatarSize = isList ? 30 : 54;
      const double overlap = 30;

      return SizedBox(
        width: avatarSize + overlap,
        height: avatarSize + overlap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (contact.status == ContactStatus.pendingApproval)
              Positioned(
                top: isList ? -5 : -5,
                right: isList ? 0 : -5,
                child: Icon(
                  Icons.star,
                  color: statusColor,
                  size: isList ? 20 : 24,
                ),
              ),
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 4),
                ),
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundImage:
                      contact.otherPartyImage(cacheManager: cacheManager),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 4),
                ),
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundImage: vCard.image(cacheManager: cacheManager),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: statusColor, width: 4),
      ),
      child: CircleAvatar(
        radius: iconSize / 2,
        backgroundImage: vCard.image(cacheManager: cacheManager),
      ),
    );
  }
}
