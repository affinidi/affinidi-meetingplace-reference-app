import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../vtc_join/vtc_findable_view.dart';
import '../vtc_trust/vtc_member_tile.dart';
import '../vtc_trust/vtc_vouch.dart';
import 'community_members_controller.dart';

const _syncingBarHeight = 2.0;

/// Whether other members of a community find the member, and the members
/// of the member's groups, each with the vouches between them and the
/// member, to vouch for them. Those are kept from opening the community and
/// synced each time this tab opens.
class CommunityMembersView extends HookConsumerWidget {
  const CommunityMembersView({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cache = communityMembersControllerProvider(communityDid);
    final syncing = useState<Future<void>?>(null);
    Future<void> sync() => syncing.value = ref.read(cache.notifier).sync();
    useEffect(() {
      // Not while building: syncing changes what is shown.
      Future.microtask(sync);
      return null;
    }, [communityDid]);
    final isSyncing =
        useFuture(syncing.value).connectionState == ConnectionState.waiting;
    final listed = ref.watch(cache);
    // Only over members already shown: until then the list itself waits.
    final showSyncing = isSyncing && listed.hasValue;

    Future<void> vouch(DirectoryEntry entry, String name) async {
      final personaDid = entry.did;
      if (personaDid == null) return;
      final edge = await vouchWithConsent(
        context,
        ref,
        communityDid: communityDid,
        communityName: communityName,
        personaDid: personaDid,
        name: name,
        entry: entry,
      );
      if (edge == null) return;
      ref.read(cache.notifier).vouched(personaDid, edge);
    }

    // One scroll view: on a short screen the list still gets room below
    // the settings.
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: VtcFindableView(
              communityDid: communityDid,
              communityName: communityName,
            ),
          ),
        ),
        // Height kept so the list does not shift as syncing starts and ends.
        SliverToBoxAdapter(
          child: SizedBox(
            height: _syncingBarHeight,
            child: showSyncing
                ? const LinearProgressIndicator(
                    key: Key('community_members_syncing'),
                  )
                : null,
          ),
        ),
        switch (listed) {
          AsyncData(value: (final members, _)) when members.isEmpty =>
            _Remaining(
              _Message(
                '${l10n.vtcGroupMembersNone}\n\n'
                '${l10n.vtcGroupMembersUnlistedNote(communityName)}',
              ),
            ),
          AsyncData(value: (final members, final edges)) =>
            SliverList.separated(
              // The note first: the community never says who is unlisted.
              itemCount: members.length + 1,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.vtcGroupMembersUnlistedNote(communityName),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                final entry = members[index - 1];
                return VtcMemberTile(
                  key: Key('community_member_${entry.entryId}'),
                  communityDid: communityDid,
                  communityName: communityName,
                  entry: entry,
                  edges: edges[entry.did] ?? const VtcEdges(),
                  names: vtcMemberNames(members),
                  onVouch: (name) => vouch(entry, name),
                );
              },
            ),
          AsyncError(:final error) => _Remaining(
            _Message(
              vtcTrustFailureMessage(
                l10n,
                error is VtcTrustException
                    ? error.failure
                    : VtcTrustFailure.failed,
                community: communityName,
                name: '',
              ),
            ),
          ),
          _ => const _Remaining(Center(child: CircularProgressIndicator())),
        },
      ],
    );
  }
}

/// [child] in the room left below the list's head.
class _Remaining extends StatelessWidget {
  const _Remaining(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SliverFillRemaining(hasScrollBody: false, child: child);
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
