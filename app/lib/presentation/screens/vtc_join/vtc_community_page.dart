import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_vtc/meeting_place_vtc.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../domain/models/vtc/vtc_card_delivery.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../vtc_vetter_profile/vtc_vetter_profile_screen.dart';
import '../vtc_vetting_desk/vtc_vetting_desk_screen.dart';
import 'vtc_card_delivery_trail.dart';
import 'vtc_community_profile.dart';
import 'vtc_findable_view.dart';
import 'vtc_flow_diagram.dart';
import 'vtc_identity_check_view.dart';
import 'vtc_join_phrase_view.dart';
import 'vtc_join_state.dart';
import 'vtc_membership_card_view.dart';
import 'vtc_progress_line.dart';
import 'vtc_trail_step.dart';

/// Prefix of a role the community defined itself, as in `custom:coach`.
const _customRolePrefix = 'custom:';

/// The built-in role that manages the community's join phrase; a role the
/// community defined itself never does, whatever its name.
const _adminRole = 'admin';

/// The member's [role] in plain words; a role the community defined itself
/// by its own name, which never reads as a built-in one.
String _roleName(AppLocalizations l10n, String role) =>
    role.startsWith(_customRolePrefix)
    ? role.substring(_customRolePrefix.length)
    : l10n.vtcCommunityRoleName(role);

/// The page of a community the member belongs to, which they come back to:
/// a welcome right after joining, else the community's logo and name; their
/// role, with the community's settings and the vetting desk behind icons
/// beside it for an administrator and a vetter, the membership card it
/// issued — or that it is on its way to the member's VTA — then Done and
/// [leave]. What the community is waits behind an icon beside its name.
class VtcCommunityPage extends HookConsumerWidget {
  const VtcCommunityPage({
    required this.state,
    required this.onDone,
    required this.leave,
  });

  final VtcJoinState state;
  final VoidCallback onDone;
  final Widget leave;

  /// Whether the member may vet here; why not, or why it could not be
  /// told, goes to the log, never a DID or a card.
  Future<bool> _canVet(WidgetRef ref, String communityDid) async {
    final logger = ref.read(appLoggerProvider);
    try {
      final canVet = await ref.read(vtcServiceProvider).canVet(communityDid);
      if (!canVet) {
        logger.info(
          'No vetter card in date and not revoked',
          name: 'VtcCommunityPage',
        );
      }
      return canVet;
    } on Exception catch (error, stackTrace) {
      final reason = switch (error) {
        MeetingPlaceVtcSDKException(:final code, :final message) =>
          '${code.name}: $message',
        _ => '${error.runtimeType}',
      };
      logger.error(
        'Checking the vetter card failed: $reason',
        stackTrace: stackTrace,
        name: 'VtcCommunityPage',
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = state.communityName ?? '';
    final card = state.membershipCard;
    final delivery = state.cardDelivery;
    final communityDid = state.communityDid;
    // Whatever role the role line shows: the vetter role comes on a card of
    // its own, checked from the start alongside the reads of the card and
    // the role rather than after them. Until the check answers, its last
    // answer stands; the desk checks the card again before any ticket.
    final canVet = useFuture(
      useMemoized(
        () async => communityDid != null && await _canVet(ref, communityDid),
        [communityDid],
      ),
    );
    final couldVet = useFuture(
      useMemoized(
        () async =>
            communityDid != null &&
            await ref.read(vtcServiceProvider).couldVet(communityDid),
        [communityDid],
      ),
    );
    final offersVetting = canVet.hasData
        ? canVet.data!
        : !canVet.hasError && couldVet.data == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (state.wasMember) ...[
          if (state.logoUrl case final logoUrl?) VtcCommunityLogo(logoUrl),
          _WithAbout(
            state: state,
            child: Text(
              name,
              key: const Key('vtc_community_name'),
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ] else ...[
          const Icon(Icons.verified, size: 72, color: Colors.white),
          const SizedBox(height: 4),
          _WithAbout(
            state: state,
            child: Text(
              l10n.vtcJoinJoined(name),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
        if (state.role case final role?)
          _RoleLine(
            role: role,
            communityDid: communityDid,
            communityName: name,
            canVet: offersVetting,
          ),
        if (communityDid != null && canVet.data == true)
          _VetterProfilePrompt(communityDid: communityDid, communityName: name),
        if (canVet.hasError)
          OnboardingMessage(
            l10n.vtcVetterCheckFailed,
            key: const Key('vtc_community_vetting_check_failed'),
            isError: true,
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
        else if (state.gettingCard)
          _CardLookup(step: state.cardStep, communityName: name)
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
        const SizedBox(height: 12),
        OnboardingButton(label: l10n.generalDone, onPressed: onDone),
        leave,
      ],
    );
  }
}

/// The member's [role], with the community's settings beside it and the
/// vetting desk for a vetter.
class _RoleLine extends StatelessWidget {
  const _RoleLine({
    required this.role,
    required this.communityDid,
    required this.communityName,
    required this.canVet,
  });

  final String role;
  final String? communityDid;
  final String communityName;

  /// Whether the member's vetter card for the community holds.
  final bool canVet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final communityDid = this.communityDid;
    final actions = [
      if (communityDid != null)
        IconButton(
          key: const Key('vtc_community_settings'),
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          tooltip: l10n.vtcCommunitySettings,
          onPressed: () => _showSettings(
            context,
            communityDid,
            communityName,
            isAdmin: role == _adminRole,
          ),
        ),
      if (communityDid != null && canVet)
        IconButton(
          key: const Key('vtc_community_vetting_desk'),
          icon: const Icon(Icons.how_to_reg_outlined, color: Colors.white),
          tooltip: l10n.vtcVetterStart,
          onPressed: () => VtcVettingDeskScreen.show(
            context,
            communityDid: communityDid,
            communityName: communityName,
          ),
        ),
    ];
    return OnboardingLine(
      key: const Key('vtc_community_role'),
      icon: Icons.badge_outlined,
      title: l10n.vtcCommunityRole,
      subtitle: _roleName(l10n, role),
      trailing: actions.isEmpty
          ? null
          : Row(mainAxisSize: MainAxisSize.min, children: actions),
    );
  }
}

/// Asks a vetter whose profile the community does not hold to write one,
/// as applicants cannot find them until they do; else shows nothing.
class _VetterProfilePrompt extends HookConsumerWidget {
  const _VetterProfilePrompt({
    required this.communityDid,
    required this.communityName,
  });

  final String communityDid;
  final String communityName;

  /// Whether the community holds no profile of the member's; not knowing
  /// goes to the log and asks nothing.
  Future<bool> _profileNeeded(WidgetRef ref) async {
    try {
      return await ref
          .read(vtcServiceProvider)
          .vetterProfileNeeded(communityDid);
    } on Exception catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .error(
            'Checking the vetter profile failed: ${error.runtimeType}',
            stackTrace: stackTrace,
            name: 'VtcCommunityPage',
          );
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Asked again once the profile screen closes.
    final profileChecks = useState(0);
    final profileNeeded = useFuture(
      useMemoized(() => _profileNeeded(ref), [
        communityDid,
        profileChecks.value,
      ]),
    );
    if (profileNeeded.data != true) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        OnboardingMessage(
          l10n.vtcVetterProfileNeeded,
          key: const Key('vtc_community_vetter_profile_needed'),
          isError: false,
        ),
        OnboardingButton(
          key: const Key('vtc_community_vetter_profile'),
          label: l10n.vtcVetterProfileSetUp,
          onPressed: () async {
            await VtcVetterProfileScreen.show(
              context,
              communityDid: communityDid,
              communityName: communityName,
            );
            profileChecks.value++;
          },
        ),
      ],
    );
  }
}

/// Finding the member's card on their VTA, step by step: each step done,
/// under way, or still to come.
class _CardLookup extends StatelessWidget {
  const _CardLookup({required this.step, required this.communityName});

  /// The step under way; none yet means the first is about to start.
  final MembershipCardStep? step;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = step ?? MembershipCardStep.values.first;
    return VtcBackgroundPanel(
      key: const Key('vtc_membership_card_loading'),
      title: l10n.vtcMembershipCardLoading,
      children: [
        for (final step in MembershipCardStep.values)
          VtcProgressLine(
            key: Key('vtc_card_step_${step.name}'),
            title: switch (step) {
              MembershipCardStep.finding => l10n.vtcCardStepFinding(
                communityName,
              ),
              MembershipCardStep.reading => l10n.vtcCardStepReading,
            },
            stage: switch (step.index.compareTo(current.index)) {
              < 0 => VtcTrailStage.done,
              0 => VtcTrailStage.current,
              _ => VtcTrailStage.next,
            },
          ),
      ],
    );
  }
}

/// [child], the community's name, with what the community is behind an
/// icon beside it.
class _WithAbout extends StatelessWidget {
  const _WithAbout({required this.state, required this.child});

  final VtcJoinState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: child),
        IconButton(
          key: const Key('vtc_community_about'),
          icon: const Icon(Icons.info_outline, color: Colors.white),
          tooltip: context.l10n.vtcJoinProfileHeading,
          onPressed: () =>
              showOnboardingSheet(context, VtcCommunityProfile(state: state)),
        ),
      ],
    );
  }
}

/// Opens the settings of the community at [communityDid]: for now its join
/// phrase.
/// The community's settings for the member: how other members find them,
/// and, for an administrator, the community's join phrase.
Future<void> _showSettings(
  BuildContext context,
  String communityDid,
  String communityName, {
  required bool isAdmin,
}) => showOnboardingSheet(
  context,
  Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: [
      if (isAdmin)
        VtcJoinPhraseView(
          communityDid: communityDid,
          communityName: communityName,
        ),
      VtcFindableView(communityDid: communityDid, communityName: communityName),
    ],
  ),
);

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
