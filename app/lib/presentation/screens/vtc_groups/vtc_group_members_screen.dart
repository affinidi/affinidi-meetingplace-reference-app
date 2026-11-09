import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../vtc_join/vtc_role_name.dart';
import '../vtc_trust/vtc_member_avatar.dart';
import '../vtc_trust/vtc_member_credentials.dart';
import '../vtc_trust/vtc_vouch.dart';

/// The other members of a community group, as the community's directory
/// shows them, each with the vouches between them and the member, to vouch
/// for them. Opened from the group's box on the groups screen.
class VtcGroupMembersScreen extends HookConsumerWidget {
  const VtcGroupMembersScreen({
    super.key,
    required this.communityDid,
    required this.communityName,
    required this.group,
  });

  final String communityDid;
  final String communityName;
  final VtcGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final service = ref.read(vtcTrustServiceProvider);
    final reload = useState(0);
    final load = useMemoized(
      () async => (
        await service.groupMembers(communityDid, groupId: group.groupId),
        await service.edgesByMember(communityDid),
      ),
      [reload.value],
    );
    final loaded = useFuture(load);

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
      if (edge != null) reload.value++;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vtcGroupMembersTitle(group.name))),
      body: switch (loaded) {
        AsyncSnapshot(hasError: true, :final error) => _Message(
          vtcTrustFailureMessage(
            l10n,
            error is VtcTrustException ? error.failure : VtcTrustFailure.failed,
            community: communityName,
            name: group.name,
          ),
        ),
        AsyncSnapshot(data: (final members, _)) when members.isEmpty =>
          _Message(
            '${l10n.vtcGroupMembersNone}\n\n'
            '${l10n.vtcGroupMembersUnlistedNote(communityName)}',
          ),
        AsyncSnapshot(data: (final members, final edges)) => ListView.separated(
          // The note first: the community never says who is unlisted.
          itemCount: members.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                key: const Key('vtc_group_members_unlisted'),
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
            final name =
                entry.displayName ?? entry.nickname ?? l10n.vtcTrustUnnamed;
            final memberEdges = edges[entry.did] ?? const VtcEdges();
            return ListTile(
              key: Key('vtc_group_member_${entry.entryId}'),
              leading: VtcMemberAvatar(
                communityDid: communityDid,
                entry: entry,
              ),
              title: Text(name),
              subtitle: switch ((entry.role, entry.did)) {
                (null, null) => Text(
                  l10n.vtcTrustNotFindable(name, communityName),
                ),
                (final role?, null) => Text(
                  '${vtcRoleName(l10n, role)}\n'
                  '${l10n.vtcTrustNotFindable(name, communityName)}',
                ),
                (final role?, _) => Text(
                  vtcRoleName(l10n, role),
                  key: Key('vtc_group_member_role_${entry.entryId}'),
                ),
                (null, _) => null,
              },
              // The icons last, in a slot each, so they line up on the
              // right in every row whether or not it offers to vouch.
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (entry.did != null && memberEdges.outgoing == null)
                    FilledButton(
                      onPressed: () => vouch(entry, name),
                      child: Text(
                        memberEdges.canVouchBack
                            ? l10n.vtcTrustVouchBack
                            : l10n.vtcTrustVouch,
                      ),
                    ),
                  SizedBox.square(
                    dimension: _iconSlot,
                    child: VtcVouchButton(
                      edges: memberEdges,
                      name: name,
                      communityDid: communityDid,
                      communityName: communityName,
                      entry: entry,
                    ),
                  ),
                  SizedBox.square(
                    dimension: _iconSlot,
                    child: VtcMemberCredentialsButton(
                      communityDid: communityDid,
                      communityName: communityName,
                      entry: entry,
                      name: name,
                      names: {
                        for (final member in members)
                          if ((
                                member.did,
                                member.displayName ?? member.nickname,
                              )
                              case (final did?, final shown?))
                            did: shown,
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// The room each icon of a member's row takes, kept when it shows none.
const _iconSlot = 40.0;

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
