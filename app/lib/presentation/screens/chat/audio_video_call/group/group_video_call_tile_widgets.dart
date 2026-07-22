part of '../group_video_call_screen.dart';

class _ParticipantGrid extends StatelessWidget {
  const _ParticipantGrid({
    required this.tileColumns,
    required this.tileHeight,
    required this.entries,
    required this.session,
    required this.memberContactCards,
    required this.isCameraEnabled,
    required this.onTapParticipant,
  });

  final int tileColumns;
  final double tileHeight;
  final List<ParticipantTileData> entries;
  final AudioVideoCallSession? session;
  final Map<String, ContactCard> memberContactCards;
  final bool isCameraEnabled;
  final ValueChanged<String?> onTapParticipant;

  @override
  Widget build(BuildContext context) {
    final rows = _rowsForEntries(entries);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          _ParticipantRow(
            tileColumns: tileColumns,
            tileHeight: tileHeight,
            entries: rows[rowIndex],
            session: session,
            memberContactCards: memberContactCards,
            isCameraEnabled: isCameraEnabled,
            onTapParticipant: onTapParticipant,
          ),
          if (rowIndex != rows.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  List<List<ParticipantTileData>> _rowsForEntries(
    List<ParticipantTileData> entries,
  ) {
    final rows = <List<ParticipantTileData>>[];
    for (var index = 0; index < entries.length; index += tileColumns) {
      final end = (index + tileColumns) > entries.length
          ? entries.length
          : index + tileColumns;
      rows.add(entries.sublist(index, end));
    }
    return rows;
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.tileColumns,
    required this.tileHeight,
    required this.entries,
    required this.session,
    required this.memberContactCards,
    required this.isCameraEnabled,
    required this.onTapParticipant,
  });

  final int tileColumns;
  final double tileHeight;
  final List<ParticipantTileData> entries;
  final AudioVideoCallSession? session;
  final Map<String, ContactCard> memberContactCards;
  final bool isCameraEnabled;
  final ValueChanged<String?> onTapParticipant;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          Expanded(
            child: _ParticipantTile(
              entry: entries[index],
              tileHeight: tileHeight,
              session: session,
              memberContactCards: memberContactCards,
              isCameraEnabled: isCameraEnabled,
              onTap: () => onTapParticipant(entries[index].participantId),
            ),
          ),
          if (index != entries.length - 1) const SizedBox(width: 8),
        ],
        for (var index = entries.length; index < tileColumns; index++) ...[
          const Expanded(child: SizedBox.shrink()),
          if (index != tileColumns - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.entry,
    required this.tileHeight,
    required this.session,
    required this.memberContactCards,
    required this.isCameraEnabled,
    required this.onTap,
  });

  final ParticipantTileData entry;
  final double tileHeight;
  final AudioVideoCallSession? session;
  final Map<String, ContactCard> memberContactCards;
  final bool isCameraEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final presentation = resolveGroupCallParticipantPresentation(
      participant: entry.participant,
      isCameraEnabled: isCameraEnabled,
      isFocusedStage: false,
      isFullScreen: false,
    );

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColoredBox(
          color: context.customColors.callControlSurface,
          child: SizedBox(
            height: tileHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ParticipantVideoOrAvatar(
                  participant: entry.participant,
                  session: session,
                  memberContactCards: memberContactCards,
                  isCameraEnabled: isCameraEnabled,
                  avatarRadius: 24,
                  label: presentation.showInlineLabel ? entry.label : null,
                  showVideo: presentation.showVideo,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Visibility(
                    visible: entry.participant.hasAudio == false,
                    child: const CallParticipantMuteBadge(),
                  ),
                ),
                if (presentation.showOverlayLabel)
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Text(
                      entry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.customColors.pureWhite,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipantVideoOrAvatar extends ConsumerWidget {
  const _ParticipantVideoOrAvatar({
    required this.participant,
    required this.session,
    required this.memberContactCards,
    required this.isCameraEnabled,
    required this.avatarRadius,
    required this.showVideo,
    this.label,
    this.labelStyle,
  });

  final AudioVideoCallParticipant participant;
  final AudioVideoCallSession? session;
  final Map<String, ContactCard> memberContactCards;
  final bool isCameraEnabled;
  final double avatarRadius;
  final bool showVideo;
  final String? label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final fallbackCard = resolveBestAvatarCard([
      if (participant.isSelf) identityCard,
      resolveCallParticipantContactCard(
        participant,
        memberContactCards: memberContactCards,
      ),
      contactStoreCard,
    ]);
    final fallbackImage = fallbackCard?.hasProfilePic == true
        ? fallbackCard!.image(cacheManager: ref.read(cacheManagerProvider))
        : null;
    if (showVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: ProfileCircleAvatar(
              radius: avatarRadius,
              image: fallbackImage,
              child: Icon(
                Icons.person,
                size: avatarRadius,
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
          IgnorePointer(
            child: AudioVideoCallView(
              session: session,
              participantId: participant.isSelf
                  ? participant.participantId
                  : participant.participantId,
              hasVideo: true,
              mirror: participant.isSelf,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileCircleAvatar(
            radius: avatarRadius,
            image: fallbackImage,
            child: Icon(
              Icons.person,
              size: avatarRadius,
              color: context.colorScheme.onSurface,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style:
                    labelStyle ??
                    context.textTheme.bodySmall?.copyWith(
                      color: context.customColors.pureWhite,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
