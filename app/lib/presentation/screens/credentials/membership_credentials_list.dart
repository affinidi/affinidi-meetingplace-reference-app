import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../application/services/identities_service/identities_service.dart';
import '../../../domain/models/vtc/vtc_membership_entry.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/tokens/mc_colors.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../widgets/common/app_card.dart';
import 'membership_credentials_controller.dart';
import 'membership_credentials_state.dart';

/// The member's membership cards, each with its community, the identity it
/// is for, until when it holds or when they left, and what its community
/// says of it now.
class MembershipCredentialsList extends ConsumerWidget {
  const MembershipCredentialsList({super.key, this.onOpen});

  /// Opens a card's details, if they can be opened.
  final void Function(VtcMembershipEntry entry)? onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(membershipCredentialsControllerProvider);

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (state.entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          switch (state.failure) {
            MembershipCredentialsFailure.vtaMissing =>
              l10n.membershipCredentialsVtaMissing,
            MembershipCredentialsFailure.unreachable =>
              l10n.membershipCredentialsUnreachable,
            null => l10n.membershipCredentialsNone,
          },
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // The cards kept on this phone stay shown when the VTA cannot be read.
    final note = switch (state.failure) {
      MembershipCredentialsFailure.vtaMissing =>
        l10n.membershipCredentialsVtaMissing,
      MembershipCredentialsFailure.unreachable =>
        l10n.membershipCredentialsSaved,
      null => null,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (note != null)
            Text(
              note,
              key: const Key('membership_credentials_note'),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          for (final entry in state.entries)
            MembershipCredentialRow(
              key: Key('membership_credential_${entry.key}'),
              entry: entry,
              status: state.statuses[entry.key],
              onTap: onOpen == null ? null : () => onOpen!(entry),
            ),
        ],
      ),
    );
  }
}

/// One membership card: its community, for which identity, until when or
/// since when left, and its state.
class MembershipCredentialRow extends ConsumerWidget {
  const MembershipCredentialRow({
    super.key,
    required this.entry,
    required this.status,
    this.onTap,
  });

  final VtcMembershipEntry entry;

  /// What its community says of it; null while being checked.
  final VtcCardStatus? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colorScheme;
    final identity = membershipIdentityName(context, ref, entry);
    final date = DateFormat.yMMMd(l10n.localeName);
    final when = switch ((entry.left, entry.card.validUntil)) {
      (final left?, _) => l10n.membershipCredentialLeft(
        date.format(left.leftAt.toLocal()),
      ),
      (null, final until?) => l10n.membershipCredentialUntil(
        date.format(until.toLocal()),
      ),
      _ => null,
    };

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: McSpacing.s4,
        vertical: McSpacing.s3,
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(Icons.card_membership_outlined, color: colors.onSurface),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  entry.communityName ?? l10n.membershipCredentialUnnamed,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  [l10n.membershipCredentialAs(identity), ?when].join(' · '),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          MembershipStatusChip(
            key: Key('membership_status_${entry.key}'),
            status: status,
          ),
        ],
      ),
    );
  }
}

/// A card's state in a word.
class MembershipStatusChip extends StatelessWidget {
  const MembershipStatusChip({super.key, required this.status});

  /// Null while it is being checked.
  final VtcCardStatus? status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = membershipStatusLabel(
      context.l10n,
      context.mcColors,
      status,
    );
    return StatusChip(
      label: label,
      color: color,
      danger: status?.state == VtcCardState.revoked,
    );
  }
}

/// A state's word, its status colour in the border.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.danger = false,
  });

  final String label;
  final Color color;

  /// Only danger may colour the word.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textColor = danger ? mc.dangerText : mc.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(McRadius.full),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(color: textColor),
      ),
    );
  }
}

/// A card's state as its chip shows it: the word and its status colour.
(String, Color) membershipStatusLabel(
  AppLocalizations l10n,
  McColors mc,
  VtcCardStatus? status,
) => switch (status?.state) {
  null => (l10n.membershipStatusChecking, mc.hairlineStrong),
  VtcCardState.valid => (l10n.membershipStatusValid, mc.success),
  VtcCardState.revoked => (l10n.membershipStatusRevoked, mc.dangerText),
  VtcCardState.expired => (l10n.membershipStatusExpired, mc.warning),
  VtcCardState.notRevocable => (
    l10n.membershipStatusNotRevocable,
    mc.highlightSecondary,
  ),
  VtcCardState.unknown => (l10n.membershipStatusUnknown, mc.hairlineStrong),
};

/// The name of the member's identity [entry]'s card is for.
String membershipIdentityName(
  BuildContext context,
  WidgetRef ref,
  VtcMembershipEntry entry,
) {
  final identity = ref
      .watch(identitiesServiceProvider)
      .identities
      .where((identity) => identity.did == entry.card.memberDid)
      .firstOrNull;
  final name = identity?.card.displayName.trim() ?? '';
  return name.isEmpty ? context.l10n.membershipCredentialOtherIdentity : name;
}
