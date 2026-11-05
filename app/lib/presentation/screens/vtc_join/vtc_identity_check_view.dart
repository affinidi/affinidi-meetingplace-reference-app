import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/vtc/vtc_identity_check.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_claim_type_label.dart';
import 'vtc_detail_line.dart';
import 'vtc_join_json_dialog.dart';

/// The community's own check of the member's identity: how it checked,
/// what it relied on and confirmed, and when, with the signed statement in
/// full behind a button.
class VtcIdentityCheckView extends StatelessWidget {
  const VtcIdentityCheckView({
    super.key,
    required this.check,
    required this.communityName,
  });

  final VtcIdentityCheck check;
  final String communityName;

  /// The statement's type and predicate, named under its JSON as on the
  /// wire.
  static const _statementKind = 'StatementCredential · vetted/1';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String date(DateTime at) =>
        DateFormat.yMMMd(l10n.localeName).format(at.toLocal());
    final heading = l10n.vtcIdentityCheckHeading(communityName);

    return GlassCard(
      key: const Key('vtc_identity_check'),
      title: heading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          VtcDetailLine(
            icon: Icons.how_to_reg_outlined,
            label: l10n.vtcIdentityCheckHow,
            value: l10n.vtcIdentityCheckMethod(check.method),
          ),
          if (check.documentClasses.isNotEmpty)
            VtcDetailLine(
              icon: Icons.badge_outlined,
              label: l10n.vtcIdentityCheckDocuments,
              value: '',
              items: [
                for (final document in check.documentClasses)
                  l10n.vtcIdentityCheckDocument(document),
              ],
            ),
          if (check.claimsVerified.isNotEmpty)
            VtcDetailLine(
              icon: Icons.task_alt,
              label: l10n.vtcIdentityCheckConfirmed,
              value: '',
              items: [
                for (final claim in check.claimsVerified)
                  vtcClaimTypeLabel(l10n, claim),
                if (check.livenessConfirmed) l10n.vtcIdentityCheckLiveness,
              ],
            )
          else if (check.livenessConfirmed)
            VtcDetailLine(
              icon: Icons.task_alt,
              label: l10n.vtcIdentityCheckConfirmed,
              value: l10n.vtcIdentityCheckLiveness,
            ),
          if (check.validFrom case final validFrom?)
            VtcDetailLine(
              icon: Icons.event_available_outlined,
              label: l10n.vtcIdentityCheckCheckedOn,
              value: date(validFrom),
            ),
          if (check.validUntil case final validUntil?)
            VtcDetailLine(
              icon: Icons.event_outlined,
              label: l10n.vtcIdentityCheckValidUntil,
              value: date(validUntil),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('vtc_identity_check_document'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(l10n.vtcIdentityCheckShow),
              onPressed: () => showVtcJoinJson(
                context,
                title: heading,
                json: check.credential,
                icon: Icons.verified_user_outlined,
                subtitle: _statementKind,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
