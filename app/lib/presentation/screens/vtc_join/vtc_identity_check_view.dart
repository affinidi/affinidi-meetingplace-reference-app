import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/vtc/vtc_identity_check.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_claim_type_label.dart';
import 'vtc_detail_line.dart';
import 'vtc_join_json_dialog.dart';

/// A check of the member's identity, by the community itself or by a
/// vetter: how it was checked, what was relied on and confirmed, and when,
/// with the signed statement in full behind a button, along with the `pnm`
/// command that fetches it from the member's VTA.
class VtcIdentityCheckView extends StatelessWidget {
  const VtcIdentityCheckView({
    super.key,
    required this.check,
    required this.checkerName,
  });

  final VtcIdentityCheck check;

  /// Who checked: the community, or the vetter who vouched.
  final String checkerName;

  /// The statement's type and predicate, named under its JSON as on the
  /// wire.
  static const _statementKind = 'StatementCredential · vetted/1';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String date(DateTime at) =>
        DateFormat.yMMMd(l10n.localeName).format(at.toLocal());
    final heading = l10n.vtcIdentityCheckHeading(checkerName);

    return GlassCard(
      key: const Key('vtc_identity_check'),
      title: heading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: McSpacing.s3,
        children: [
          VtcDetailLine(
            icon: McIcons.userCheck,
            label: l10n.vtcIdentityCheckHow,
            value: l10n.vtcIdentityCheckMethod(check.method),
          ),
          if (check.documentClasses.isNotEmpty)
            VtcDetailLine(
              icon: McIcons.badge,
              label: l10n.vtcIdentityCheckDocuments,
              value: '',
              items: [
                for (final document in check.documentClasses)
                  l10n.vtcIdentityCheckDocument(document),
              ],
            ),
          if (check.claimsVerified.isNotEmpty)
            VtcDetailLine(
              icon: McIcons.checkCircle,
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
              icon: McIcons.checkCircle,
              label: l10n.vtcIdentityCheckConfirmed,
              value: l10n.vtcIdentityCheckLiveness,
            ),
          if (check.validFrom case final validFrom?)
            VtcDetailLine(
              icon: McIcons.calendarCheck,
              label: l10n.vtcIdentityCheckCheckedOn,
              value: date(validFrom),
            ),
          if (check.validUntil case final validUntil?)
            VtcDetailLine(
              icon: McIcons.calendar,
              label: l10n.vtcIdentityCheckValidUntil,
              value: date(validUntil),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('vtc_identity_check_document'),
              icon: const Icon(McIcons.receipt),
              label: Text(l10n.vtcIdentityCheckShow),
              onPressed: () => showVtcJoinJson(
                context,
                title: heading,
                json: check.credential,
                icon: McIcons.credentials,
                subtitle: _statementKind,
                command: pnmCredentialCommand(check.credential['id']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
