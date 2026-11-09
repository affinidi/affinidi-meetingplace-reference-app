import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/vtc/vtc_membership_card.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_colors.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_detail_line.dart';
import 'vtc_join_json_dialog.dart';

/// The membership card a community issued, as a card on the page: the
/// community, what the card states, and the credential in full behind an
/// icon.
class VtcMembershipCardView extends StatelessWidget {
  const VtcMembershipCardView({
    super.key,
    required this.card,
    required this.communityName,
    this.logoUrl,
  });

  final VtcMembershipCard card;
  final String communityName;
  final Uri? logoUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VtcCardView(
      cardKey: const Key('vtc_membership_card'),
      documentKey: const Key('vtc_membership_card_document'),
      communityName: communityName,
      logoUrl: logoUrl,
      title: l10n.vtcMembershipCardTitle,
      credential: card.credential,
      credentialType: 'MembershipCredential',
      documentIcon: Icons.card_membership_outlined,
      chips: [
        if (card.personhood)
          (Icons.person_outline, l10n.vtcMembershipCardPersonhood),
      ],
      holderLabel: l10n.vtcMembershipCardMember,
      holderDid: card.memberDid,
      issuer: card.issuer,
      validFrom: card.validFrom,
      validUntil: card.validUntil,
    );
  }
}

/// A card a community issued, as a card on the page: the
/// community and [title], what the card states, whom it is about and for
/// how long, and the [credential] in full behind an icon.
class VtcCardView extends StatelessWidget {
  const VtcCardView({
    super.key,
    required this.cardKey,
    required this.documentKey,
    required this.communityName,
    required this.title,
    required this.credential,
    required this.credentialType,
    required this.documentIcon,
    required this.holderLabel,
    required this.holderDid,
    required this.issuer,
    this.logoUrl,
    this.chips = const [],
    this.validFrom,
    this.validUntil,
  });

  final Key cardKey;
  final Key documentKey;
  final String communityName;
  final Uri? logoUrl;
  final String title;

  /// The credential exactly as the VTA keeps it, and its type, named under
  /// its JSON as on the wire.
  final Map<String, dynamic> credential;
  final String credentialType;
  final IconData documentIcon;

  /// What else the card states, each with its icon.
  final List<(IconData, String)> chips;

  /// Who the card is about, and the DID it names them by.
  final String holderLabel;
  final String holderDid;

  final String issuer;
  final DateTime? validFrom;
  final DateTime? validUntil;

  static const _radius = Radius.circular(McRadius.lg);
  static const _blurSigma = 20.0;
  static const _logoSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final mc = context.mcColors;
    String date(DateTime at) =>
        DateFormat.yMMMd(l10n.localeName).format(at.toLocal());

    return ClipRRect(
      borderRadius: const BorderRadius.all(_radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: DecoratedBox(
          key: cardKey,
          // A theme surface rather than a dark branded card: its details
          // are the shared VtcDetailLine, which follows the theme.
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            borderRadius: const BorderRadius.all(_radius),
            border: Border.all(color: mc.hairlineStrong),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    _Logo(url: logoUrl, size: _logoSize),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            communityName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              color: mc.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(title, style: onboardingNote(context)),
                        ],
                      ),
                    ),
                    IconButton(
                      key: documentKey,
                      icon: Icon(
                        Icons.receipt_long_outlined,
                        color: mc.textPrimary,
                      ),
                      tooltip: l10n.vtcMembershipCardShow,
                      onPressed: () => showVtcJoinJson(
                        context,
                        title: title,
                        json: credential,
                        icon: documentIcon,
                        subtitle: credentialType,
                      ),
                    ),
                  ],
                ),
                for (final (icon, label) in chips)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _Chip(icon: icon, label: label),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      VtcDetailLine(
                        icon: Icons.fingerprint,
                        label: holderLabel,
                        value: holderDid,
                        isId: true,
                      ),
                      VtcDetailLine(
                        icon: Icons.groups_outlined,
                        label: l10n.vtcMembershipCardIssuedBy,
                        value: issuer,
                        isId: true,
                      ),
                      if (validFrom case final from?)
                        VtcDetailLine(
                          icon: Icons.event_available_outlined,
                          label: l10n.vtcMembershipCardValidFrom,
                          value: date(from),
                        ),
                      if (validUntil case final until?)
                        VtcDetailLine(
                          icon: Icons.event_busy_outlined,
                          label: l10n.vtcMembershipCardValidUntil,
                          value: date(until),
                        ),
                      Row(
                        spacing: 8,
                        children: [
                          Icon(
                            Icons.cloud_done_outlined,
                            size: 16,
                            color: mc.textSecondary,
                          ),
                          Expanded(
                            child: Text(
                              l10n.vtcMembershipCardKept,
                              style: onboardingNote(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The community's logo in a white ring, or a group icon while there is
/// none or it cannot load.
class _Logo extends StatelessWidget {
  const _Logo({required this.url, required this.size});

  final Uri? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.groups, color: McColors.blue, size: size / 2);
    final url = this.url;
    return Container(
      width: size,
      height: size,
      // A white ring in both modes: community logos are drawn for a light
      // ground.
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? fallback
          : Image.network(
              url.toString(),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

/// A small outlined label, such as what else the card states.
class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: mc.hairlineStrong),
        borderRadius: BorderRadius.circular(McRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(icon, size: 14, color: mc.textSecondary),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: mc.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
