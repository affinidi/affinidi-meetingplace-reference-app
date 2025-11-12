part of 'connection_details_screen.dart';

class _ProfilePictures extends ConsumerWidget {
  _ProfilePictures(this.contactId);

  final String contactId;

  static final double _picSize = 150.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final cacheManager = ref.read(cacheManagerProvider);
    final otherPartyProfilePic = ref.watch(
      provider.select(
        (state) => state.channel?.otherPartyVCard?.profilePic,
      ),
    );
    final controller = ref.read(provider.notifier);

    final myProfilePic = ref.watch(
      provider.select(
        (state) => state.channel?.vCard?.profilePic,
      ),
    );

    final hasOtherPartyPic =
        otherPartyProfilePic != null && otherPartyProfilePic.isNotEmpty;
    final hasMyPic = myProfilePic != null && myProfilePic.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TranslatedPicture(
          offset: const Offset(30, 0),
          image: hasOtherPartyPic
              ? CachedBase64Image(otherPartyProfilePic,
                  cacheManager: cacheManager)
              : defaultProfileImage,
          size: _picSize,
          onPressed: () async {
            final imageBytes = await controller.getImageBytes(
                hasOtherPartyPic: hasOtherPartyPic,
                otherPartyProfilePic: otherPartyProfilePic);

            if (!context.mounted) return;

            unawaited(Navigator.of(
              context,
              rootNavigator: true,
            ).push(
              MaterialPageRoute(
                builder: (context) => ImageViewScreen(
                  imageBytes: imageBytes,
                ),
              ),
            ));
          },
        ),
        _TranslatedPicture(
          offset: const Offset(-30, 0),
          image: hasMyPic
              ? CachedBase64Image(myProfilePic, cacheManager: cacheManager)
              : defaultProfileImage,
          size: _picSize,
          onPressed: () async {
            final imageBytes = await controller.getImageBytes(
                hasOtherPartyPic: hasMyPic, otherPartyProfilePic: myProfilePic);

            if (!context.mounted) return;

            await Navigator.of(
              context,
              rootNavigator: true,
            ).push<MediaReviewResult>(
              MaterialPageRoute(
                builder: (context) => ImageViewScreen(
                  imageBytes: imageBytes,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TranslatedPicture extends StatelessWidget {
  const _TranslatedPicture({
    required this.image,
    required this.size,
    required this.offset,
    this.onPressed,
  });

  final ImageProvider<Object> image;
  final double size;
  final Offset offset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: context.colorScheme.surface,
            width: 8.0,
          ),
        ),
        child: GestureDetector(
          onTap: onPressed,
          child: CircleAvatar(
            radius: size / 2, // match size dynamically
            backgroundImage: image,
          ),
        ),
      ),
    );
  }
}
