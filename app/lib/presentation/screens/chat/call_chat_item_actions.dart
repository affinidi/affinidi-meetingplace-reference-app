part of 'chat_screen.dart';

/// Bottom-sheet shown when tapping a completed (ended / missed / declined)
/// call chat item, offering to re-initiate a call of the same kind.
class _CallChatItemActions extends ConsumerWidget {
  const _CallChatItemActions({
    required this._contactId,
    required this._mediaType,
  });

  final String _contactId;
  final CallMediaType _mediaType;

  static Future<void> show({
    required BuildContext context,
    required String contactId,
    required CallMediaType mediaType,
  }) async => await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        _CallChatItemActions(contactId: contactId, mediaType: mediaType),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final displayName = ref.watch(provider.navigationBarTitle);
    final isAudioOnly = _mediaType == CallMediaType.audio;

    void call() {
      Navigator.of(context).pop();
      context.push(
        AudioVideoCallRoute(
          contactId: _contactId,
          isAudioOnly: isAudioOnly,
        ).location,
      );
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: BottomSheetMenu(
        showHandle: true,
        itemCount: 1,
        itemBuilder: (context, index) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                displayName,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                isAudioOnly ? Icons.call : Icons.videocam,
                color: Colors.white,
                size: 28,
              ),
              title: Text(
                context.l10n.videoCallTitle,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              onTap: call,
            ),
          ],
        ),
      ),
    );
  }
}
