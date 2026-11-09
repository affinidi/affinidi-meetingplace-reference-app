import 'package:flutter/material.dart';

import 'vtc_findable_view.dart';
import 'vtc_join_phrase_view.dart';

/// The built-in role that manages the community's join phrase; a role the
/// community defined itself never does, whatever its name.
const _adminRole = 'admin';

/// The community's settings for the member: how other members find them,
/// and, for an administrator, the community's join phrase.
class VtcCommunitySettings extends StatelessWidget {
  const VtcCommunitySettings({
    super.key,
    required this.communityDid,
    required this.communityName,
    required this.role,
  });

  final String communityDid;
  final String communityName;

  /// The member's role in the community; none while it is unknown.
  final String? role;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: [
      if (role == _adminRole)
        VtcJoinPhraseView(
          communityDid: communityDid,
          communityName: communityName,
        ),
      VtcFindableView(communityDid: communityDid, communityName: communityName),
    ],
  );
}
