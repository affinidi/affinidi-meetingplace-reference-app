import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_room_screen.dart';

const _logKey = 'VtcRoomsView';

/// The community's data rooms as the member sees them: the places it
/// offers them, such as through a group's room binding, to accept, and the
/// rooms they are in. The Rooms tab of a community's page; pulled down, it
/// reads them again.
///
/// Only a failure's code is logged; never a room, a member or a DID.
class VtcRoomsView extends HookConsumerWidget {
  const VtcRoomsView({super.key, required this.communityDid});

  final String communityDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.read(vtcServiceProvider);
    Future<(RoomOffers, List<RoomMembership>)> read() async => (
      await service.roomOffers(communityDid),
      await service.roomMemberships(communityDid),
    );
    final load = useState(useMemoized(read));
    final loaded = useFuture(load.value);
    final accepting = useState<String?>(null);

    Future<void> refresh() async {
      load.value = read();
      try {
        await load.value;
      } on Object {
        // The tab says why in place of the rooms.
      }
    }

    Future<void> accept(RoomOffer offer) async {
      if (accepting.value != null) return;
      accepting.value = offer.roomId;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await service.acceptRoomOffer(communityDid, offer);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.vtcRoomsAccepted(offer.label))),
        );
        load.value = read();
      } on Exception catch (error) {
        messenger.showSnackBar(
          SnackBar(content: Text(vtcRoomsFailureMessage(l10n, error))),
        );
        _log(ref, 'accepting a room offer', error);
      } finally {
        if (context.mounted) accepting.value = null;
      }
    }

    if (!loaded.hasData && !loaded.hasError) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: refresh,
      child: switch (loaded) {
        AsyncSnapshot(hasError: true, :final error) => _Message(
          vtcRoomsFailureMessage(l10n, error),
        ),
        AsyncSnapshot(data: (final offers, final rooms)) => _Rooms(
          communityDid: communityDid,
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
        _ => const SizedBox.shrink(),
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
    required this.offers,
    required this.rooms,
    required this.accepting,
    required this.onAccept,
  });

  final String communityDid;
  final List<RoomOffer> offers;
  final List<RoomMembership> rooms;
  final String? accepting;
  final Future<void> Function(RoomOffer offer) onAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (offers.isEmpty && rooms.isEmpty) return _Message(l10n.vtcRoomsNone);
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
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
                      : const Icon(McIcons.login),
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
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textTheme.titleMedium?.copyWith(
      color: context.mcColors.textPrimary,
    ),
  );
}

/// A room in a box, as a group is drawn: its name, what the member may do
/// there, and who can read what is written.
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

  static const _radius = BorderRadius.all(Radius.circular(McRadius.lg));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final writes = readOnly == null ? summary.canWrite : !readOnly!;
    final sealed = summary.visibility.isSealed;
    return Material(
      color: context.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: _radius,
        side: BorderSide(color: context.mcColors.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      summary.label,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      McIcons.chevronRight,
                      color: context.mcColors.textSecondary,
                    ),
                ],
              ),
              if (summary.description case final description?)
                Text(
                  description,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              OnboardingLine(
                icon: writes ? McIcons.edit : McIcons.visible,
                title: writes ? l10n.vtcRoomsReadWrite : l10n.vtcRoomsReadOnly,
                subtitle: closed ? l10n.vtcRoomsClosed : null,
              ),
              OnboardingLine(
                icon: sealed ? McIcons.lock : McIcons.public,
                title: sealed ? l10n.vtcRoomsSealed : l10n.vtcRoomsOpenTier,
              ),
              ?action,
            ],
          ),
        ),
      ),
    );
  }
}

/// A message in place of the rooms, such as why they can't be shown;
/// scrollable, so pulling it down reads them again.
class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(text, textAlign: TextAlign.center),
          ),
        ),
      ),
    ],
  );
}
