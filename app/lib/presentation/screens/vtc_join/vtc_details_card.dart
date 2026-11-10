import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../../themes/tokens/mc_typography.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/identity_picker/identity_card.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
import '../../widgets/vta_identity_card.dart';
import 'vtc_claim_type_label.dart';

/// One profile detail shared in vetting: its claim type, e.g.
/// `email.personal`, and its value as shown.
typedef VtcDetail = ({String type, String value});

/// The profile details shared in vetting, drawn as an identity card, so
/// the applicant and the vetter see the same card: the person over the
/// card's upper edge, [heading] as its eyebrow, the applicant's name, the
/// other details by their icon and kind, and [note] as small print.
class VtcDetailsCard extends StatelessWidget {
  const VtcDetailsCard({
    super.key,
    required this.heading,
    required this.details,
    this.note,
  });

  /// Claim types that name the person, the first one given used as the
  /// card's name.
  static const _nameTypes = ['name.display', 'name.legal'];

  /// The picture straddles the card's upper edge by half its height, as
  /// on an identity card.
  static const _pictureSize = IdentityCard.pictureSize;

  final String heading;
  final List<VtcDetail> details;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final nameIndex = _nameTypes
        .map((type) => details.indexWhere((detail) => detail.type == type))
        .firstWhere((index) => index >= 0, orElse: () => -1);
    final name = nameIndex >= 0 ? details[nameIndex] : null;
    final rows = [
      for (final (index, detail) in details.indexed)
        if (index != nameIndex) detail,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: _pictureSize / 2),
      child: Stack(
        // The card takes the slot's full width, not its text's.
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          AppCard(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(McRadius.xl),
              side: BorderSide(color: mc.hairline),
            ),
            padding: const EdgeInsets.fromLTRB(
              McSpacing.s5,
              _pictureSize / 2 + McSpacing.s2,
              McSpacing.s5,
              14,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: McSpacing.s1,
              children: [
                Text(
                  heading.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: McTypography.eyebrow.copyWith(color: mc.textSecondary),
                ),
                if (name != null)
                  Text(
                    name.value,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: mc.textPrimary,
                    ),
                  ),
                const SizedBox(height: McSpacing.s2),
                for (final detail in rows) _DetailRow(detail: detail),
                if (note case final note?) ...[
                  Divider(height: 12, color: mc.hairline),
                  Text(note, style: onboardingNote(context)),
                ],
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: -_pictureSize / 2,
            child: Center(
              child: IdentityCardAvatar(picture: null, icon: McIcons.person),
            ),
          ),
        ],
      ),
    );
  }
}

/// A detail as an identity card shows a field: its icon and value, with
/// the kind of detail beside it, since two may share an icon.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.detail});

  final VtcDetail detail;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: McSpacing.s1),
      child: Row(
        spacing: McSpacing.s2,
        children: [
          Icon(_icon(detail.type), color: mc.textSecondary, size: 16),
          Expanded(
            child: Text(
              detail.value,
              style: textTheme.bodyLarge?.copyWith(color: mc.textPrimary),
            ),
          ),
          Text(
            vtcClaimTypeLabel(context.l10n, detail.type),
            style: textTheme.labelSmall?.copyWith(color: mc.textTertiary),
          ),
        ],
      ),
    );
  }

  static IconData _icon(String type) => switch (type) {
    'person.birthDate' => McIcons.calendar,
    'skill.language' => McIcons.chat,
    'account.handle' => McIcons.account,
    'address.country' => McIcons.location,
    _ when type.startsWith('name.') => McIcons.person,
    _ when type.startsWith('email.') => McIcons.email,
    _ when type.startsWith('phone.') => McIcons.phone,
    _ => McIcons.badge,
  };
}
