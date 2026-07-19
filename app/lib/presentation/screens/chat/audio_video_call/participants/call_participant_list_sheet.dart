import 'package:flutter/material.dart';

import '../../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../widgets/bottom_sheet_menu.dart';
import '../../../../widgets/profile_circle_avatar.dart';
import 'call_participant.dart';

class CallParticipantListSheet extends StatelessWidget {
  const CallParticipantListSheet({
    super.key,
    required this.participants,
    required this.onCall,
    required this.onRingingTap,
  });

  final List<CallParticipant> participants;

  /// Called when the bell icon is tapped for an idle or timed-out participant.
  final void Function(String participantId) onCall;

  /// Called when the triple-dot icon is tapped for a ringing participant.
  final void Function(String participantId) onRingingTap;

  static Future<void> show(
    BuildContext context, {
    required List<CallParticipant> participants,
    required void Function(String) onCall,
    required void Function(String) onRingingTap,
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CallParticipantListSheet(
        participants: participants,
        onCall: onCall,
        onRingingTap: onRingingTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connected = participants
        .where((p) => p.connection == CallParticipantConnection.connected)
        .toList();
    final notConnected = participants
        .where((p) => p.connection == CallParticipantConnection.notConnected)
        .toList();

    final l10n = context.l10n;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: ColoredBox(
        color: context.customColors.callControlSurface,
        child: BottomSheetMenu(
          showHandle: true,
          itemCount: 1,
          itemBuilder: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    l10n.callParticipantsConnectedCount(connected.length),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _section(
                  context,
                  label: l10n.callParticipantsConnectedSection,
                  participants: connected,
                ),
                const SizedBox(height: 20),
                _section(
                  context,
                  label: l10n.callParticipantsNotConnectedSection,
                  participants: notConnected,
                ),
                SizedBox(height: bottomPadding + 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String label,
    required List<CallParticipant> participants,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        for (final participant in participants)
          _ParticipantRow(
            participant: participant,
            onCall: onCall,
            onRingingTap: onRingingTap,
          ),
      ],
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.participant,
    required this.onCall,
    required this.onRingingTap,
  });

  final CallParticipant participant;
  final void Function(String participantId) onCall;
  final void Function(String participantId) onRingingTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = context.colorScheme.onSurface;
    final p = participant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.customColors.callBubbleGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ProfileCircleAvatar(
            radius: 20,
            image: p.avatar,
            child: p.avatar == null
                ? Icon(Icons.person, color: onSurface)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              p.firstName,
              style: context.textTheme.titleMedium?.copyWith(color: onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildTrailing(context, onSurface),
        ],
      ),
    );
  }

  /// Trailing action for a not-connected participant: the triple-dot while
  /// ringing, otherwise the bell (idle or timed-out, so the user can re-ring).
  /// Connected participants have no trailing action.
  Widget _buildTrailing(BuildContext context, Color color) {
    if (participant.connection != CallParticipantConnection.notConnected) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final isRinging = participant.ringState == CallRingState.ringing;

    return Semantics(
      button: true,
      label: isRinging
          ? l10n.callParticipantRingingAction(participant.firstName)
          : l10n.callParticipantCallAction(participant.firstName),
      child: IconButton(
        icon: Icon(
          isRinging ? Icons.more_horiz : Icons.notifications,
          color: color,
        ),
        onPressed: () =>
            isRinging ? onRingingTap(participant.id) : onCall(participant.id),
      ),
    );
  }
}
