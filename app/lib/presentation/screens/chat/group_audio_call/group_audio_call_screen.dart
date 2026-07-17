import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import 'group_audio_call_controller.dart';
import 'group_audio_call_participant_tile.dart';
import 'group_audio_call_state.dart';

/// Group audio call screen.
///
/// Displays participants in a layout that adapts based on count:
/// - Single participant: full-screen tile
/// - 2+ participants: grid of tiles
/// - Ringing: group icon with "Waiting for others..." status
///
/// Includes real-time sync of participant events and mute status.
class GroupAudioCallScreen extends ConsumerWidget {
  const GroupAudioCallScreen({super.key, required this.groupContactId});

  final String groupContactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupAudioCallControllerProvider(groupContactId));
    final controller = ref.read(
      groupAudioCallControllerProvider(groupContactId).notifier,
    );

    return Scaffold(
      backgroundColor: context.customColors.darkGrey,
      body: SafeArea(
        child: state.isRinging
            ? _RingingStateView(state: state, controller: controller)
            : _ActiveCallStateView(state: state, controller: controller),
      ),
    );
  }
}

class _RingingStateView extends StatelessWidget {
  const _RingingStateView({required this.state, required this.controller});

  final GroupAudioCallState state;
  final GroupAudioCallController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;
    final textTheme = context.textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _GroupCallAvatar(),
          const SizedBox(height: 24),
          Text(
            context.l10n.groupCallWaitingForOthers,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(color: colors.pureWhite),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final countLabel = state.participantCount == 1
                  ? context.l10n.groupCallParticipant
                  : context.l10n.groupCallParticipants;
              return Text(
                '${state.participantCount} $countLabel',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colors.pureWhite),
              );
            },
          ),
          const SizedBox(height: 48),
          ElevatedButton.icon(
            onPressed: controller.leaveCall,
            icon: const Icon(Icons.close),
            label: Text(context.l10n.groupCallEndCall),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.rose,
              foregroundColor: colors.pureWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCallAvatar extends StatelessWidget {
  const _GroupCallAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.grey700),
      child: Icon(Icons.group, size: 60, color: colors.cyan),
    );
  }
}

class _ActiveCallStateView extends StatelessWidget {
  const _ActiveCallStateView({required this.state, required this.controller});

  final GroupAudioCallState state;
  final GroupAudioCallController controller;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.customColors.darkGrey,
      child: Column(
        children: [
          Expanded(
            child: state.participantCount == 1
                ? _SingleParticipantView(state: state)
                : _ParticipantGridView(state: state),
          ),
          _ControlsBar(controller: controller),
        ],
      ),
    );
  }
}

class _SingleParticipantView extends StatelessWidget {
  const _SingleParticipantView({required this.state});

  final GroupAudioCallState state;

  @override
  Widget build(BuildContext context) {
    final participant = state.participants.isNotEmpty
        ? state.participants.first
        : null;

    if (participant == null) {
      return Center(
        child: Text(
          context.l10n.groupCallNoParticipants,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.customColors.pureWhite,
          ),
        ),
      );
    }

    return Center(
      child: GroupAudioCallParticipantTile(
        displayName: participant.displayName,
        isMuted: participant.isMuted,
        isSelf: participant.isSelf,
        size: 200,
      ),
    );
  }
}

class _ParticipantGridView extends StatelessWidget {
  const _ParticipantGridView({required this.state});

  final GroupAudioCallState state;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = state.participantCount <= 4 ? 2 : 3;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: state.participantCount,
        itemBuilder: (context, index) {
          final participant = state.participants[index];
          return GroupAudioCallParticipantTile(
            displayName: participant.displayName,
            isMuted: participant.isMuted,
            isSelf: participant.isSelf,
            size: 120,
          );
        },
      ),
    );
  }
}

class _ControlsBar extends StatelessWidget {
  const _ControlsBar({required this.controller});

  final GroupAudioCallController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.customColors;

    return ColoredBox(
      color: colors.callControlSurface.withValues(alpha: 0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              onPressed: controller.toggleMic,
              backgroundColor: colors.cyan,
              icon: Icon(Icons.mic, color: colors.pureWhite),
              label: Text(
                context.l10n.groupCallMute,
                style: TextStyle(color: colors.pureWhite),
              ),
            ),
            FloatingActionButton.extended(
              onPressed: controller.leaveCall,
              backgroundColor: colors.rose,
              icon: Icon(Icons.call_end, color: colors.pureWhite),
              label: Text(
                context.l10n.groupCallLeave,
                style: TextStyle(color: colors.pureWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
