import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/vtc/vtc_membership_card.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vtc_detail_line.dart';
import 'vtc_join_json_dialog.dart';

/// The membership card a community issued, as a frosted card on the
/// gradient: the community, what the card states, and the credential in
/// full behind an icon.
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

  static const _radius = Radius.circular(20);
  static const _blurSigma = 20.0;
  static const _logoSize = 44.0;

  /// The credential's type, named under its JSON as on the wire.
  static const _credentialType = 'MembershipCredential';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    String date(DateTime at) =>
        DateFormat.yMMMd(l10n.localeName).format(at.toLocal());

    return ClipRRect(
      borderRadius: const BorderRadius.all(_radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: DecoratedBox(
          key: const Key('vtc_membership_card'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withAlpha(70), Colors.white.withAlpha(25)],
            ),
            borderRadius: const BorderRadius.all(_radius),
            border: Border.all(color: Colors.white.withAlpha(110)),
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
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            l10n.vtcMembershipCardTitle,
                            style: onboardingNote(context),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('vtc_membership_card_document'),
                      icon: const Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.white,
                      ),
                      tooltip: l10n.vtcMembershipCardShow,
                      onPressed: () => showVtcJoinJson(
                        context,
                        title: l10n.vtcMembershipCardTitle,
                        json: card.credential,
                        icon: Icons.card_membership_outlined,
                        subtitle: _credentialType,
                      ),
                    ),
                  ],
                ),
                if (card.personhood)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _Chip(
                      icon: Icons.person_outline,
                      label: l10n.vtcMembershipCardPersonhood,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      VtcDetailLine(
                        icon: Icons.fingerprint,
                        label: l10n.vtcMembershipCardMember,
                        value: card.memberDid,
                        isId: true,
                      ),
                      VtcDetailLine(
                        icon: Icons.groups_outlined,
                        label: l10n.vtcMembershipCardIssuedBy,
                        value: card.issuer,
                        isId: true,
                      ),
                      if (card.validFrom case final from?)
                        VtcDetailLine(
                          icon: Icons.event_available_outlined,
                          label: l10n.vtcMembershipCardValidFrom,
                          value: date(from),
                        ),
                      if (card.validUntil case final until?)
                        VtcDetailLine(
                          icon: Icons.event_busy_outlined,
                          label: l10n.vtcMembershipCardValidUntil,
                          value: date(until),
                        ),
                      Row(
                        spacing: 8,
                        children: [
                          const Icon(
                            Icons.cloud_done_outlined,
                            size: 16,
                            color: Colors.white70,
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
    final fallback = Icon(
      Icons.groups,
      color: context.colorScheme.primary,
      size: size / 2,
    );
    final url = this.url;
    return Container(
      width: size,
      height: size,
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

/// A small frosted label, such as what else the card states.
class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        border: Border.all(color: Colors.white.withAlpha(90)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
