import 'package:flutter/material.dart';

import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../infrastructure/extensions/build_context_extensions.dart';

/// Reusable participant tile for group audio calls.
///
/// Displays a circular profile picture with an optional mute icon overlay.
/// Supports single participant (full-screen) or grid layout (2+).
class GroupAudioCallParticipantTile extends StatelessWidget {
  const GroupAudioCallParticipantTile({
    super.key,
    required this.displayName,
    required this.isMuted,
    required this.isSelf,
    this.contactCard,
    this.size = 120,
  });

  /// Display name for the participant.
  final String displayName;

  /// Whether the participant's mic is muted.
  final bool isMuted;

  /// Whether this is the local user.
  final bool isSelf;

  /// Optional contact card for avatar reference.
  final ContactCard? contactCard;

  /// Size of the tile in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ParticipantProfileTile(size: size, isMuted: isMuted, isSelf: isSelf),
        if (displayName.isNotEmpty) ...[
          const SizedBox(height: 8),
          _ParticipantDisplayName(displayName: displayName),
        ],
      ],
    );
  }
}

class _ParticipantProfileTile extends StatelessWidget {
  const _ParticipantProfileTile({
    required this.size,
    required this.isMuted,
    required this.isSelf,
  });

  final double size;
  final bool isMuted;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.customColors.grey700,
          ),
          child: _DefaultProfileIcon(size: size),
        ),
        if (isMuted)
          Positioned(
            top: size * 0.08,
            left: size * 0.08,
            child: _MutedIndicator(size: size),
          ),
        if (isSelf) const Positioned(top: 0, right: 0, child: _SelfIndicator()),
      ],
    );
  }
}

class _MutedIndicator extends StatelessWidget {
  const _MutedIndicator({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.24,
      height: size * 0.24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.customColors.rose,
      ),
      child: Icon(
        Icons.mic_off,
        color: context.customColors.pureWhite,
        size: size * 0.12,
      ),
    );
  }
}

class _SelfIndicator extends StatelessWidget {
  const _SelfIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: context.customColors.cyan,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        context.l10n.you,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.customColors.darkGrey,
        ),
      ),
    );
  }
}

class _ParticipantDisplayName extends StatelessWidget {
  const _ParticipantDisplayName({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Text(
      displayName,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.bodySmall?.copyWith(
        color: context.customColors.pureWhite,
      ),
    );
  }
}

class _DefaultProfileIcon extends StatelessWidget {
  const _DefaultProfileIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: context.customColors.whiteOverlay30,
      ),
    );
  }
}
