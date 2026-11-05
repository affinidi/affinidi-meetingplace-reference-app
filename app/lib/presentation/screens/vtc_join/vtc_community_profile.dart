import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_join_state.dart';

/// The community's logo above the title; nothing while it cannot load.
class VtcCommunityLogo extends StatelessWidget {
  const VtcCommunityLogo(this.url);

  final Uri url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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

/// Who the community is: its description, website, contact and DID, which
/// can be copied.
class VtcCommunityProfile extends HookWidget {
  const VtcCommunityProfile({required this.state});

  final VtcJoinState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final did = state.communityDid ?? '';
    final copied = useState(false);

    Future<void> copyDid() async {
      await Clipboard.setData(ClipboardData(text: did));
      copied.value = true;
    }

    return GlassCard(
      title: l10n.vtcJoinProfileHeading,
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            if (state.description case final description?)
              Text(
                description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            if (state.website case final website?)
              OnboardingLine(
                icon: Icons.language,
                title: l10n.vtcJoinWebsite,
                subtitle: website.toString(),
              ),
            if (state.contactEmail case final email?)
              OnboardingLine(
                icon: Icons.mail_outline,
                title: l10n.vtcJoinContact,
                subtitle: email,
              ),
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
                        l10n.vtcJoinDidHint,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
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
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white),
                  tooltip: l10n.linkedVtaCopyDid,
                  visualDensity: VisualDensity.compact,
                  onPressed: copyDid,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
