import 'package:flutter/material.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../vtc_join/vtc_role_name.dart';
import 'vtc_member_avatar.dart';
import 'vtc_member_credentials.dart';
import 'vtc_vouch.dart';

/// Another member of a community, as its directory shows them: their
/// picture, name and role, the vouches between them and the member, an
/// offer to vouch for them, and their credentials.
class VtcMemberTile extends StatelessWidget {
  const VtcMemberTile({
    super.key,
    required this.communityDid,
    required this.communityName,
    required this.entry,
    required this.edges,
    required this.names,
    required this.onVouch,
    this.onRefreshed,
  });

  final String communityDid;
  final String communityName;
  final DirectoryEntry entry;

  /// The vouches between this member and the member on this phone.
  final VtcEdges edges;

  /// The names of the members shown, by their DID, to name who vouched.
  final Map<String, String> names;

  /// Vouches for this member, given the name the row shows.
  final void Function(String name) onVouch;

  /// Takes the vouches with this member as read once the member opened
  /// them.
  final ValueChanged<VtcEdges>? onRefreshed;

  /// The room each icon of a row takes, kept when it shows none.
  static const _iconSlot = 40.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = entry.displayName ?? entry.nickname ?? l10n.vtcTrustUnnamed;
    return ListTile(
      leading: VtcMemberAvatar(communityDid: communityDid, entry: entry),
      title: Text(name),
      subtitle: switch (entry.role) {
        final role? => Text(
          vtcRoleName(l10n, role),
          key: Key('vtc_member_role_${entry.entryId}'),
        ),
        null => null,
      },
      // The icons last, in a slot each, so they line up on the right in
      // every row whether or not it offers to vouch.
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (entry.did != null && edges.outgoing == null)
            FilledButton(
              onPressed: () => onVouch(name),
              child: Text(
                edges.canVouchBack
                    ? l10n.vtcTrustVouchBack
                    : l10n.vtcTrustVouch,
              ),
            ),
          SizedBox.square(
            dimension: _iconSlot,
            child: VtcVouchButton(
              edges: edges,
              name: name,
              communityDid: communityDid,
              communityName: communityName,
              entry: entry,
              onRefreshed: onRefreshed,
            ),
          ),
          SizedBox.square(
            dimension: _iconSlot,
            child: VtcMemberCredentialsButton(
              communityDid: communityDid,
              communityName: communityName,
              entry: entry,
              name: name,
              names: names,
            ),
          ),
        ],
      ),
    );
  }
}

/// The names [entries] show, by their DID, for [VtcMemberTile.names].
Map<String, String> vtcMemberNames(Iterable<DirectoryEntry> entries) => {
  for (final entry in entries)
    if ((entry.did, entry.displayName ?? entry.nickname) case (
      final did?,
      final shown?,
    ))
      did: shown,
};
