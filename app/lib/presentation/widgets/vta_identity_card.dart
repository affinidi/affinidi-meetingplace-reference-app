import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/contact_card/contact_card.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/contact_card_extensions.dart';
import '../../infrastructure/providers/cache_manager_provider.dart';
import 'onboarding_style/onboarding_style.dart';

/// A VTA identity as a card in the shape of an MPX identity card, with a
/// glass look on the gradient: its picture centred over the card's upper edge,
/// its name, the details its profile holds, and its full DID as metadata at
/// the foot. A null [did] is the new identity the VTA would create.
class VtaIdentityCard extends ConsumerWidget {
  const VtaIdentityCard({super.key, required this.did, this.card});

  final String? did;

  /// The identity's profile, as this phone keeps it in step with the VTA;
  /// null for an identity this phone does not hold.
  final ContactCard? card;

  static const _radius = Radius.circular(25);

  /// The picture straddles the card's upper edge by half its height.
  static const _avatarRadius = 40.0;
  static const _avatarRing = 3.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final did = this.did;
    final card = this.card;
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
          DecoratedBox(
            decoration: BoxDecoration(
              // Glass in look only: the sheen is blended onto the theme
              // colour rather than let through, so the card behind it in a
              // deck does not show.
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    Colors.white.withAlpha(60),
                    context.colorScheme.primary,
                  ),
                  Color.alphaBlend(
                    Colors.white.withAlpha(25),
                    context.colorScheme.primary,
                  ),
                ],
              ),
              borderRadius: const BorderRadius.all(_radius),
              border: Border.all(color: Colors.white.withAlpha(90)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                _avatarRadius + 10,
                16,
                14,
              ),
              // Sized to its content, or filling a slot such as a card in a
              // deck.
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (did == null) ...[
                    Text(
                      l10n.vtcJoinNewIdentityHost,
                      textAlign: TextAlign.center,
                      style: textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
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
                      Divider(height: 12, color: Colors.white.withAlpha(50)),
                    _DidMetadata(did: did),
                  ],
                ],
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

/// The identity's picture in a frosted ring, or [icon] when it has none.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.picture, required this.icon});

  final ImageProvider<Object>? picture;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VtaIdentityCard._avatarRing),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.alphaBlend(
          Colors.white.withAlpha(90),
          context.colorScheme.primary,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: VtaIdentityCard._avatarRadius - VtaIdentityCard._avatarRing,
        backgroundColor: Color.alphaBlend(
          Colors.white.withAlpha(50),
          context.colorScheme.primary,
        ),
        backgroundImage: picture,
        child: picture == null
            ? Icon(icon, size: 36, color: Colors.white)
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
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.fingerprint, size: 14, color: Colors.white54),
        ),
        Expanded(
          child: Text(
            did,
            style: context.textTheme.labelSmall?.copyWith(
              color: Colors.white60,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
