import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/identity/identity.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/contact_card_extensions.dart';
import '../../infrastructure/extensions/did_extensions.dart';
import '../../infrastructure/extensions/identities_extensions.dart';
import '../../infrastructure/providers/cache_manager_provider.dart';
import '../themes/tokens/mc_icons.dart';
import '../themes/tokens/mc_radius.dart';
import '../themes/tokens/mc_typography.dart';
import 'common/app_card.dart';
import 'identity_picker/identity_card.dart';
import 'identity_picker/identity_contact_rows.dart';
import 'onboarding_style/onboarding_style.dart';
import 'vta_details.dart';

/// A VTA identity as an MPX identity card: its picture centred over the
/// card's upper edge, the kind of identity over its name, with the VTA's
/// shield beside it for where it lives on the VTA, the details its profile
/// holds as the identity card shows them, and its DID as metadata. A null
/// [did] is the new identity the VTA would create.
class VtaIdentityCard extends ConsumerWidget {
  const VtaIdentityCard({
    super.key,
    required this.did,
    this.identity,
    this.missingCredential = false,
  });

  final String? did;

  /// The identity, with its profile as this phone keeps it in step with the
  /// VTA; null for an identity this phone does not hold.
  final Identity? identity;

  /// Whether the identity lacks a credential it needs, e.g. to join under
  /// a way into a community that asks for one; marked under its name.
  final bool missingCredential;

  static const _radius = Radius.circular(McRadius.xl);

  /// The picture straddles the card's upper edge by half its height, as
  /// on an identity card.
  static const _pictureSize = IdentityCard.pictureSize;

  static const _blurSigma = 20.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final mc = context.mcColors;
    final did = this.did;
    final identity = this.identity;
    final card = identity?.card;
    final displayName = card?.displayName.trim() ?? '';
    final picture = card != null && card.hasProfilePic
        ? card.image(cacheManager: ref.read(cacheManagerProvider))
        : null;

    // The upper half of the picture hangs above the card, inside the margin.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        IdentityCard.margin,
        _pictureSize / 2 + IdentityCard.margin,
        IdentityCard.margin,
        IdentityCard.margin,
      ),
      child: Stack(
        // The card takes the slot's full width, not its text's.
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          // An identity card, blurred behind as well so the card stacked
          // behind it in a deck cannot be read.
          ClipRRect(
            borderRadius: const BorderRadius.all(_radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
              child: AppCard(
                accent: identity?.getCardColor(context.colorScheme),
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(_radius),
                  side: BorderSide(color: mc.hairline),
                ),
                // Sized to its content, or filling a slot such as a card in a
                // deck, where it scrolls.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    _pictureSize / 2 + 8,
                    20,
                    14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 4,
                    children: [
                      // The kind of identity as an eyebrow, as on an
                      // identity card.
                      if (identity != null)
                        Text(
                          identity.getSubtitle(l10n: l10n).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: McTypography.eyebrow.copyWith(
                            color: mc.textSecondary,
                          ),
                        ),
                      // The VTA's shield beside the name, for an identity
                      // there.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              did == null
                                  ? l10n.vtcJoinNewIdentity
                                  : displayName.isNotEmpty
                                  ? displayName
                                  : l10n.vtcJoinExistingIdentity,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              // As a normal identity card's name.
                              style: textTheme.titleLarge?.copyWith(
                                color: mc.textPrimary,
                              ),
                            ),
                          ),
                          if (identity != null && identity.isVtaPersona)
                            VtaDetailsButton(
                              key: ValueKey(identity.id),
                              contextId: identity.vtaContextId!,
                              profileId: identity.vtaProfileId!,
                              color: mc.textSecondary,
                            ),
                        ],
                      ),
                      if (missingCredential)
                        Row(
                          key: const Key('vta_identity_missing_credential'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Icon(McIcons.error, size: 16, color: mc.dangerText),
                            Text(
                              l10n.vtcJoinCredentialMissing,
                              style: textTheme.labelMedium?.copyWith(
                                color: mc.dangerText,
                              ),
                            ),
                          ],
                        ),
                      if (did == null) ...[
                        Text(
                          l10n.vtcJoinNewIdentityHost,
                          textAlign: TextAlign.center,
                          style: textTheme.labelMedium?.copyWith(
                            color: mc.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.vtcJoinNewIdentityNote,
                          textAlign: TextAlign.center,
                          style: onboardingNote(context),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        if (card != null) IdentityContactRows(card: card),
                        Divider(height: 12, color: mc.hairline),
                        _DidMetadata(did: did),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -_pictureSize / 2,
            child: Center(
              child: IdentityCardAvatar(
                picture: picture,
                icon: did == null ? McIcons.personAdd : McIcons.person,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The identity's picture in the canvas-coloured ring an identity card's
/// picture wears, or [icon] when it has none.
class IdentityCardAvatar extends StatelessWidget {
  const IdentityCardAvatar({
    super.key,
    required this.picture,
    required this.icon,
  });

  final ImageProvider<Object>? picture;
  final IconData icon;

  /// As an identity card's picture's ring.
  static const _ring = 6.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final mc = context.mcColors;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.theme.scaffoldBackgroundColor,
          width: _ring,
        ),
      ),
      child: CircleAvatar(
        radius: IdentityCard.pictureSize / 2 - _ring,
        backgroundColor: colorScheme.surfaceContainerHigh,
        backgroundImage: picture,
        child: picture == null
            ? Icon(icon, size: 36, color: mc.textSecondary)
            : null,
      ),
    );
  }
}

/// The identity's DID on one line, set small and muted as metadata rather
/// than as a detail of the profile: its method, as much of its start as the
/// line holds, and all of it from the last colon, which names the identity.
class _DidMetadata extends StatelessWidget {
  const _DidMetadata({required this.did});

  final String did;

  /// The most of the start shown, as elsewhere for a DID's start.
  static const _maxStart = 24;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final style = McTypography.code.copyWith(
      color: mc.textTertiary,
      fontSize: context.textTheme.labelSmall?.fontSize,
      height: 1.4,
    );
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(McIcons.identities, size: 14, color: mc.textTertiary),
        ),
        Expanded(
          // An empty line sizes the row, so a layout that measures its
          // children's intrinsic height, such as the onboarding layout's,
          // never asks the LayoutBuilder, which cannot answer.
          child: Stack(
            children: [
              Text('', maxLines: 1, style: style),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool fits(String text) {
                      final painter = TextPainter(
                        text: TextSpan(text: text, style: style),
                        maxLines: 1,
                        textScaler: textScaler,
                        textDirection: textDirection,
                      )..layout(maxWidth: constraints.maxWidth);
                      final overflows = painter.didExceedMaxLines;
                      painter.dispose();
                      return !overflows;
                    }

                    return Text(
                      _shown(fits),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// The DID whole if it [fits], else with its start cut back, down to its
  /// method, until it does.
  String _shown(bool Function(String text) fits) {
    if (fits(did)) return did;
    // However narrow, `did:method:` stays.
    final minStart = did.indexOf(':', 'did:'.length) + 1;
    for (var start = _maxStart; start > minStart; start--) {
      final shown = did.topAndLastPart(charCountTop: start);
      if (fits(shown)) return shown;
    }
    return did.topAndLastPart(charCountTop: minStart);
  }
}
