import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../domain/models/vtc/vtc_community.dart';
import '../../../domain/models/vtc/vtc_member_link.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/form_rows/form_card.dart';
import 'vtc_member_search_screen.dart';
import 'vtc_vouch.dart';

/// The contact's vouches in the communities the member picked them in, and
/// vouching for them in another. Shown for a person only, once the member
/// belongs to a community.
class VtcContactTrustPanel extends HookConsumerWidget {
  const VtcContactTrustPanel({
    super.key,
    required this.channelDid,
    required this.contactName,
  });

  /// The contact's channel DID, or null while it is not known.
  final String? channelDid;

  /// The contact's name, as the member sees it.
  final String contactName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final channelDid = this.channelDid;
    final service = ref.read(vtcTrustServiceProvider);
    final reload = useState(0);
    final load = useMemoized(
      () =>
          channelDid == null ? null : _CommunityTrust.load(service, channelDid),
      [channelDid, reload.value],
    );
    final trust = useFuture(load).data;
    if (channelDid == null || trust == null || trust.communities.isEmpty) {
      return const SizedBox.shrink();
    }

    String nameOf(VtcMemberLink link) =>
        contactName.isNotEmpty ? contactName : link.name;

    Future<void> vouch(_TrustRow row) async {
      final edge = await vouchWithConsent(
        context,
        ref,
        communityDid: row.link.communityDid,
        communityName: row.communityName,
        personaDid: row.link.personaDid,
        name: nameOf(row.link),
      );
      if (edge != null) reload.value++;
    }

    Future<void> withdraw(_TrustRow row, PublishedRelationship edge) async {
      final withdrawn = await withdrawWithConfirmation(
        context,
        ref,
        communityDid: row.link.communityDid,
        communityName: row.communityName,
        name: nameOf(row.link),
        edge: edge,
      );
      if (withdrawn) reload.value++;
    }

    Future<void> vouchInCommunity() async {
      final community = await _pickCommunity(context, trust.communities);
      if (community == null || !context.mounted) return;
      final communityName = community.name ?? community.communityDid;
      final entry = await Navigator.of(context).push<DirectoryEntry>(
        MaterialPageRoute(
          builder: (_) => VtcMemberSearchScreen(
            communityDid: community.communityDid,
            communityName: communityName,
            contactName: contactName,
          ),
        ),
      );
      if (entry == null || !context.mounted) return;
      final link = await service.link(
        channelDid: channelDid,
        communityDid: community.communityDid,
        entry: entry,
      );
      reload.value++;
      if (!context.mounted) return;
      final edge = await vouchWithConsent(
        context,
        ref,
        communityDid: community.communityDid,
        communityName: communityName,
        personaDid: link.personaDid,
        name: nameOf(link),
      );
      if (edge != null) reload.value++;
    }

    return FormCard(
      key: const Key('vtc_community_trust'),
      title: l10n.vtcTrustHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final row in trust.rows) ...[
            _TrustRowView(
              row: row,
              name: nameOf(row.link),
              onVouch: () => vouch(row),
              onWithdraw: (edge) => withdraw(row, edge),
            ),
            const Divider(),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: OutlinedButton.icon(
              key: const Key('vtc_vouch_in_community'),
              icon: const Icon(Icons.handshake_outlined),
              label: Text(l10n.vtcTrustVouchInCommunity),
              onPressed: vouchInCommunity,
            ),
          ),
        ],
      ),
    );
  }

  static Future<VtcCommunity?> _pickCommunity(
    BuildContext context,
    List<VtcCommunity> communities,
  ) async {
    if (communities.length == 1) return communities.single;
    return showDialog<VtcCommunity>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.vtcTrustPickCommunity),
        children: [
          for (final community in communities)
            SimpleDialogOption(
              key: Key('vtc_pick_${community.communityDid}'),
              onPressed: () => Navigator.of(context).pop(community),
              child: Text(community.name ?? community.communityDid),
            ),
        ],
      ),
    );
  }
}

/// One community the contact was picked in, and the vouches there.
class _TrustRowView extends StatelessWidget {
  const _TrustRowView({
    required this.row,
    required this.name,
    required this.onVouch,
    required this.onWithdraw,
  });

  final _TrustRow row;
  final String name;
  final VoidCallback onVouch;
  final void Function(PublishedRelationship edge) onWithdraw;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final edges = row.edges;
    final lines = [
      if (row.failure case final failure?)
        vtcTrustFailureMessage(
          l10n,
          failure,
          community: row.communityName,
          name: name,
        ),
      if (edges?.outgoing != null) l10n.vtcTrustYouVouched,
      if (edges?.incoming != null) l10n.vtcTrustTheyVouched(name),
      if (edges != null && edges.outgoing == null && edges.incoming == null)
        l10n.vtcTrustNoVouch,
    ];
    final outgoing = edges?.outgoing;
    return Padding(
      key: Key('vtc_trust_${row.link.communityDid}'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(row.communityName, style: context.textTheme.titleSmall),
                for (final line in lines)
                  Text(line, style: context.textTheme.bodySmall),
              ],
            ),
          ),
          if (outgoing != null)
            TextButton(
              key: const Key('vtc_trust_withdraw'),
              onPressed: () => onWithdraw(outgoing),
              child: Text(l10n.vtcTrustWithdraw),
            )
          else if (edges != null)
            FilledButton(
              key: const Key('vtc_trust_vouch'),
              onPressed: onVouch,
              child: Text(
                edges.canVouchBack
                    ? l10n.vtcTrustVouchBack
                    : l10n.vtcTrustVouch,
              ),
            ),
        ],
      ),
    );
  }
}

/// The member's communities, and the vouches with the contact in each one
/// the contact was picked in.
class _CommunityTrust {
  const _CommunityTrust(this.communities, this.rows);

  final List<VtcCommunity> communities;
  final List<_TrustRow> rows;

  static Future<_CommunityTrust> load(
    VtcTrustService service,
    String channelDid,
  ) async {
    final communities = await service.communities();
    final names = {
      for (final community in communities)
        community.communityDid: community.name ?? community.communityDid,
    };
    final rows = <_TrustRow>[];
    for (final link in await service.links(channelDid)) {
      final name = names[link.communityDid];
      if (name == null) continue;
      try {
        rows.add(
          _TrustRow(
            link,
            name,
            edges: await service.edgesWith(link.communityDid, link.personaDid),
          ),
        );
      } on VtcTrustException catch (error) {
        rows.add(_TrustRow(link, name, failure: error.failure));
      }
    }
    return _CommunityTrust(communities, rows);
  }
}

class _TrustRow {
  const _TrustRow(this.link, this.communityName, {this.edges, this.failure});

  final VtcMemberLink link;
  final String communityName;
  final VtcEdges? edges;
  final VtcTrustFailure? failure;
}
