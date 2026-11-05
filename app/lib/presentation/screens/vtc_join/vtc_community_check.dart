import 'package:flutter/material.dart';

import '../../../domain/models/vtc/vtc_community_address.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';

/// What lets the member tell this is the community they meant: where its
/// DID says it is hosted and, for a `did:webvh`, its fingerprint, to
/// compare with what the community shows elsewhere.
///
/// Both come from the DID, not from what the community says about itself.
class VtcCommunityCheck extends StatelessWidget {
  const VtcCommunityCheck({
    super.key,
    required this.address,
    required this.communityName,
  });

  final VtcCommunityAddress address;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassCard(
      title: l10n.vtcJoinRightCommunityHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          OnboardingLine(
            key: const Key('vtc_join_host'),
            icon: Icons.dns_outlined,
            title: l10n.vtcJoinHostedAt,
            subtitle: address.host,
          ),
          if (address.groupedFingerprint case final fingerprint?)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                const Icon(Icons.fingerprint, size: 20, color: Colors.white),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        l10n.vtcJoinFingerprint,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      MonospaceDid(
                        fingerprint,
                        textKey: const Key('vtc_join_fingerprint'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Text(
            l10n.vtcJoinCompareHint(communityName),
            style: onboardingNote(context),
          ),
        ],
      ),
    );
  }
}
