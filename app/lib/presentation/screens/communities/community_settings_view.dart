import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../vtc_join/vtc_community_settings.dart';
import '../vtc_join/vtc_join_phrase_view.dart';
import 'community_tabs_providers.dart';

/// The member's settings for a community: its join phrase, once their role
/// says they administer it.
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
    // Null also when the VTA cannot be asked.
    final role = ref.watch(communityRoleProvider(communityDid)).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: managesJoinPhrase(role)
          ? VtcJoinPhraseView(
              communityDid: communityDid,
              communityName: communityName,
            )
          : null,
    );
  }
}
