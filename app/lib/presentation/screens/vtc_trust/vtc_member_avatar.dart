import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/vtc_trust_service/vtc_trust_service.dart';

/// The picture the member of [entry] shows in the community's directory,
/// or a person until it arrives, or when they show none or it cannot be
/// fetched.
class VtcMemberAvatar extends HookConsumerWidget {
  const VtcMemberAvatar({
    super.key,
    required this.communityDid,
    required this.entry,
  });

  final String communityDid;
  final DirectoryEntry entry;

  static const _radius = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(vtcTrustServiceProvider);
    final load = useMemoized(
      () => service.memberPicture(communityDid, entry: entry),
      [communityDid, entry.entryId, entry.avatarSha256],
    );
    final picture = useFuture(load).data;
    if (picture == null) {
      return const SizedBox.square(
        dimension: _radius * 2,
        child: Icon(Icons.person_outline),
      );
    }
    return CircleAvatar(
      key: Key('vtc_member_avatar_${entry.entryId}'),
      radius: _radius,
      backgroundImage: MemoryImage(picture),
    );
  }
}
