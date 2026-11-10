import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';

/// The community's logo above the title; nothing while it cannot load.
class VtcCommunityLogo extends StatelessWidget {
  const VtcCommunityLogo(this.url);

  final Uri url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(McRadius.md),
        child: Image.network(
          url.toString(),
          key: const Key('vtc_join_logo'),
          height: 64,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Who the community is: its description, website and DID, which can both
/// be copied, contact, and the join phrase it can be found by.
class VtcCommunityProfile extends HookWidget {
  const VtcCommunityProfile({
    super.key,
    required this.communityDid,
    this.description,
    this.website,
    this.contactEmail,
    this.joinPhrase,
  });

  final String communityDid;
  final String? description;
  final Uri? website;
  final String? contactEmail;
  final String? joinPhrase;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final did = communityDid;
    final copied = useState(false);
    final websiteCopied = useState(false);
    final mc = context.mcColors;

    Future<void> copyDid() async {
      await Clipboard.setData(ClipboardData(text: did));
      copied.value = true;
    }

    Future<void> copyWebsite(Uri website) async {
      await Clipboard.setData(ClipboardData(text: website.toString()));
      websiteCopied.value = true;
    }

    return GlassCard(
      title: l10n.vtcJoinProfileHeading,
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: McSpacing.s3,
          children: [
            if (description case final description?)
              Text(
                description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: mc.textPrimary,
                ),
              ),
            if (website case final website?)
              OnboardingLine(
                icon: McIcons.website,
                title: l10n.vtcJoinWebsite,
                subtitle: website.toString(),
                trailing: IconButton(
                  key: const Key('vtc_community_copy_website'),
                  icon: Icon(
                    websiteCopied.value ? McIcons.check : McIcons.copy,
                    size: 18,
                    color: mc.textSecondary,
                  ),
                  tooltip: websiteCopied.value
                      ? l10n.copiedToClipboard
                      : l10n.vtcJoinCopyWebsite,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => copyWebsite(website),
                ),
              ),
            if (contactEmail case final email?)
              OnboardingLine(
                icon: McIcons.email,
                title: l10n.vtcJoinContact,
                subtitle: email,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: McSpacing.s3,
              children: [
                FirstLineIcon(
                  McIcons.identities,
                  size: 20,
                  color: mc.textSecondary,
                  style: context.textTheme.bodyMedium,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: McSpacing.s05,
                    children: [
                      Text(
                        l10n.communityDidLabel,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: mc.textPrimary,
                        ),
                      ),
                      MonospaceDid(
                        did,
                        textKey: const Key('vtc_join_community_did'),
                      ),
                      if (copied.value)
                        Text(
                          l10n.copiedToClipboard,
                          style: onboardingNote(context),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(McIcons.copy, size: 18, color: mc.textSecondary),
                  tooltip: l10n.linkedVtaCopyDid,
                  visualDensity: VisualDensity.compact,
                  onPressed: copyDid,
                ),
              ],
            ),
            if (joinPhrase case final phrase?)
              OnboardingLine(
                key: const Key('vtc_community_join_phrase'),
                icon: McIcons.key,
                title: l10n.vtcJoinPhraseHeading,
                subtitle: phrase,
              ),
          ],
        ),
      ),
    );
  }
}
