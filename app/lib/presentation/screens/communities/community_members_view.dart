import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../vtc_trust/vtc_member_search_screen.dart';
import '../vtc_trust/vtc_member_tile.dart';
import '../vtc_trust/vtc_vouch.dart';
import 'community_members_controller.dart';

/// The other members of a community: those of the member's groups, or
/// those the member searches the directory for, each with the vouches
/// between them and the member, to vouch for them. The directory answers
/// searches only, never lists every member, so the groups' members show
/// until the member searches. Those are kept from opening the community
/// and synced each time this tab opens; a search is read each time.
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
    final service = ref.read(vtcTrustServiceProvider);
    final cache = communityMembersControllerProvider(communityDid);
    final query = useState<String?>(null);
    final reload = useState(0);
    useEffect(() {
      // Not while building: syncing changes what is shown.
      Future.microtask(() => ref.read(cache.notifier).sync());
      return null;
    }, [communityDid]);
    final listed = ref.watch(cache);
    final search = useMemoized(() async {
      final text = query.value;
      if (text == null) return null;
      if (text.length < VtcMemberSearchScreen.minQueryLength) {
        throw const VtcTrustException(VtcTrustFailure.searchTooShort);
      }
      return (
        await service.findMembers(communityDid, query: text),
        await service.edgesByMember(communityDid),
      );
    }, [query.value, reload.value]);
    final searched = useFuture(search);
    final loaded = query.value == null
        ? switch (listed) {
            AsyncData(:final value) =>
              AsyncSnapshot<CommunityMembers?>.withData(
                ConnectionState.done,
                value,
              ),
            AsyncError(:final error, :final stackTrace) =>
              AsyncSnapshot<CommunityMembers?>.withError(
                ConnectionState.done,
                error,
                stackTrace,
              ),
            _ => const AsyncSnapshot<CommunityMembers?>.waiting(),
          }
        : searched;
    final none = query.value == null
        ? l10n.vtcGroupMembersNone
        : l10n.vtcTrustSearchNone;

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
      if (query.value == null) {
        await ref.read(cache.notifier).sync();
      } else {
        reload.value++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            key: const Key('community_members_search_field'),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: l10n.vtcTrustSearchHint,
              helperText: l10n.communityMembersPrompt(communityName),
              helperMaxLines: 2,
              prefixIcon: const Icon(McIcons.search),
            ),
            // Nothing to search for shows the groups' members again.
            onSubmitted: (text) =>
                query.value = text.trim().isEmpty ? null : text.trim(),
          ),
        ),
        Expanded(
          child: switch (loaded) {
            AsyncSnapshot(connectionState: ConnectionState.waiting) =>
              const Center(child: CircularProgressIndicator()),
            AsyncSnapshot(hasError: true, :final error) => _Message(
              vtcTrustFailureMessage(
                l10n,
                error is VtcTrustException
                    ? error.failure
                    : VtcTrustFailure.failed,
                community: communityName,
                name: query.value ?? '',
              ),
            ),
            AsyncSnapshot(data: (final members, _)) when members.isEmpty =>
              _Message(
                '$none\n\n'
                '${l10n.vtcGroupMembersUnlistedNote(communityName)}',
              ),
            AsyncSnapshot(data: (final members, final edges)) =>
              ListView.separated(
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
            _ => const Center(child: CircularProgressIndicator()),
          },
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
