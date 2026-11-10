import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'vtc_rooms_screen.dart';

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
    final load = useMemoized(() async {
      final listing = await service.roomRecords(communityDid, room);
      final newest = [...listing.records]
        ..sort((a, b) => b.version.compareTo(a.version));
      final opened = <(RoomRecordSummary, RoomRecord?)>[];
      for (final summary in newest.take(_maxOpened)) {
        if (summary.status == RoomRecordStatus.retracted) continue;
        try {
          final record = await service.roomRecord(
            communityDid,
            room,
            key: summary.key,
          );
          // The room's own profile is not a member's record.
          if (record == null) continue;
          opened.add((summary, record));
        } on MeetingPlaceVtcSDKException catch (error) {
          _log(ref, 'opening a record', error.code.name);
          opened.add((summary, null));
        }
      }
      return opened;
    }, [reload.value]);
    final loaded = useFuture(load);

    Future<void> write() async {
      final draft = await showDialog<(String, String)>(
        context: context,
        builder: (_) => const _WriteDialog(),
      );
      if (draft == null || !context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await service.writeRoomRecord(
          communityDid,
          room,
          title: draft.$1,
          body: draft.$2.isEmpty ? null : draft.$2,
        );
        messenger.showSnackBar(SnackBar(content: Text(l10n.vtcRoomWritten)));
        reload.value++;
      } on Exception catch (error) {
        messenger.showSnackBar(
          SnackBar(content: Text(vtcRoomsFailureMessage(l10n, error))),
        );
        _log(
          ref,
          'writing a record',
          error is MeetingPlaceVtcSDKException
              ? error.code.name
              : error.runtimeType,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(room.label),
        actions: [
          IconButton(
            key: const Key('vtc_room_refresh'),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.vtcJoinCheckAgain,
            onPressed: loaded.connectionState == ConnectionState.waiting
                ? null
                : () => reload.value++,
          ),
        ],
      ),
      floatingActionButton: room.canWrite
          ? FloatingActionButton.extended(
              key: const Key('vtc_room_write'),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.vtcRoomWrite),
              onPressed: write,
            )
          : null,
      body: switch (loaded) {
        AsyncSnapshot(hasError: true, :final error) => _Message(
          vtcRoomsFailureMessage(l10n, error),
        ),
        AsyncSnapshot(data: final records?) when records.isEmpty => _Message(
          room.canWrite
              ? l10n.vtcRoomRecordsNoneWriter
              : l10n.vtcRoomRecordsNone,
        ),
        AsyncSnapshot(data: final records?) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: records.length + (room.canWrite ? 0 : 1),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (!room.canWrite && index == 0) {
              return Text(
                l10n.vtcRoomReadOnlyNote,
                key: const Key('vtc_room_read_only'),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              );
            }
            final (summary, record) = records[index - (room.canWrite ? 0 : 1)];
            return _RecordCard(summary: summary, record: record, myDid: myDid);
          },
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  static void _log(WidgetRef ref, String action, Object code) => ref
      .read(appLoggerProvider)
      .warning('Failed $action: $code', name: _logKey);
}

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
    return Container(
      key: Key('vtc_room_record_${summary.key}'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          if (record == null)
            Text(l10n.vtcRoomRecordUnopened, style: muted)
          else ...[
            Text(
              record.title ?? l10n.vtcRoomRecordUntitled,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
      ),
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
