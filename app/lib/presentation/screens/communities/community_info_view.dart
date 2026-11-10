import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../vtc_join/vtc_community_profile.dart';
import 'community_tabs_providers.dart';

/// What a community publishes about itself — what it is about, its
/// website and contact — with its DID, and the join phrase this phone
/// published for it, if any. The DID shows also when the profile cannot be
/// read.
class CommunityInfoView extends ConsumerWidget {
  const CommunityInfoView({super.key, required this.communityDid});

  final String communityDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(communityInfoProvider(communityDid)).value;
    if (data == null) return const Center(child: OnboardingSpinner());
    final (profile, joinPhrase) = data;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          VtcCommunityProfile(
            communityDid: communityDid,
            description: profile?.description,
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
    );
  }
}
