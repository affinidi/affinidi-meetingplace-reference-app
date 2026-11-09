import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/identity/identity.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/contact_card_extensions.dart';
import '../../infrastructure/providers/cache_manager_provider.dart';
import '../themes/tokens/mc_radius.dart';
import '../themes/tokens/mc_typography.dart';
import 'onboarding_style/onboarding_style.dart';
import 'vta_details.dart';

/// A VTA identity as a card in the shape of an MPX identity card, a panel
/// over the gradient: its picture centred over the card's upper edge,
/// its name, the details its profile holds, its full DID as metadata, and
/// where it lives on the VTA, collapsed. A null [did] is the new identity
/// the VTA would create.
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

  /// The picture straddles the card's upper edge by half its height.
  static const _avatarRadius = 40.0;
  static const _avatarRing = 3.0;

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
    final details = <(IconData, String)>[
      if (card != null) ...[
        if (card.fullName.isNotEmpty) (Icons.badge_outlined, card.fullName),
        if (card.emailAddress.trim().isNotEmpty)
          (Icons.email_outlined, card.emailAddress),
        if (card.mobilePhone.trim().isNotEmpty)
          (Icons.phone_outlined, card.mobilePhone),
      ],
    ];
    final picture = card != null && card.hasProfilePic
        ? card.image(cacheManager: ref.read(cacheManagerProvider))
        : null;

    // The upper half of the picture hangs above the card, inside the margin.
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, _avatarRadius + 8, 8, 8),
      child: Stack(
        // The card takes the slot's full width, not its text's.
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        children: [
          // A panel, blurred behind as well so the card stacked behind it in
          // a deck cannot be read.
          ClipRRect(
            borderRadius: const BorderRadius.all(_radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  borderRadius: const BorderRadius.all(_radius),
                  border: Border.all(color: mc.hairline),
                ),
                // Sized to its content, or filling a slot such as a card in a
                // deck, where the opened VTA details scroll.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    _avatarRadius + 10,
                    16,
                    14,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 6,
                    children: [
                      Text(
                        did == null
                            ? l10n.vtcJoinNewIdentity
                            : displayName.isNotEmpty
                            ? displayName
                            : l10n.vtcJoinExistingIdentity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: mc.textPrimary,
                        ),
                      ),
                      if (missingCredential)
                        Row(
                          key: const Key('vta_identity_missing_credential'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: mc.dangerText,
                            ),
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
                        const SizedBox(height: 4),
                        for (final (icon, value) in details)
                          _Detail(icon: icon, value: value),
                        if (details.isNotEmpty)
                          Divider(height: 12, color: mc.hairline),
                        _DidMetadata(did: did),
                        if (identity != null && identity.isVtaPersona) ...[
                          Divider(height: 12, color: mc.hairline),
                          VtaDetails(
                            key: ValueKey(identity.id),
                            contextId: identity.vtaContextId!,
                            profileId: identity.vtaProfileId!,
                            color: mc.textSecondary,
                          ),
                        ],
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
            top: -_avatarRadius,
            child: Center(
              child: _Avatar(
                picture: picture,
                icon: did == null ? Icons.person_add : Icons.person,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The identity's picture in a hairline ring, or [icon] when it has none.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.picture, required this.icon});

  final ImageProvider<Object>? picture;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final mc = context.mcColors;
    return Container(
      padding: const EdgeInsets.all(VtaIdentityCard._avatarRing),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: mc.hairline),
      ),
      child: CircleAvatar(
        radius: VtaIdentityCard._avatarRadius - VtaIdentityCard._avatarRing,
        backgroundColor: colorScheme.surfaceContainerHigh,
        backgroundImage: picture,
        child: picture == null
            ? Icon(icon, size: 36, color: mc.textSecondary)
            : null,
      ),
    );
  }
}

/// One detail of the identity's profile, by its icon.
class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 16, color: mc.textSecondary),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: mc.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// The identity's DID in full, set small and muted as metadata rather than
/// as a detail of the profile.
class _DidMetadata extends StatelessWidget {
  const _DidMetadata({required this.did});

  final String did;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.fingerprint, size: 14, color: mc.textTertiary),
        ),
        Expanded(
          child: Text(
            did,
            style: McTypography.code.copyWith(
              color: mc.textTertiary,
              fontSize: context.textTheme.labelSmall?.fontSize,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
