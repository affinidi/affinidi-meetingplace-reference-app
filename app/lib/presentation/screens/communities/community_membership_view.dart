import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../vtc_join/vtc_join_screen.dart';
import '../vtc_join/vtc_membership_card_view.dart';
import '../vtc_join/vtc_role_name.dart';
import 'community_logo_provider.dart';
import 'community_tabs_providers.dart';

/// The member's membership of a community: their role there and the
/// membership card it issued, both as their VTA keeps them, and a way to
/// leave it.
class CommunityMembershipView extends ConsumerWidget {
  const CommunityMembershipView({
    super.key,
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final role = ref.watch(communityRoleProvider(communityDid));
    final card = ref.watch(communityMembershipCardProvider(communityDid));
    final logoUrl = ref.watch(communityLogoProvider(communityDid)).value;

    if (role.error ?? card.error case final error?) {
      return _Message(switch (error) {
        VtaNotLinkedException() => l10n.membershipCredentialsVtaMissing,
        _ => l10n.membershipCredentialsUnreachable,
      });
    }
    if (!role.hasValue || !card.hasValue) {
      return const Center(child: OnboardingSpinner());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (role.value case final role?)
            OnboardingLine(
              key: const Key('community_membership_role'),
              icon: McIcons.badge,
              title: l10n.vtcCommunityRole,
              subtitle: vtcRoleName(l10n, role),
            ),
          if (card.value case final card?)
            VtcMembershipCardView(
              card: card,
              communityName: communityName,
              logoUrl: logoUrl,
            )
          else
            Row(
              key: const Key('community_membership_card_pending'),
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 8,
              children: [
                Icon(McIcons.pending, color: context.mcColors.textSecondary),
                Flexible(
                  child: Text(
                    l10n.vtcMembershipCardOnItsWay,
                    style: onboardingNote(context),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const Key('community_membership_leave'),
            onPressed: () => _leave(context, ref),
            style: context.destructiveElevatedButtonStyle,
            child: Text(l10n.vtcJoinLeaveAction),
          ),
        ],
      ),
    );
  }

  /// Leaves the community once the member confirms, then closes it: they
  /// no longer belong to it.
  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    // Read now: the view may be gone once leaving ends.
    final service = ref.read(vtcServiceProvider);
    if (!await confirmLeaveCommunity(context, communityName)) return;
    if (!context.mounted) return;
    await VtcJoinScreen.showLeaving(
      context,
      communityDid: communityDid,
      communityName: communityName,
    );
    // Still a member when leaving failed or was refused.
    final community = await service.community(communityDid);
    if (community == null && context.mounted) Navigator.of(context).pop();
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
