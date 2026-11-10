import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../vtc_join/vtc_community_settings.dart';
import '../vtc_join/vtc_join_phrase_view.dart';
import 'community_tabs_providers.dart';

/// Opens how people find a community by its join phrase, beside its name,
/// once the member's role says they administer it; nothing otherwise.
class CommunityJoinPhraseAction extends ConsumerWidget {
  const CommunityJoinPhraseAction({
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
    if (!managesJoinPhrase(role)) return const SizedBox.shrink();

    return IconButton(
      key: const Key('community_join_phrase'),
      visualDensity: VisualDensity.compact,
      icon: Icon(McIcons.public, color: context.mcColors.textSecondary),
      tooltip: context.l10n.vtcJoinPhraseHeading,
      onPressed: () => showOnboardingSheet(
        context,
        VtcJoinPhraseView(
          communityDid: communityDid,
          communityName: communityName,
        ),
      ),
    );
  }
}
