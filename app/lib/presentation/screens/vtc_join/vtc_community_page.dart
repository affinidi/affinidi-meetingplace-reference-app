import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../domain/models/vtc/vtc_card_delivery.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_card_delivery_trail.dart';
import 'vtc_community_profile.dart';
import 'vtc_flow_diagram.dart';
import 'vtc_identity_check_view.dart';
import 'vtc_join_phrase_view.dart';
import 'vtc_join_state.dart';
import 'vtc_membership_card_view.dart';

/// Prefix of a role the community defined itself, as in `custom:coach`.
const _customRolePrefix = 'custom:';

/// The member's [role] in plain words; a role the community defined itself
/// by its own name, which never reads as a built-in one.
String _roleName(AppLocalizations l10n, String role) =>
    role.startsWith(_customRolePrefix)
    ? role.substring(_customRolePrefix.length)
    : l10n.vtcCommunityRoleName(role);

/// The page of a community the member belongs to, which they come back to:
/// a welcome right after joining, else the community's logo and name; their
/// role, with the community's settings behind a button beside it, the
/// membership card it issued — or that it is on its way to the member's
/// VTA — what the community is, then Done and [leave].
class VtcCommunityPage extends StatelessWidget {
  const VtcCommunityPage({
    required this.state,
    required this.onDone,
    required this.leave,
  });

  final VtcJoinState state;
  final VoidCallback onDone;
  final Widget leave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = state.communityName ?? '';
    final card = state.membershipCard;
    final delivery = state.cardDelivery;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (state.wasMember) ...[
          if (state.logoUrl case final logoUrl?) VtcCommunityLogo(logoUrl),
          Text(
            name,
            key: const Key('vtc_community_name'),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ] else ...[
          const Icon(Icons.verified, size: 72, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            l10n.vtcJoinJoined(name),
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ],
        if (state.role case final role?)
          OnboardingLine(
            key: const Key('vtc_community_role'),
            icon: Icons.badge_outlined,
            title: l10n.vtcCommunityRole,
            subtitle: _roleName(l10n, role),
            centered: true,
            trailing: switch (state.communityDid) {
              final communityDid? => IconButton(
                key: const Key('vtc_community_settings'),
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                tooltip: l10n.vtcCommunitySettings,
                onPressed: () => _showSettings(context, communityDid, name),
              ),
              null => null,
            },
          ),
        const SizedBox(height: 4),
        if (card != null) ...[
          VtcMembershipCardView(
            card: card,
            communityName: name,
            logoUrl: state.logoUrl,
          ),
          _CardRoute(communityName: name, memberDid: card.memberDid),
          if (delivery != null)
            _CardArrival(delivery: delivery, communityName: name),
        ] else if (delivery != null)
          VtcCardDeliveryTrail(delivery: delivery, communityName: name)
        else
          Row(
            key: const Key('vtc_membership_card_pending'),
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              const Icon(Icons.hourglass_top, size: 16, color: Colors.white70),
              Flexible(
                child: Text(
                  l10n.vtcMembershipCardOnItsWay,
                  style: onboardingNote(context),
                ),
              ),
            ],
          ),
        if (state.identityCheck case final check?)
          VtcIdentityCheckView(check: check, communityName: name),
        VtcCommunityProfile(state: state),
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.generalDone, onPressed: onDone),
        leave,
      ],
    );
  }
}

/// Opens the settings of the community at [communityDid] in a sheet on the
/// onboarding gradient: for now its join phrase.
Future<void> _showSettings(
  BuildContext context,
  String communityDid,
  String communityName,
) {
  const radius = BorderRadius.vertical(top: Radius.circular(24));
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DecoratedBox(
      decoration: onboardingGradient(context, radius: 2, borderRadius: radius),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: VtcJoinPhraseView(
          communityDid: communityDid,
          communityName: communityName,
        ),
      ),
    ),
  );
}

/// Where the card on show came from, as the Credentials tab draws it: the
/// community issued it to the identity, which passed it on to the VTA.
class _CardRoute extends ConsumerWidget {
  const _CardRoute({required this.communityName, required this.memberDid});

  final String communityName;

  /// The DID of the identity the card is for.
  final String memberDid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = ref
        .watch(identitiesServiceProvider)
        .identities
        .where((identity) => identity.did == memberDid)
        .firstOrNull
        ?.card
        .displayName
        .trim();
    final identity = name == null || name.isEmpty
        ? l10n.vtcJoinTrailIdentity
        : name;
    return VtcFlowBox(
      key: const Key('vtc_join_card_route'),
      flow: VtcFlowDiagram(
        nodes: [
          VtcFlowNode(Icons.groups_outlined, l10n.membershipFlowCommunity),
          VtcFlowNode(Icons.person_outline, identity),
          VtcFlowNode(Icons.shield_outlined, l10n.membershipTrailYourVta),
        ],
      ),
      summary: Text(
        l10n.vtcJoinCardRoute(communityName, identity),
        style: onboardingNote(context),
      ),
    );
  }
}

/// How the card on show came to the VTA, folded away behind a toggle.
class _CardArrival extends HookWidget {
  const _CardArrival({required this.delivery, required this.communityName});

  final VtcCardDelivery delivery;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        InkWell(
          key: const Key('vtc_delivery_toggle'),
          onTap: () => expanded.value = !expanded.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                const Icon(Icons.route_outlined, color: Colors.white),
                Expanded(
                  child: Text(
                    context.l10n.vtcDeliveryHeading,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  expanded.value ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        if (expanded.value)
          VtcCardDeliveryTrail(
            delivery: delivery,
            communityName: communityName,
          ),
      ],
    );
  }
}
