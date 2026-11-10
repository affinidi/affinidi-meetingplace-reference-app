import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../../widgets/vta_identity_card.dart';
import '../vtc_join/vtc_join_screen.dart';
import '../vtc_join/vtc_membership_card_view.dart';
import '../vtc_join/vtc_role_name.dart';
import 'communities_controller.dart';
import 'community_logo_provider.dart';
import 'community_tabs_providers.dart';

/// The role a vetter card gives, as a community names it.
const _vetterRole = 'vetter';

/// The member's membership of a community: the identity they joined with,
/// their role there and the cards it issued them, the membership card and a
/// vetter's role card, and the cards its groups issued them that are valid
/// now, as their VTA keeps them, each with its details folded away, and a
/// way to leave it.
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
    // Only a vetter holds one; the Vetting tab says when it cannot be read.
    final vetterCard = ref
        .watch(communityVetterCardProvider(communityDid))
        .value;
    // Shown once read; a card the VTA cannot give is not missed here.
    final groupCards =
        ref.watch(communityGroupCardsProvider(communityDid)).value ?? const [];
    final logoUrl = ref.watch(communityLogoProvider(communityDid)).value;
    final joinedAs = _joinedAs(ref);
    final roleName = switch (role.value) {
      // A vetter card is held alongside the role, e.g. by an administrator.
      final role? when vetterCard != null && role != _vetterRole => [
        vtcRoleName(l10n, role),
        vtcRoleName(l10n, _vetterRole),
      ].join(' · '),
      final role? => vtcRoleName(l10n, role),
      null => null,
    };

    if (role.error ?? card.error case final error?) {
      return _Message(switch (error) {
        VtaNotLinkedException() => l10n.membershipCredentialsVtaMissing,
        _ => l10n.membershipCredentialsUnreachable,
      });
    }
    // The card shows as soon as it is read; the role joins it once read.
    if (!card.hasValue) {
      return const Center(child: OnboardingSpinner());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (joinedAs case (final identity, :final did))
            VtaIdentityCard(
              key: const Key('community_membership_identity'),
              did: did,
              identity: identity,
              role: roleName,
            )
          // Without the identity's card, the role stands on its own.
          else if (roleName != null)
            OnboardingLine(
              key: const Key('community_membership_role'),
              icon: McIcons.badge,
              title: l10n.vtcCommunityRole,
              subtitle: roleName,
            ),
          if (card.value case final card?)
            VtcMembershipCardView(
              card: card,
              logoUrl: logoUrl,
              collapsible: true,
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
          if (vetterCard != null)
            VtcVetterCardView(
              card: vetterCard,
              logoUrl: logoUrl,
              collapsible: true,
            ),
          for (final card in groupCards)
            VtcGroupCardView(card: card, logoUrl: logoUrl, collapsible: true),
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

  /// The identity the member joined with, and the DID the community knows
  /// it by: its own, or one made for the community alone; null for a new
  /// identity, which has no profile.
  (Identity, {String did})? _joinedAs(WidgetRef ref) {
    final community = ref
        .watch(communitiesControllerProvider)
        .value
        ?.where((community) => community.communityDid == communityDid)
        .firstOrNull;
    if (community == null) return null;
    // A DID made for this community lives in the identity's context too.
    final identity = ref
        .watch(identitiesServiceProvider)
        .vtaPersonas
        .where((identity) => identity.vtaContextId == community.contextId)
        .firstOrNull;
    if (identity == null) return null;
    return (identity, did: community.personaDid);
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
