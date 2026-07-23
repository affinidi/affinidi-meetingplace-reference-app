import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../../../domain/models/contact_card/contact_card.dart';
import '../../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../../infrastructure/providers/cache_manager_provider.dart';
import '../audio_video_call_screen_controller.dart';
import '../rules/call_participant_identity_rules.dart';
import 'call_participant.dart';
import 'call_participant_list_sheet.dart';
import 'call_participants_ring_controller.dart';

/// Live, data-bound participant list for a group call.
///
/// Watches the shared call state so members move between the Connected and
/// Not connected sections in real time while the sheet is open, and drives the
/// per-member re-ring state via [CallParticipantsRingController].
class CallParticipantsSheet extends ConsumerWidget {
  const CallParticipantsSheet({super.key, required this.contactId});

  final String contactId;

  static Future<void> show(BuildContext context, {required String contactId}) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CallParticipantsSheet(contactId: contactId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = audioVideoCallScreenControllerProvider(contactId);
    final roster = ref.watch(provider.select((s) => s.memberContactCards));
    final connected = ref.watch(provider.select((s) => s.participants));
    final ownDid = ref.watch(provider.select((s) => s.ownDid));
    final ringStates = ref.watch(
      callParticipantsRingControllerProvider(contactId),
    );
    final cacheManager = ref.read(cacheManagerProvider);
    final ringController = ref.read(
      callParticipantsRingControllerProvider(contactId).notifier,
    );

    final participants = buildCallParticipants(
      roster: roster,
      connected: connected,
      ringStates: ringStates,
      avatarOf: (card) => card.image(cacheManager: cacheManager),
      ownDid: ownDid,
    );

    return CallParticipantListSheet(
      participants: participants,
      onCall: ringController.ring,
      onRingingTap: ringController.cancelRing,
    );
  }
}

/// Derives the presentational participant list from group-call state.
///
/// Every roster member is listed except the local user ([ownDid]), which is
/// never shown or rung. A member is Connected when their DID is present among
/// the call [connected] participants; otherwise Not connected, carrying its
/// current entry from [ringStates]. [avatarOf] resolves each member's avatar
/// image.
List<CallParticipant> buildCallParticipants({
  required Map<String, ContactCard> roster,
  required List<AudioVideoCallParticipant> connected,
  required Map<String, CallRingState> ringStates,
  required ImageProvider<Object> Function(ContactCard) avatarOf,
  String? ownDid,
}) {
  final connectedDids = connected
      .map(
        (participant) =>
            resolveCallParticipantDid(participant, memberContactCards: roster),
      )
      .whereType<String>()
      .toSet();

  return [
    for (final entry in roster.entries)
      if (entry.key != ownDid)
        if (connectedDids.contains(entry.key))
          CallParticipant(
            id: entry.key,
            firstName: entry.value.firstName,
            avatar: avatarOf(entry.value),
            connection: CallParticipantConnection.connected,
          )
        else
          CallParticipant(
            id: entry.key,
            firstName: entry.value.firstName,
            avatar: avatarOf(entry.value),
            connection: CallParticipantConnection.notConnected,
            ringState: ringStates[entry.key] ?? CallRingState.idle,
          ),
  ];
}
