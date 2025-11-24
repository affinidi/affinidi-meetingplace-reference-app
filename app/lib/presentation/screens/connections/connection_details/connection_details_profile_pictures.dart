part of 'connection_details_screen.dart';

class _ProfilePictures extends ConsumerWidget {
  _ProfilePictures(this.contactId);

  final String contactId;

  static final double _picSize = 150.0;

  Future<void> _navigateToImageView(
      {required BuildContext context,
      required Future<Uint8List> imageBytesFuture}) async {
    final imageBytes = await imageBytesFuture;
    if (!context.mounted) return;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (context) => ImageViewScreen(imageBytes: imageBytes),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final cacheManager = ref.read(cacheManagerProvider);
    final controller = ref.read(provider.notifier);

    final contact = ref.watch(
      provider.select((state) => state.contact),
    );
    final isGroupChat = contact?.isGroup ?? false;

    // For group chats, display only the group image
    if (isGroupChat) {
      return Center(
        child: _TranslatedPicture(
          offset: Offset.zero,
          backgroundColor: Colors.white,
          size: _picSize,
          child: _DefaultImage(image: groupImage),
          onPressed: () => _navigateToImageView(
            context: context,
            imageBytesFuture: controller.getImageBytes(
              hasOtherPartyPic: false,
              otherPartyProfilePic: null,
            ),
          ),
        ),
      );
    }

    final channel = ref.watch(
      provider.select((state) => state.channel),
    );

    final hasOtherPartyPic = channel?.hasOtherPartyProfilePic ?? false;
    final hasMyPic = channel?.hasMyProfilePic ?? false;

    final otherPartyImage =
        channel?.otherPartyImage(cacheManager: cacheManager) ??
            defaultProfileImage;
    final myImage =
        channel?.myImage(cacheManager: cacheManager) ?? defaultProfileImage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TranslatedPicture(
          offset: const Offset(30, 0),
          backgroundColor: hasOtherPartyPic ? null : Colors.white,
          backgroundImage: hasOtherPartyPic ? otherPartyImage : null,
          child:
              hasOtherPartyPic ? null : _DefaultImage(image: otherPartyImage),
          size: _picSize,
          onPressed: () => unawaited(
            _navigateToImageView(
              context: context,
              imageBytesFuture: controller.getImageBytes(
                hasOtherPartyPic: hasOtherPartyPic,
                otherPartyProfilePic: channel?.otherPartyVCard?.profilePic,
              ),
            ),
          ),
        ),
        _TranslatedPicture(
          offset: const Offset(-30, 0),
          backgroundColor: hasMyPic ? null : Colors.white,
          backgroundImage: hasMyPic ? myImage : null,
          child: hasMyPic ? null : _DefaultImage(image: myImage),
          size: _picSize,
          onPressed: () => _navigateToImageView(
            context: context,
            imageBytesFuture: controller.getImageBytes(
              hasOtherPartyPic: hasMyPic,
              otherPartyProfilePic: channel?.vCard?.profilePic,
            ),
          ),
        ),
      ],
    );
  }
}

class _TranslatedPicture extends StatelessWidget {
  const _TranslatedPicture({
    required this.size,
    required this.offset,
    this.onPressed,
    this.backgroundColor,
    this.backgroundImage,
    this.child,
  });

  final double size;
  final Offset offset;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final ImageProvider<Object>? backgroundImage;
  final Widget? child;

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
            radius: size / 2,
            backgroundColor: backgroundColor,
            backgroundImage: backgroundImage,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DefaultImage extends StatelessWidget {
  const _DefaultImage({required this.image});

  final ImageProvider<Object> image;

  static const double _defaultImageSize = 80.0;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      fit: BoxFit.contain,
      width: _defaultImageSize,
      height: _defaultImageSize,
    );
  }
}
