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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(McRadius.lg),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHigh,
        ),
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
                    color: context.mcColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: context.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(McRadius.md),
                    side: BorderSide(color: context.mcColors.hairline),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(McRadius.md),
                    onTap: call,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAudioOnly ? Icons.call : Icons.videocam,
                            color: context.mcColors.textPrimary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.l10n.videoCallTitle,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.mcColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
