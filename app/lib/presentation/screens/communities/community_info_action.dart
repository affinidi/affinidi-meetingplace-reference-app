import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../vtc_join/vtc_community_profile.dart';
import 'community_tabs_providers.dart';

/// Opens what else a community publishes about itself — its website and
/// contact — with its DID, and the join phrase this phone published for
/// it, if any, beside its description; nothing until it is read. The DID
/// shows also when the profile cannot be read.
class CommunityInfoAction extends ConsumerWidget {
  const CommunityInfoAction({super.key, required this.communityDid});

  final String communityDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(communityInfoProvider(communityDid)).value;
    if (data == null) return const SizedBox.shrink();
    final (profile, joinPhrase) = data;

    return IconButton(
      key: const Key('community_info'),
      visualDensity: VisualDensity.compact,
      icon: Icon(McIcons.info, color: context.mcColors.textSecondary),
      tooltip: context.l10n.vtcJoinProfileHeading,
      onPressed: () => showOnboardingSheet(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            // The description shows under the community's name already.
            VtcCommunityProfile(
              communityDid: communityDid,
              website: profile?.website,
              contactEmail: profile?.contactEmail,
              joinPhrase: joinPhrase,
            ),
            if (profile == null)
              OnboardingMessage(
                context.l10n.communityInfoUnavailable,
                isError: false,
              ),
          ],
        ),
      ),
    );
  }
}
