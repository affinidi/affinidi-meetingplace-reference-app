part of 'audio_video_call_screen.dart';

class _CallParticipantTile extends ConsumerWidget {
  const _CallParticipantTile({
    required this.participant,
    required this.session,
    required this.isAudioOnly,
    required this.contactCard,
    required this.displayName,
    this.borderRadius = 12,
  });

  final AudioVideoCallParticipant participant;
  final AudioVideoCallSession? session;
  final bool isAudioOnly;
  final ContactCard? contactCard;
  final String displayName;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.customColors;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final cacheManager = ref.read(cacheManagerProvider);
    final participantDid = participant.did;
    final identityCard = ref.watch(
      identitiesServiceProvider.select(
        (state) =>
            state.currentIdentity?.card ?? state.identities.firstOrNull?.card,
      ),
    );
    final contactStoreCard = participantDid == null || participantDid.isEmpty
        ? null
        : ref.watch(
            contactsServiceProvider.select(
              (state) =>
                  state.getContactByChannelDid(participantDid)?.card ??
                  state.getContactByCardDid(participantDid)?.card,
            ),
          );
    final resolvedContactCard = resolveBestAvatarCard([
      if (participant.isSelf) identityCard,
      contactCard,
      contactStoreCard,
    ]);
    final image =
        resolvedContactCard?.image(cacheManager: cacheManager) ??
        defaultProfileImage;

    final showVideo = !isAudioOnly && participant.hasVideo;

    return Container(
      decoration: BoxDecoration(
        color: colors.grey900,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (showVideo)
              Positioned.fill(
                child: IgnorePointer(
                  child: AudioVideoCallView(
                    session: session,
                    participantId: participant.participantId,
                    hasVideo: participant.hasVideo,
                    mirror: participant.isSelf,
                  ),
                ),
              )
            else
              Center(child: ProfileCircleAvatar(radius: 36, image: image)),
            if (displayName.isNotEmpty)
              Positioned(
                bottom: 8,
                left: 8,
                child: Text(
                  displayName,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface,
                    shadows: const [Shadow(blurRadius: 4)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
