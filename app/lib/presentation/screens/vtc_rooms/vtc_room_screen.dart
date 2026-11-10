import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/vtc_exception_extensions.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_spacing.dart';
import 'vtc_rooms_view.dart';

const _logKey = 'VtcRoomScreen';

/// Most records opened at once. A room with more shows the newest.
const _maxOpened = 50;

/// One room's records, each opened by the member's VTA and checked against
/// its author's signature, newest first; and, for a member who may write
/// there, a way to add one.
///
/// Records are other members' text: shown as plain text, never as markup.
/// Only a failure's code is logged; never a room, a record or a DID.
class VtcRoomScreen extends HookConsumerWidget {
  const VtcRoomScreen({
    super.key,
    required this.communityDid,
    required this.room,
  });

  final String communityDid;
  final RoomMembership room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.read(vtcServiceProvider);
    final reload = useState(0);
    final me = useMemoized(() => service.roomMemberDid(communityDid));
    final myDid = useFuture(me).data;
    // Records the member wrote here, shown at once: reading the room back
    // through the VTA takes a while.
    final posted = useState(const <_Opened>[]);
    // The title and text being written, shown until the room has it.
    final posting = useState<(String, String?)?>(null);
    final load = useMemoized(() async {
      final listing = await service.roomRecords(communityDid, room);
      final newest = [
        for (final summary in listing.records)
          if (summary.status != RoomRecordStatus.retracted) summary,
      ]..sort((a, b) => b.version.compareTo(a.version));
      // Opened side by side: each is its own round trip to the VTA.
      final opened = await Future.wait(
        newest.take(_maxOpened).map<Future<_Opened?>>((summary) async {
          try {
            final record = await service.roomRecord(
              communityDid,
              room,
              key: summary.key,
            );
            // The room's own profile is not a member's record.
            return record == null ? null : (summary, record);
          } on MeetingPlaceVtcSDKException catch (error) {
            _log(ref, 'opening a record', error.logCode);
            return (summary, null);
          }
        }),
      );
      return opened.nonNulls.toList();
    }, [reload.value]);
    final loaded = useFuture(load);

    Future<void> write() async {
      final draft = await showDialog<(String, String)>(
        context: context,
        builder: (_) => const _WriteDialog(),
      );
      if (draft == null || !context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final (title, text) = draft;
      final body = text.isEmpty ? null : text;
      posting.value = (title, body);
      try {
        final written = await service.writeRoomRecord(
          communityDid,
          room,
          title: title,
          body: body,
        );
        messenger.showSnackBar(SnackBar(content: Text(l10n.vtcRoomWritten)));
        // The member left the room while it was written.
        if (!context.mounted) return;
        final now = DateTime.now().toUtc();
        posted.value = [
          (
            RoomRecordSummary(
              key: written.key,
              version: written.version,
              status: RoomRecordStatus.active,
              updatedAt: now,
            ),
            RoomRecord(
              roomId: room.roomId,
              key: written.key,
              version: written.version,
              status: RoomRecordStatus.active,
              author: myDid,
              updatedAt: now,
              title: title,
              body: body,
            ),
          ),
          ...posted.value,
        ];
        reload.value++;
      } on Exception catch (error) {
        messenger.showSnackBar(
          SnackBar(content: Text(vtcRoomsFailureMessage(l10n, error))),
        );
        _log(
          ref,
          'writing a record',
          error is MeetingPlaceVtcSDKException
              ? error.logCode
              : error.runtimeType,
        );
      } finally {
        if (context.mounted) posting.value = null;
      }
    }

    final refreshing = loaded.connectionState == ConnectionState.waiting;
    // What the room read back, and what the member wrote that it does not
    // show yet, newest first.
    final records = switch (loaded.data) {
      final read? => [
        ...posted.value.where(
          (mine) => !read.any((other) => other.$1.key == mine.$1.key),
        ),
        ...read,
      ]..sort((a, b) => b.$1.version.compareTo(a.$1.version)),
      null => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(room.label),
        actions: [
          IconButton(
            key: const Key('vtc_room_refresh'),
            icon: const Icon(McIcons.refresh),
            tooltip: l10n.vtcJoinCheckAgain,
            onPressed: refreshing ? null : () => reload.value++,
          ),
        ],
        bottom: refreshing && records != null
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(
                  key: Key('vtc_room_refreshing'),
                  minHeight: 2,
                ),
              )
            : null,
      ),
      floatingActionButton: room.canWrite
          ? FloatingActionButton.extended(
              key: const Key('vtc_room_write'),
              icon: posting.value != null
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(McIcons.edit),
              label: Text(
                posting.value != null ? l10n.vtcRoomPosting : l10n.vtcRoomWrite,
              ),
              onPressed: posting.value != null ? null : write,
            )
          : null,
      body: switch ((loaded, records)) {
        (AsyncSnapshot(hasError: true, :final error), _) => _Message(
          vtcRoomsFailureMessage(l10n, error),
        ),
        (_, final records?) when records.isEmpty && posting.value == null =>
          _Message(
            room.canWrite
                ? l10n.vtcRoomRecordsNoneWriter
                : l10n.vtcRoomRecordsNone,
          ),
        (_, final records?) => _Separated([
          if (!room.canWrite)
            Text(
              l10n.vtcRoomReadOnlyNote,
              key: const Key('vtc_room_read_only'),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          if (posting.value case (final title, final body))
            _PostingCard(title: title, body: body),
          for (final (summary, record) in records)
            _RecordCard(summary: summary, record: record, myDid: myDid),
        ]),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  static void _log(WidgetRef ref, String action, Object code) => ref
      .read(appLoggerProvider)
      .warning('Failed $action: $code', name: _logKey);
}

/// A record as the room lists it, and opened; null when it could not be.
typedef _Opened = (RoomRecordSummary, RoomRecord?);

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.summary,
    required this.record,
    required this.myDid,
  });

  final RoomRecordSummary summary;

  /// The DID the member writes as, once known.
  final String? myDid;

  /// The record opened and checked; null when it could not be.
  final RoomRecord? record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = context.textTheme.bodySmall?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );
    final record = this.record;
    final updatedAt = record?.updatedAt ?? summary.updatedAt;
    return _Card(
      key: Key('vtc_room_record_${summary.key}'),
      children: [
        if (record == null)
          Text(l10n.vtcRoomRecordUnopened, style: muted)
        else ...[
          Text(
            record.title ?? l10n.vtcRoomRecordUntitled,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (record.body case final body?)
            Text(body, style: context.textTheme.bodyMedium),
          if (record.status == RoomRecordStatus.deprecated)
            Text(l10n.vtcRoomRecordOutdated, style: muted),
        ],
        Text(
          [
            // Only once opened: the author is then the one who signed.
            if (record?.author case final author?)
              author == myDid
                  ? l10n.vtcRoomRecordByYou
                  : l10n.vtcRoomRecordByMember,
            DateFormat.yMMMd(
              l10n.localeName,
            ).add_jm().format(updatedAt.toLocal()),
          ].join(' · '),
          style: muted,
        ),
      ],
    );
  }
}

/// Asks for a new record's title and text; pops `(title, text)`, or null
/// when dismissed.
class _WriteDialog extends HookWidget {
  const _WriteDialog();

  static const _maxTitle = 200;
  static const _maxBody = 10000;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = useTextEditingController();
    final body = useTextEditingController();
    useListenable(title);
    final ready = title.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(l10n.vtcRoomWriteTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            TextField(
              key: const Key('vtc_room_write_title'),
              controller: title,
              autofocus: true,
              maxLength: _maxTitle,
              decoration: InputDecoration(
                labelText: l10n.vtcRoomWriteTitleLabel,
              ),
            ),
            TextField(
              key: const Key('vtc_room_write_body'),
              controller: body,
              minLines: 3,
              maxLines: 8,
              maxLength: _maxBody,
              decoration: InputDecoration(
                labelText: l10n.vtcRoomWriteBodyLabel,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.vtcRoomWriteCancel),
        ),
        FilledButton(
          key: const Key('vtc_room_write_send'),
          onPressed: ready
              ? () => Navigator.of(
                  context,
                ).pop((title.text.trim(), body.text.trim()))
              : null,
          child: Text(l10n.vtcRoomWriteSend),
        ),
      ],
    );
  }
}

/// The draft being written, shown at the top of the room until the room
/// has it.
class _PostingCard extends StatelessWidget {
  const _PostingCard({required this.title, required this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) => _Card(
    key: const Key('vtc_room_posting'),
    children: [
      Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      if (body case final body?)
        Text(body, style: context.textTheme.bodyMedium),
      Row(
        spacing: 8,
        children: [
          const SizedBox.square(
            dimension: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          Text(
            context.l10n.vtcRoomPosting,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ],
  );
}

/// A record's card in the room.
class _Card extends StatelessWidget {
  const _Card({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    // The hairline border takes its width from the padding, so the
    // content keeps its size.
    padding: const EdgeInsets.all(16 - McSpacing.hairline),
    decoration: BoxDecoration(
      color: context.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(McRadius.lg),
      border: Border.all(color: context.mcColors.hairline),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: children,
    ),
  );
}

/// The room's lines, a gap between each.
class _Separated extends StatelessWidget {
  const _Separated(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
    itemCount: children.length,
    separatorBuilder: (_, _) => const SizedBox(height: 16),
    itemBuilder: (_, index) => children[index],
  );
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
