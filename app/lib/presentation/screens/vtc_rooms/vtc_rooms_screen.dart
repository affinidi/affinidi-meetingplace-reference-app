import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'vtc_room_screen.dart';

const _logKey = 'VtcRoomsScreen';

/// The community's data rooms as the member sees them: the places it
/// offers them, such as through a group's room binding, to accept, and the
/// rooms they are in. Opened from a membership card.
///
/// Only a failure's code is logged; never a room, a member or a DID.
class VtcRoomsScreen extends HookConsumerWidget {
  const VtcRoomsScreen({
    super.key,
    required this.communityDid,
    this.communityName,
  });

  final String communityDid;
  final String? communityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.read(vtcServiceProvider);
    final reload = useState(0);
    final accepting = useState<String?>(null);
    final load = useMemoized(
      () async => (
        await service.roomOffers(communityDid),
        await service.roomMemberships(communityDid),
      ),
      [reload.value],
    );
    final loaded = useFuture(load);

    Future<void> accept(RoomOffer offer) async {
      if (accepting.value != null) return;
      accepting.value = offer.roomId;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await service.acceptRoomOffer(communityDid, offer);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.vtcRoomsAccepted(offer.label))),
        );
        reload.value++;
      } on Exception catch (error) {
        messenger.showSnackBar(
          SnackBar(content: Text(vtcRoomsFailureMessage(l10n, error))),
        );
        _log(ref, 'accepting a room offer', error);
      } finally {
        if (context.mounted) accepting.value = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.vtcRoomsTitle,
          style: context.textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            key: const Key('vtc_rooms_refresh'),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.vtcJoinCheckAgain,
            onPressed: loaded.connectionState == ConnectionState.waiting
                ? null
                : () => reload.value++,
          ),
        ],
      ),
      body: switch (loaded) {
        AsyncSnapshot(hasError: true, :final error) => _Message(
          vtcRoomsFailureMessage(l10n, error),
        ),
        AsyncSnapshot(data: (final offers, final rooms)) => _Rooms(
          communityDid: communityDid,
          communityName: communityName,
          offers: offers.open.toList(),
          // An offer not accepted yet is listed with the offers, and a
          // place the member left is gone.
          rooms: [
            for (final room in rooms)
              if (room.state != RoomMemberState.offered &&
                  room.state != RoomMemberState.removed &&
                  !offers.open.any((offer) => offer.roomId == room.roomId))
                room,
          ],
          accepting: accepting.value,
          onAccept: accept,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  static void _log(WidgetRef ref, String action, Object error) {
    final code = error is MeetingPlaceVtcSDKException
        ? error.code.name
        : error.runtimeType;
    ref.read(appLoggerProvider).warning('Failed $action: $code', name: _logKey);
  }
}

/// What to tell the member when a room action fails with [error].
String vtcRoomsFailureMessage(AppLocalizations l10n, Object? error) =>
    switch (error) {
      VtaNotLinkedException() => l10n.vtcRoomsVtaMissing,
      NotACommunityMemberException() => l10n.vtcGroupsNotAMember,
      MeetingPlaceVtcSDKException(:final refusalCode?)
          when refusalCode.endsWith('actionNotHeld') =>
        l10n.vtcRoomWriteRefused,
      _ => l10n.vtcRoomsFailed,
    };

class _Rooms extends StatelessWidget {
  const _Rooms({
    required this.communityDid,
    required this.communityName,
    required this.offers,
    required this.rooms,
    required this.accepting,
    required this.onAccept,
  });

  final String communityDid;
  final String? communityName;
  final List<RoomOffer> offers;
  final List<RoomMembership> rooms;
  final String? accepting;
  final Future<void> Function(RoomOffer offer) onAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (offers.isEmpty && rooms.isEmpty) return _Message(l10n.vtcRoomsNone);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (communityName case final name?)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              name,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (offers.isNotEmpty) ...[
          _Heading(l10n.vtcRoomsOffersHeading),
          for (final offer in offers)
            _RoomCard(
              key: Key('vtc_room_offer_${offer.roomId}'),
              summary: offer,
              action: FilledButton.icon(
                key: Key('vtc_room_accept_${offer.roomId}'),
                icon: accepting == offer.roomId
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: Text(l10n.vtcRoomsAccept),
                onPressed: accepting == null ? () => onAccept(offer) : null,
              ),
            ),
        ],
        if (rooms.isNotEmpty) ...[
          _Heading(l10n.vtcRoomsMineHeading),
          for (final room in rooms)
            _RoomCard(
              key: Key('vtc_room_${room.roomId}'),
              summary: room,
              // What the room gives the member, whether or not it is open
              // to them now; [closed] says when it is not.
              readOnly:
                  room.readOnly || !room.actions.contains(RoomAction.write),
              closed: !room.canRead,
              onTap: room.canRead
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VtcRoomScreen(
                          communityDid: communityDid,
                          room: room,
                        ),
                      ),
                    )
                  : null,
            ),
        ],
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Text(text, style: context.textTheme.titleMedium),
  );
}

/// A room in a frosted box, as a group is drawn: its name, what the member
/// may do there, and who can read what is written.
class _RoomCard extends StatelessWidget {
  const _RoomCard({
    super.key,
    required this.summary,
    this.action,
    this.onTap,
    this.readOnly,
    this.closed = false,
  });

  final RoomSummary summary;
  final Widget? action;
  final VoidCallback? onTap;
  final bool? readOnly;
  final bool closed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final writes = readOnly == null ? summary.canWrite : !readOnly!;
    final muted = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary.label,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (onTap != null) const Icon(Icons.chevron_right),
                  ],
                ),
                if (summary.description case final description?)
                  Text(description, style: context.textTheme.bodyMedium),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      avatar: Icon(
                        writes
                            ? Icons.edit_outlined
                            : Icons.visibility_outlined,
                        size: 16,
                      ),
                      label: Text(
                        writes ? l10n.vtcRoomsReadWrite : l10n.vtcRoomsReadOnly,
                      ),
                    ),
                    if (closed) Chip(label: Text(l10n.vtcRoomsClosed)),
                  ],
                ),
                Text(
                  summary.visibility.isSealed
                      ? l10n.vtcRoomsSealed
                      : l10n.vtcRoomsOpenTier,
                  style: muted,
                ),
                ?action,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
