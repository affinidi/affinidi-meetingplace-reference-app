import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_service/vtc_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../vtc_join/vtc_membership_card_view.dart';
import '../vtc_join/vtc_role_name.dart';
import 'community_logo_provider.dart';

/// The member's membership of a community: their role there and the
/// membership card it issued, both as their VTA keeps them. Read from the
/// VTA each time this opens, never kept on the phone.
class CommunityMembershipView extends HookConsumerWidget {
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
    final load = useMemoized(() async {
      final service = ref.read(vtcServiceProvider);
      return (
        await service.communityRole(communityDid),
        await service.membershipCard(communityDid),
      );
    }, [communityDid]);
    final loaded = useFuture(load);
    final logoUrl = ref.watch(communityLogoProvider(communityDid)).value;

    if (loaded.error case final error?) {
      return _Message(switch (error) {
        VtaNotLinkedException() => l10n.membershipCredentialsVtaMissing,
        _ => l10n.membershipCredentialsUnreachable,
      });
    }
    final data = loaded.data;
    if (data == null) return const Center(child: OnboardingSpinner());
    final (role, card) = data;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (role != null)
            OnboardingLine(
              key: const Key('community_membership_role'),
              icon: McIcons.badge,
              title: l10n.vtcCommunityRole,
              subtitle: vtcRoleName(l10n, role),
            ),
          if (card != null)
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
        ],
      ),
    );
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
