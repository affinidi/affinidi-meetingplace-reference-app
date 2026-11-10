import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../vtc_join/vtc_community_settings.dart';
import 'community_tabs_providers.dart';

/// The member's settings for a community: how other members find them at
/// once, and the community's join phrase too once their role says they
/// administer it.
class CommunitySettingsView extends ConsumerWidget {
  const CommunitySettingsView({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Null also when the VTA cannot be asked: the settings every member
    // has still show.
    final role = ref.watch(communityRoleProvider(communityDid)).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: VtcCommunitySettings(
        communityDid: communityDid,
        communityName: communityName,
        role: role,
      ),
    );
  }
}
