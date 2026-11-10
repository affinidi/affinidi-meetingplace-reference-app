import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/vtc/vtc_membership_card.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_colors.dart';
import '../../themes/tokens/mc_elevation.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_spacing.dart';
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
    this.collapsible = false,
  });

  final VtcMembershipCard card;
  final String communityName;
  final Uri? logoUrl;

  /// See [VtcCardView.collapsible].
  final bool collapsible;

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
      documentIcon: McIcons.membership,
      chips: [
        if (card.personhood) (McIcons.person, l10n.vtcMembershipCardPersonhood),
      ],
      holderLabel: l10n.vtcMembershipCardMember,
      holderDid: card.memberDid,
      issuer: card.issuer,
      validFrom: card.validFrom,
      validUntil: card.validUntil,
      collapsible: collapsible,
    );
  }
}

/// A card a community issued, as a card on the page: the
/// community and [title], what the card states, whom it is about and for
/// how long, and the [credential] in full behind an icon, with the `pnm`
/// command that fetches it from the member's VTA.
class VtcCardView extends HookWidget {
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
    this.collapsible = false,
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

  /// Whether whom the card is about and for how long start folded away,
  /// for a list of cards, behind a chevron that opens them.
  final bool collapsible;

  static const _radius = Radius.circular(McRadius.lg);
  static const _blurSigma = 20.0;
  static const _logoSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final mc = context.mcColors;
    final expanded = useState(!collapsible);
    String date(DateTime at) =>
        DateFormat.yMMMd(l10n.localeName).format(at.toLocal());

    // The featured card of its page: Mission Control's card glow under it,
    // outside the clip so the glow is not cut off.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(_radius),
        boxShadow: McElevation.glowCard(context.theme.brightness),
      ),
      child: ClipRRect(
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
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: mc.insetTop)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  McSpacing.s4,
                  McSpacing.s4,
                  McSpacing.s2,
                  McSpacing.s4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: McSpacing.s3,
                  children: [
                    Row(
                      spacing: McSpacing.s3,
                      children: [
                        _Logo(url: logoUrl, size: _logoSize),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: McSpacing.s05,
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
                          icon: Icon(McIcons.receipt, color: mc.textPrimary),
                          tooltip: l10n.vtcMembershipCardShow,
                          onPressed: () => showVtcJoinJson(
                            context,
                            title: title,
                            json: credential,
                            icon: documentIcon,
                            subtitle: credentialType,
                            command: pnmCredentialCommand(credential['id']),
                          ),
                        ),
                        if (collapsible)
                          IconButton(
                            icon: Icon(
                              expanded.value
                                  ? McIcons.chevronUp
                                  : McIcons.chevronDown,
                              color: mc.textPrimary,
                            ),
                            tooltip: expanded.value
                                ? MaterialLocalizations.of(
                                    context,
                                  ).expandedIconTapHint
                                : MaterialLocalizations.of(
                                    context,
                                  ).collapsedIconTapHint,
                            onPressed: () => expanded.value = !expanded.value,
                          ),
                      ],
                    ),
                    for (final (icon, label) in chips)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _Chip(icon: icon, label: label),
                      ),
                    if (expanded.value)
                      Padding(
                        padding: const EdgeInsets.only(right: McSpacing.s2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: McSpacing.s3,
                          children: [
                            VtcDetailLine(
                              icon: McIcons.identities,
                              label: holderLabel,
                              value: holderDid,
                              isId: true,
                            ),
                            VtcDetailLine(
                              icon: McIcons.community,
                              label: l10n.vtcMembershipCardIssuedBy,
                              value: issuer,
                              isId: true,
                            ),
                            if (validFrom case final from?)
                              VtcDetailLine(
                                icon: McIcons.calendarCheck,
                                label: l10n.vtcMembershipCardValidFrom,
                                value: date(from),
                              ),
                            if (validUntil case final until?)
                              VtcDetailLine(
                                icon: McIcons.calendarX,
                                label: l10n.vtcMembershipCardValidUntil,
                                value: date(until),
                              ),
                            Row(
                              spacing: McSpacing.s2,
                              children: [
                                Icon(
                                  McIcons.cloudDone,
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
    final fallback = Icon(
      McIcons.community,
      color: McColors.blue,
      size: size / 2,
    );
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
        padding: const EdgeInsets.symmetric(
          horizontal: McSpacing.s2,
          vertical: McSpacing.s1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: McSpacing.s1,
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
