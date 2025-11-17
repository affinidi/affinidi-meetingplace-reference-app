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

    final isGroupChat = ref.read(
      provider.select(
        (state) => state.channel?.isGroup,
      ),
    );

    final myProfilePic = ref.watch(
      provider.select(
        (state) {
          if (isGroupChat == true) {
            final otherPartyPic = state.channel?.otherPartyVCard?.profilePic;
            // If group admin (no otherPartyVCard), use vCard instead
            return otherPartyPic ?? state.channel?.vCard?.profilePic;
          }
          return state.channel?.vCard?.profilePic;
        },
      ),
    );

    final hasOtherPartyPic = isGroupChat != null &&
        !isGroupChat &&
        otherPartyProfilePic != null &&
        otherPartyProfilePic.isNotEmpty;
    final hasMyPic = myProfilePic != null && myProfilePic.isNotEmpty;

    final useWhiteBackgroundForOtherParty = !hasOtherPartyPic;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TranslatedPicture(
          offset: const Offset(30, 0),
          image: hasOtherPartyPic
              ? CachedBase64Image(otherPartyProfilePic,
                  cacheManager: cacheManager)
              : isGroupChat != null
                  ? isGroupChat
                      ? groupImage
                      : defaultProfileImage
                  : null,
          backgroundColor:
              useWhiteBackgroundForOtherParty ? Colors.white : null,
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
          backgroundColor: !hasMyPic ? Colors.white : null,
          size: _picSize,
          onPressed: () async {
            final imageBytes = await controller.getImageBytes(
                hasOtherPartyPic: true,
                otherPartyProfilePic:
                    hasMyPic ? myProfilePic : defaultProfileBase64);

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
    this.backgroundColor,
  });

  final ImageProvider<Object>? image;
  final double size;
  final Offset offset;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isGroupOrDefaultImage =
        image == groupImage || image == defaultProfileImage;

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
            backgroundColor: backgroundColor,
            backgroundImage: isGroupOrDefaultImage ? null : image,
            child: isGroupOrDefaultImage && image != null
                ? Image(
                    image: image!,
                    fit: BoxFit.contain,
                    width: 80,
                    height: 80,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
