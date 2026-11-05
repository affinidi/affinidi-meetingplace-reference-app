import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/vtc/vtc_membership_entry.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../vtc_join/vtc_trail_step.dart';
import 'membership_credentials_controller.dart';
import 'membership_credentials_list.dart';

/// A membership card's story, drawn as a trail in the member's words: the
/// community issued it, their VTA keeps it, they left — if they did — and
/// what the community's status list says of it now. Each step says who did
/// it, so the member sees where their VTA took part and where this phone
/// asked the community directly. The signed documents show in full behind
/// each step's icon.
class MembershipCredentialDetailsScreen extends ConsumerWidget {
  const MembershipCredentialDetailsScreen({super.key, required this.entryKey});

  /// The [VtcMembershipEntry.key] of the card shown.
  final String entryKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(membershipCredentialsControllerProvider);
    final entry = state.entries
        .where((entry) => entry.key == entryKey)
        .firstOrNull;
    final checking = state.checking.contains(entryKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.membershipDetailsTitle,
          style: context.textTheme.headlineMedium,
        ),
        actions: [
          if (entry != null)
            IconButton(
              key: const Key('membership_check_again'),
              icon: const Icon(Icons.refresh),
              tooltip: l10n.vtcJoinCheckAgain,
              onPressed: checking
                  ? null
                  : () => ref
                        .read(membershipCredentialsControllerProvider.notifier)
                        .check(entryKey),
            ),
        ],
      ),
      body: entry == null
          ? Center(child: Text(l10n.membershipCredentialsNone))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 24,
                children: [
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: Text(
                          entry.communityName ??
                              l10n.membershipCredentialUnnamed,
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      MembershipStatusChip(
                        status: checking ? null : state.statuses[entryKey],
                      ),
                    ],
                  ),
                  _MembershipTrail(
                    entry: entry,
                    identity: membershipIdentityName(context, ref, entry),
                    readAt: state.readAt,
                    status: checking ? null : state.statuses[entryKey],
                  ),
                ],
              ),
            ),
    );
  }
}

class _MembershipTrail extends StatelessWidget {
  const _MembershipTrail({
    required this.entry,
    required this.identity,
    required this.readAt,
    required this.status,
  });

  final VtcMembershipEntry entry;
  final String identity;
  final DateTime? readAt;

  /// What the community says of the card; null while it is being asked.
  final VtcCardStatus? status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    String time(DateTime at) =>
        DateFormat.yMMMd(locale).add_Hm().format(at.toLocal());
    String date(DateTime at) => DateFormat.yMMMd(locale).format(at.toLocal());
    final card = entry.card;
    final community = entry.communityName ?? l10n.membershipCredentialUnnamed;
    final left = entry.left;
    final leave = left?.leaveExchange;
    final receipt = leave?.receipt;
    final status = this.status;
    final lastKnown = status?.lastKnown;
    final statusList = status?.statusList ?? lastKnown?.statusList;
    final names = [identity, community];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VtcTrailStep(
          key: const Key('membership_trail_issued'),
          icon: Icons.card_membership_outlined,
          stage: VtcTrailStage.done,
          title: l10n.membershipTrailIssued(community),
          summary: switch (card.validFrom) {
            final from? => l10n.membershipTrailIssuedSummary(
              identity,
              community,
              date(from),
            ),
            null => l10n.membershipTrailIssuedSummaryUndated(
              identity,
              community,
            ),
          },
          highlights: names,
          actor: community,
          details: [
            VtcTrailDetail(
              Icons.groups_outlined,
              l10n.vtcJoinTrailIssuer,
              card.issuer,
              isId: true,
            ),
            VtcTrailDetail(
              Icons.fingerprint,
              l10n.membershipTrailMember,
              card.memberDid,
              isId: true,
            ),
            if (card.validFrom case final from?)
              VtcTrailDetail(
                Icons.event_outlined,
                l10n.membershipTrailValidFrom,
                time(from),
              ),
            if (card.validUntil case final until?)
              VtcTrailDetail(
                Icons.event_outlined,
                l10n.vtcJoinTrailValidUntil,
                time(until),
              ),
          ],
          document: card.credential,
          documentTitle: l10n.membershipTrailCardDocument,
          documentKey: const Key('membership_trail_card_document'),
        ),
        VtcTrailStep(
          key: const Key('membership_trail_kept'),
          icon: Icons.draw_outlined,
          stage: VtcTrailStage.done,
          title: l10n.membershipTrailKept,
          summary: switch ((left, readAt)) {
            (_?, _) => l10n.membershipTrailPutAway,
            (null, final at?) => l10n.membershipTrailKeptSummary(
              identity,
              time(at),
            ),
            (null, null) => l10n.membershipTrailKept,
          },
          highlights: names,
          actor: l10n.membershipTrailYourVta,
          details: [
            if (entry.stored case final stored?) ...[
              VtcTrailDetail(
                Icons.inventory_2_outlined,
                l10n.membershipTrailStoredId,
                stored.id,
                isId: true,
              ),
              if (stored.purpose case final purpose?)
                VtcTrailDetail(
                  Icons.folder_outlined,
                  l10n.membershipTrailStoredPurpose,
                  purpose,
                ),
              if (stored.status case final status?)
                VtcTrailDetail(
                  Icons.verified_outlined,
                  l10n.membershipTrailStoredStatus,
                  status,
                ),
              if (stored.types.isNotEmpty)
                VtcTrailDetail(
                  Icons.category_outlined,
                  l10n.membershipTrailStoredTypes,
                  stored.types.join(', '),
                ),
            ],
          ],
        ),
        if (left != null)
          VtcTrailStep(
            key: const Key('membership_trail_left'),
            icon: Icons.draw_outlined,
            stage: VtcTrailStage.done,
            title: l10n.membershipTrailLeft(community),
            summary: leave == null
                ? l10n.membershipTrailLeftNoReceipt(community)
                : l10n.membershipTrailLeftSummary(
                    community,
                    _keeps(l10n, leave.answer.payload['disposition']),
                  ),
            highlights: names,
            actor: leave == null
                ? community
                : l10n.membershipTrailLeftActor(community),
            details: [
              if (receipt != null) ...[
                if (receipt.signedAt case final at?)
                  VtcTrailDetail(
                    Icons.schedule,
                    l10n.vtcJoinTrailSignedAt,
                    time(at),
                  ),
                VtcTrailDetail(
                  Icons.groups_outlined,
                  l10n.vtcJoinTrailAnsweredBy,
                  receipt.answeredBy,
                  isId: true,
                ),
                if (receipt.answeredAt case final at?)
                  VtcTrailDetail(
                    Icons.schedule,
                    l10n.vtcJoinTrailAnsweredAt,
                    time(at),
                  ),
                VtcTrailDetail(
                  Icons.assignment_outlined,
                  l10n.vtcJoinTrailTask,
                  receipt.type,
                ),
              ],
            ],
            document: leave?.toJson(),
            documentTitle: l10n.membershipTrailLeftDocument,
            documentKey: const Key('membership_trail_left_document'),
          ),
        VtcTrailStep(
          key: const Key('membership_trail_checked'),
          icon: Icons.fact_check_outlined,
          stage: switch (status?.state) {
            null => VtcTrailStage.current,
            VtcCardState.unknown => VtcTrailStage.failed,
            _ => VtcTrailStage.done,
          },
          busy: status == null,
          title: l10n.membershipTrailChecked(community),
          summary: _checkSummary(
            l10n,
            community,
            status,
            time,
            date,
            validUntil: card.validUntil,
          ),
          highlights: names,
          actor: l10n.membershipTrailThisPhone,
          details: [
            if (status?.statusListUrl case final url?)
              VtcTrailDetail(
                Icons.link,
                l10n.membershipTrailStatusList,
                url.toString(),
                isId: true,
              ),
            if (status?.index case final index?)
              VtcTrailDetail(
                Icons.tag,
                l10n.membershipTrailStatusIndex,
                '$index',
              ),
            if (status?.checkedAt ?? lastKnown?.checkedAt case final at?)
              VtcTrailDetail(
                Icons.schedule,
                l10n.membershipTrailCheckedAt,
                time(at),
              ),
          ],
          document: statusList,
          documentTitle: l10n.membershipTrailStatusDocument(community),
          documentKey: const Key('membership_trail_status_document'),
          isLast: true,
        ),
      ],
    );
  }

  static String _keeps(AppLocalizations l10n, Object? disposition) =>
      switch (disposition) {
        'purge' => l10n.membershipTrailKeepsNothing,
        'tombstone' => l10n.membershipTrailKeepsNote,
        'historical' => l10n.membershipTrailKeepsHistory,
        _ => l10n.membershipTrailKeepsUnknown,
      };

  static String _checkSummary(
    AppLocalizations l10n,
    String community,
    VtcCardStatus? status,
    String Function(DateTime) time,
    String Function(DateTime) date, {
    required DateTime? validUntil,
  }) {
    final direct = l10n.membershipTrailCheckDirect(community);
    return switch (status) {
      null => l10n.membershipTrailChecking(community),
      VtcCardStatus(state: VtcCardState.expired) when validUntil != null =>
        l10n.membershipTrailExpired(date(validUntil)),
      VtcCardStatus(state: VtcCardState.notRevocable) =>
        l10n.membershipTrailNotRevocable(community),
      VtcCardStatus(state: VtcCardState.revoked, :final checkedAt?) =>
        '$direct · ${l10n.membershipTrailRevoked(community, time(checkedAt))}',
      VtcCardStatus(state: VtcCardState.valid, :final checkedAt?) =>
        '$direct · ${l10n.membershipTrailValid(time(checkedAt))}',
      VtcCardStatus(:final lastKnown?) => [
        direct,
        l10n.membershipTrailUnreachable(community),
        if (lastKnown.revoked)
          l10n.membershipTrailLastRevoked(time(lastKnown.checkedAt))
        else
          l10n.membershipTrailLastValid(time(lastKnown.checkedAt)),
      ].join(' · '),
      _ => '$direct · ${l10n.membershipTrailUnreachable(community)}',
    };
  }
}
