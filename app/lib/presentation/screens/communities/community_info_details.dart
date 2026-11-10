import 'package:flutter/material.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../vtc_join/vtc_community_profile.dart';

/// What else a community publishes about itself — its website and contact
/// — with its DID, and the join phrase this phone published for it, if
/// any, unfolded under its description. The DID shows also when the
/// profile cannot be read.
class CommunityInfoDetails extends StatelessWidget {
  const CommunityInfoDetails({
    super.key,
    required this.communityDid,
    required this.profile,
    required this.joinPhrase,
  });

  final String communityDid;

  /// Null when the community's profile cannot be read.
  final CommunityProfile? profile;

  final String? joinPhrase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: McSpacing.s3,
      children: [
        // The description shows above already.
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
    );
  }
}
