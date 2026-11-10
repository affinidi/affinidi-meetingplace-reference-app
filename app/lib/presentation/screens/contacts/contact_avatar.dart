part of 'contacts_screen.dart';

class _ContactAvatar extends ConsumerWidget {
  const _ContactAvatar({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconSize = 70.0;
    final cacheManager = ref.read(cacheManagerProvider);

    final displayImage = contact.image(cacheManager: cacheManager);

    return ProfileCircleAvatar(radius: iconSize / 2, image: displayImage);
  }
}
